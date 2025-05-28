module "network" {
  source = "../../modules/network"
  cidr_vpc = var.cidr_vpc
  env = var.env
  project = var.project
  subnets = var.subnets
}