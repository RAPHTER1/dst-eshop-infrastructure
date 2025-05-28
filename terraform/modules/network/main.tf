resource "aws_vpc" "this" {
    cidr_block = var.cidr_vpc
    enable_dns_hostnames = true
    enable_dns_support = true
    
    tags = {
      Name = "${local.name_prefix}-vpc"
    }
}

resource "aws_subnet" "public" {
  for_each = var.subnets.public
  
  vpc_id = aws_vpc.this.id
  cidr_block = each.value.cidr
  availability_zone = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name = "${locals.name_prefix}-public-${each.key}"
  }
}

resource "aws_subnet" "private" {
  for_each = var.subnets.private

  vpc_id = aws_vpc.this.id
  cidr_block = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${locals.name_prefix}-public-${each.key}"
  }
}