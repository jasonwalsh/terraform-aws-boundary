terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

locals {
  configuration = templatefile(
    "${path.module}/templates/configuration.hcl.tpl",
    {
      controllers = jsonencode(var.ip_addresses)

      keys = [
        {
          key_id  = data.aws_kms_key.auth.id
          purpose = "worker-auth"
        }
      ]
    }
  )
}

data "aws_kms_key" "auth" {
  key_id = var.kms_key_id
}

data "aws_security_group" "controller" {
  id = var.security_group_id
}

# Allows the workers to gossip with the controller on :9201
resource "aws_security_group_rule" "controller" {
  from_port                = 9201
  protocol                 = "TCP"
  security_group_id        = data.aws_security_group.controller.id
  source_security_group_id = aws_security_group.worker.id
  to_port                  = 9201
  type                     = "ingress"
}

resource "aws_security_group" "worker" {
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 9202
    protocol    = "TCP"
    to_port     = 9202
  }

  dynamic "ingress" {
    for_each = var.key_name != "" ? [22] : []

    content {
      from_port       = 22
      protocol        = "TCP"
      security_groups = [var.bastion_security_group]
      to_port         = 22
    }
  }

  name   = "BoundaryWorker"
  tags   = var.tags
  vpc_id = var.vpc_id
}

module "workers" {
  source = "../boundary"

  auto_scaling_group_name = "BoundaryWorker"
  boundary_release        = var.boundary_release
  bucket_name             = var.bucket_name
  desired_capacity        = var.desired_capacity
  iam_instance_profile    = aws_iam_instance_profile.worker.name
  image_id                = var.image_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  max_size                = var.max_size
  min_size                = var.min_size
  security_groups         = [aws_security_group.worker.id]
  tags                    = var.tags
  vpc_zone_identifier     = var.public_subnets

  write_files = [
    {
      content     = local.configuration
      owner       = "root:root"
      path        = "/etc/boundary/configuration.hcl"
      permissions = "0644"
    }
  ]
}

# https://www.boundaryproject.io/docs/configuration/kms/awskms#authentication
#
# Allows the workers to invoke the Decrypt, DescribeKey, and Encrypt
# routines for the worker-auth key.
data "aws_iam_policy_document" "kms" {
  statement {
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt"
    ]

    effect = "Allow"

    resources = [data.aws_kms_key.auth.arn]
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
  name   = "BoundaryWorkerServiceRolePolicy"
  policy = data.aws_iam_policy_document.kms.json
}

resource "aws_iam_role" "worker" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  name               = "ServiceRoleForBoundaryWorker"
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "kms" {
  policy_arn = aws_iam_policy.kms.arn
  role       = aws_iam_role.worker.name
}

resource "aws_iam_instance_profile" "worker" {
  role = aws_iam_role.worker.name
}
