locals {
  name = "${var.department}-${var.project_name}"
}

data "aws_region" "current" {}