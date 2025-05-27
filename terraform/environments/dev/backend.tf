terraform {
  backend "s3" {
    bucket         = "eshop-tf-state"
    key            = "dev/terraform.tfstate"
    region         = "eu-west-3"
    dynamodb_table = "eshop-tf-lock"
  }
}
