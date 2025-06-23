aws_region  = "eu-west-3"
aws_profile = "terraform"
project     = "eshop"
env         = "dev"

vpc_cidr = "10.0.0.0/16"

azs = ["eu-west-3a", "eu-west-3b"]

public_subnet_cidrs  = ["10.0.101.0/24"]
private_subnet_cidrs = ["10.0.1.0/24"]
database_subnets     = ["10.0.21.0/24", "10.0.22.0/24"]
enable_nat_gateway   = true
db_name              = "eshop"
db_username          = "admin"
db_password          = "azertyuiop"
multi_az             = false