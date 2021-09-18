terraform {
  required_version = "~> 1.0"
}

locals {
  image_id = data.aws_ami.boundary.id

  private_subnets = coalescelist(var.private_subnets, module.vpc.private_subnets)

  public_subnets = coalescelist(var.public_subnets, module.vpc.public_subnets)

  tags = merge(
    var.tags,
    {
      Owner = "terraform"
    }
  )

  vpc_id = coalesce(var.vpc_id, module.vpc.vpc_id)
}

data "aws_availability_zones" "available" {}

data "aws_ami" "boundary" {
  most_recent = true
  name_regex  = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
  owners      = ["aws-marketplace"]
}

data "aws_s3_bucket_objects" "cloudinit" {
  bucket = aws_s3_bucket.boundary.id

  depends_on = [module.controllers]
}

resource "random_string" "boundary" {
  length  = 16
  special = false
  upper   = false
}

resource "aws_s3_bucket" "boundary" {
  acl           = "private"
  bucket        = "boundary-${random_string.boundary.result}"
  force_destroy = true
  tags          = local.tags
}

module "controllers" {
  source = "./modules/controller"

  boundary_release = var.boundary_release
  bucket_name      = aws_s3_bucket.boundary.id
  desired_capacity = var.controller_desired_capacity
  image_id         = local.image_id
  instance_type    = var.controller_instance_type
  key_name         = var.key_name
  max_size         = var.controller_max_size
  min_size         = var.controller_min_size
  private_subnets  = local.private_subnets
  public_subnets   = local.public_subnets
  tags             = local.tags
  vpc_id           = local.vpc_id
}

module "workers" {
  source = "./modules/worker"

  bastion_security_group = module.controllers.bastion_security_group
  boundary_release       = var.boundary_release
  bucket_name            = aws_s3_bucket.boundary.id
  desired_capacity       = var.worker_desired_capacity
  image_id               = local.image_id
  instance_type          = var.worker_instance_type
  ip_addresses           = module.controllers.ip_addresses
  key_name               = var.key_name
  kms_key_id             = module.controllers.kms_key_id
  max_size               = var.worker_max_size
  min_size               = var.worker_min_size
  public_subnets         = local.public_subnets
  security_group_id      = module.controllers.security_group_id
  tags                   = local.tags
  vpc_id                 = local.vpc_id
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.7.0"

  azs                = data.aws_availability_zones.available.names
  cidr               = var.cidr_block
  create_vpc         = var.vpc_id != "" ? false : true
  enable_nat_gateway = true
  name               = "boundary"

  private_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]

  public_subnets = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24"
  ]

  tags = local.tags
}
