locals {
  name_prefix = "${var.project}-${var.env}"
}
variable "project" {
    description = "Name of the project"
    type = string
}

variable "env" {
    description = "Name of the environment (dev, stage, prod, ...)"
    type = string
}

variable "cidr_vpc" {
  description = "CIDR of the vpc"
  type = string
}

variable "subnets" {
    description = "Définition des subnets publics et privé avec AZ et CIDR"
    type = object({
      public = map(object({
        az = string
        cidr = string
      }))
      private = map(object({
        az = string
        cidr = string
      }))
    })
}