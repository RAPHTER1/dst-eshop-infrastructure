module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "20.36.0"

  cluster_name = "${local.name_prefix}-eks"
  cluster_version = "1.31"
  subnet_ids = module.vpc.private_subnets
  vpc_id = module.vpc.vpc_id

  enable_irsa = true

  eks_managed_node_groups = {
    default = {
        instance_types = [var.instance_types]
        desired_size = 1
        max_size = 1
        min_size = 1
    }
  }

  tags = {
    Environment = var.env
    Project     = var.project
  }
}