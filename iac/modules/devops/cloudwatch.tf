resource "aws_cloudwatch_log_group" "log-group-codebuild-build" {
  name = "/aws/codebuild/${var.department}/${var.project-name}-build"
  retention_in_days = var.retention-days
  tags = {
    TFName     = "${local.name}"
    Department = "${var.department}"
    Application = "${var.project-name}"
  }
}


resource "aws_cloudwatch_log_group" "log-group-codebuild-deploy" {
  name = "/aws/codebuild/${var.department}/${var.project-name}-deploy"
  retention_in_days = var.retention-days
  tags = {
    TFName     = "${local.name}"
    Department = "${var.department}"
    Application = "${var.project-name}"
  }
}
