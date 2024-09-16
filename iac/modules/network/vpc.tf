locals {
    subnet_id = [for k,v in data.aws_subnet.private : v.id][0]
}

data "aws_vpc" "vpc" {
 id = var.vpc_id 
}

data "aws_subnets" "private_subnets" {
  filter {
    name = "vpc-id"
    values = [var.vpc_id]
  }
  tags = {
    Tier = "private"
  }
}

data "aws_subnets" "public_subnets" {
  filter {
    name = "vpc-id"
    values = [var.vpc_id]
  }
  tags = {
    Tier = "public"
  }
}

data "aws_subnet" "public" {
  for_each = toset(data.aws_subnets.public_subnets.ids)
  id = each.value
}

data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private_subnets.ids)
  id = each.value
}

data "aws_internet_gateway" "igw" {
  filter {
    name   = "attachment.vpc-id"
    values = [var.vpc_id]
  }
}

resource "aws_eip" "eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id = local.subnet_id
}

resource "aws_route_table" "route_to_ngw" {
  vpc_id = var.vpc_id

  route {
    cidr_block = data.aws_vpc.vpc.cidr_block
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }
  
}

resource "aws_route_table_association" "route_to_ngw" {
  subnet_id = local.subnet_id
  route_table_id = aws_route_table.route_to_ngw.id
}




