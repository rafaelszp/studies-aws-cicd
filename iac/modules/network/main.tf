locals {
  name = "${var.department}-${var.project_name}"
  #ecr_arns = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${var.department}/*"
  #arn:aws:ecr:us-east-2:730335591954:repository/communication/home-frontend
  ecr_arns = jsonencode("arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/${var.department}/*")
  ssm_secrets_arns = jsonencode("arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${upper(var.environment_name)}_${upper(var.department)}_*")
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}