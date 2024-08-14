locals {
  name = "${var.department}-${var.project-name}"
}

data "aws_region" "region" {

}

data "aws_caller_identity" "current_caller_id" {

}