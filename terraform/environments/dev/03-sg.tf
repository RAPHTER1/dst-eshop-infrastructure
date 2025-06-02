# module "sg_rds" {
#   source  = "terraform-aws-modules/security-group/aws"
#   version = "5.1.0"

#   name        = "${local.name_prefix}-rds-sg"
#   description = "Security group for RDS PostgreSQL"
#   vpc_id      = module.vpc.vpc_id

#   ingress_with_source_security_group_id = [
#     {
#       rule                     = "postgresql-tcp"
#       source_security_group_id = module.eks.node_security_group_id
#     }
#   ]

#   egress_rules = ["all-all"]

#   tags = {
#     Project     = var.project
#     Environment = var.env
#   }
# }

module "sg_bastion" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "${var.project}-${var.env}-bastion"
  description = "Allow SSH"
  vpc_id      = module.vpc.vpc_id

  ingress_rules       = ["ssh-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules = ["all-all"]

  tags = {
    Project     = var.project
    Environment = var.env
  }
}

#Ajouter la règle qui permet au bastion d'acceder à l'api EKS
resource "aws_security_group_rule" "bastion_to_eks_api" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  security_group_id = module.eks.security_group_id
  source_security_group_id = module.sg_bastion.security_group_id
}