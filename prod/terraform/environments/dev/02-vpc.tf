module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "${local.name_prefix}-vpc"
  cidr = var.vpc_cidr

  azs = var.azs
  private_subnets = var.private_subnet_cidrs
  public_subnets = var.public_subnet_cidrs
  database_subnets = var.database_subnets

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = true
  enable_dns_support = true
  enable_dns_hostnames = true

  create_database_subnet_group = true

  tags = {
    Project     = var.project
    Environment = var.env
  }
}