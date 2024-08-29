data "aws_vpc" "vpc" {
 id = var.vpc_id 
}

data "aws_subnets" "subnets" {
  filter {
    name = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_subnet" "public" {
  for_each = toset(data.aws_subnets.subnets.ids)
  id = each.value
}
