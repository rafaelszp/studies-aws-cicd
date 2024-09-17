locals {
  subnet_id        = [for k, v in data.aws_subnet.private : v.id][0]
  public_subnet_id = [for k, v in data.aws_subnet.public : v.id][0]
  gateway_vpc_endpoints = {
    "s3" = {
      "service_name"    = "com.amazonaws.${data.aws_region.current.name}.s3",
      "route_table_ids" = toset(data.aws_route_tables.private_route_tables.ids)
    }
  }
  interface_vpc_endpoints = {
    "ecr.dkr" = {
      "service_name"    = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
    },
    "ecr.api" = {
      "service_name"    = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
    },
    "logs" = {
      "service_name"    = "com.amazonaws.${data.aws_region.current.name}.logs"
    }
  }
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  tags = {
    Tier = "private"
  }
}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  tags = {
    Tier = "public"
  }
}

data "aws_route_tables" "private_route_tables" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  tags = {
    Tier = "private"
  }
}

data "aws_subnet" "public" {
  for_each = toset(data.aws_subnets.public_subnets.ids)
  id       = each.value
}

data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private_subnets.ids)
  id       = each.value
}


resource "aws_security_group" "sg_vpc_endpoint" {
  name   = "${local.name}-vpc-endpoint-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

data "template_file" "vpc_endpoint_policy"{
  template = file("${path.module}/templates/vpc/endpoint_policy.tpl")
}

resource "aws_vpc_endpoint" "gw_endpoint" {
  for_each = local.gateway_vpc_endpoints
  vpc_id = var.vpc_id
  service_name = each.value.service_name
  route_table_ids = each.value.route_table_ids
  vpc_endpoint_type = "Gateway"  
  private_dns_enabled = true
  security_group_ids = [aws_security_group.sg_vpc_endpoint.id]
  policy = data.template_file.vpc_endpoint_policy.rendered
}

resource "aws_vpc_endpoint" "iface_endpoint" {
  for_each = local.interface_vpc_endpoints
  vpc_id = var.vpc_id
  service_name = each.value.service_name
  subnet_ids = data.aws_subnets.private_subnets.ids
  vpc_endpoint_type = "Interface"   
  private_dns_enabled = true
  security_group_ids = [aws_security_group.sg_vpc_endpoint.id]
  policy = data.template_file.vpc_endpoint_policy.rendered
}

# resource "aws_vpc_endpoint" "vpc_endpoints" {
#   for_each = toset(local.vpc_endpoints)
#   vpc_id = var.vpc_id
#   service_name = each.key
#   subnet_ids = data.aws_subnets.private_subnets.ids
#   vpc_endpoint_type = "Interface"
# }
# data "aws_internet_gateway" "igw" {
#   filter {
#     name   = "attachment.vpc-id"
#     values = [var.vpc_id]
#   }
# }

# resource "aws_eip" "eip" {
#   domain = "vpc"
# }

# resource "aws_nat_gateway" "ngw" {
#   allocation_id = aws_eip.eip.id
#   subnet_id = local.public_subnet_id
# }

# resource "aws_route_table" "route_to_ngw" {
#   vpc_id = var.vpc_id

#   route {
#     cidr_block = data.aws_vpc.vpc.cidr_block
#     gateway_id = "local"
#   }

#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.ngw.id
#   }
# }

# resource "aws_route_table_association" "route_to_ngw" {
#   subnet_id = local.subnet_id
#   route_table_id = aws_route_table.route_to_ngw.id
# }




