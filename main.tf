provider "aws" {}

locals {
  image_id = data.aws_ami.boundary.id

  subnets = coalescelist(var.subnets, module.vpc.public_subnets)

  tags = merge(
    var.tags,
    {
      Owner = "terraform"
    }
  )

  vpc_id = coalesce(var.vpc_id, module.vpc.vpc_id)

  vpc_zone_identifier = coalescelist(var.vpc_zone_identifier, module.vpc.private_subnets)
}

data "aws_availability_zones" "available" {}

data "aws_ami" "boundary" {
  most_recent = true
  name_regex  = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
  owners      = ["aws-marketplace"]
}

module "controllers" {
  source = "./modules/controller"

  boundary_release    = var.boundary_release
  desired_capacity    = var.controller_desired_capacity
  image_id            = local.image_id
  instance_type       = var.controller_instance_type
  max_size            = var.controller_max_size
  min_size            = var.controller_min_size
  subnets             = local.subnets
  tags                = local.tags
  vpc_id              = local.vpc_id
  vpc_zone_identifier = local.vpc_zone_identifier
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

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
