locals {
  configuration = templatefile(
    "${path.module}/templates/configuration.hcl.tpl",
    {
      # Database URL for PostgreSQL
      database_url = format(
        "postgresql://%s:%s@%s/%s",
        module.postgresql.this_db_instance_username,
        module.postgresql.this_db_instance_password,
        module.postgresql.this_db_instance_endpoint,
        module.postgresql.this_db_instance_name
      )

      keys = [
        {
          key_id  = aws_kms_key.root.key_id
          purpose = "root"
        },
        {
          key_id  = aws_kms_key.auth.key_id
          purpose = "worker-auth"
        }
      ]
    }
  )
}

resource "aws_security_group" "alb" {
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  dynamic "ingress" {
    for_each = [80, 443]

    content {
      cidr_blocks = ["0.0.0.0/0"]
      from_port   = ingress.value
      protocol    = "TCP"
      to_port     = ingress.value
    }
  }

  name = "Boundary Application Load Balancer"

  tags = merge(
    {
      Name = "Boundary Application Load Balancer"
    },
    var.tags
  )

  vpc_id = var.vpc_id
}

resource "aws_security_group" "controller" {
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    from_port       = 9200
    protocol        = "TCP"
    security_groups = [aws_security_group.alb.id]
    to_port         = 9200
  }

  name   = "Boundary controller"
  tags   = var.tags
  vpc_id = var.vpc_id
}

resource "aws_security_group" "postgresql" {
  ingress {
    from_port       = 5432
    protocol        = "TCP"
    security_groups = [aws_security_group.controller.id]
    to_port         = 5432
  }

  tags   = var.tags
  vpc_id = var.vpc_id
}

module "alb" {
  source = "terraform-aws-modules/alb/aws"

  http_tcp_listeners = [
    {
      port     = 80
      protocol = "HTTP"
    }
  ]

  load_balancer_type = "application"
  name               = "boundary"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnets
  tags               = var.tags

  target_groups = [
    {
      name             = "boundary"
      backend_protocol = "HTTP"
      backend_port     = 9200
    }
  ]

  vpc_id = var.vpc_id
}

resource "random_password" "postgresql" {
  length  = 16
  special = false
}

module "postgresql" {
  source = "terraform-aws-modules/rds/aws"

  allocated_storage       = 5
  backup_retention_period = 0
  backup_window           = "03:00-06:00"
  engine                  = "postgres"
  engine_version          = "12.4"
  family                  = "postgres12"
  identifier              = "boundary"
  instance_class          = "db.t2.micro"
  maintenance_window      = "Mon:00:00-Mon:03:00"
  major_engine_version    = "12"
  name                    = "boundary"
  password                = random_password.postgresql.result
  port                    = 5432
  storage_encrypted       = false
  subnet_ids              = var.private_subnets
  tags                    = var.tags
  username                = "boundary"
  vpc_security_group_ids  = [aws_security_group.postgresql.id]
}

module "controllers" {
  source = "../boundary"

  auto_scaling_group_name = "boundary-controller"
  boundary_release        = var.boundary_release
  desired_capacity        = var.desired_capacity
  iam_instance_profile    = aws_iam_instance_profile.controller.name
  image_id                = var.image_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  max_size                = var.max_size
  min_size                = var.min_size

  # Initialize the DB before starting the service
  runcmd = [
    "boundary database init -config /etc/boundary/configuration.hcl"
  ]

  security_groups     = [aws_security_group.controller.id]
  tags                = var.tags
  target_group_arns   = module.alb.target_group_arns
  vpc_zone_identifier = var.private_subnets

  write_files = [
    {
      content     = base64encode(local.configuration)
      encoding    = "b64"
      owner       = "root:root"
      path        = "/etc/boundary/configuration.hcl"
      permissions = "0644"
    }
  ]
}

# https://www.boundaryproject.io/docs/configuration/kms/awskms#authentication
#
# Allows the controllers to invoke the Decrypt, DescribeKey, and Encrypt
# routines for the worker-auth and root keys.
data "aws_iam_policy_document" "kms" {
  statement {
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt"
    ]

    effect = "Allow"

    resources = [aws_kms_key.auth.arn, aws_kms_key.root.arn]
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    effect = "Allow"

    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_policy" "kms" {
  name   = "BoundaryControllerServiceRolePolicy"
  policy = data.aws_iam_policy_document.kms.json
}

resource "aws_iam_role" "controller" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  name               = "ServiceRoleForBoundaryController"
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "kms" {
  policy_arn = aws_iam_policy.kms.arn
  role       = aws_iam_role.controller.name
}

resource "aws_iam_instance_profile" "controller" {
  role = aws_iam_role.controller.name
}

# The root key used by controllers
resource "aws_kms_key" "root" {
  deletion_window_in_days = 7
  key_usage               = "ENCRYPT_DECRYPT"
  tags                    = merge(var.tags, { Purpose = "root" })
}

# The worker-auth AWS KMS key used by controllers and workers
resource "aws_kms_key" "auth" {
  deletion_window_in_days = 7
  key_usage               = "ENCRYPT_DECRYPT"
  tags                    = merge(var.tags, { Purpose = "worker-auth" })
}
