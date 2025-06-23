variable "aws_region" {
  description = "Région aws"
  type        = string
}

variable "aws_profile" {
  description = "Nom du profil AWS à utiliser pour le provisionnement terraform"
  type        = string
}

variable "project" {
  description = "Name of the project"
  type        = string
}

variable "env" {
  description = "Name of the environment (dev, stage, prod, ...)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR of the vpc"
  type        = string
}

variable "azs" {
  description = "Liste des Availability Zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR des subnets publics"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR des subnets privés"
  type        = list(string)
}

variable "database_subnets" {
  type = list(string)
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Enable NAT Gateway"
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "multi_az" {
  type = bool
}

variable "instance_types" {
  type = list(string)
}