cidr_vpc = "10.0.0.0/16"
project = "eshop"
env = "dev"

subnets = {
  public = {
    "a" = { az = "eu-west-3a", cidr = "10.0.1.0/24" }
  }
}