module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.12.0"

  identifier = "${local.name_prefix}-db"

  engine            = "postgres"
  engine_version    = 15
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 5432

  multi_az               = var.multi_az
  subnet_ids             = module.vpc.database_subnets
  create_db_subnet_group = false

  # vpc_security_group_ids = [module.sg_rds.node_security_group_id]
  create_db_parameter_group = false

  tags = {
    Project     = var.project
    Environment = var.env
  }
}