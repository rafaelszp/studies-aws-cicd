resource "aws_cloudwatch_log_group" "log-group-codebuild" {
  # group_name = "/aws/codebuild/${var.department}/${var.project-name}-build"
  name = "/aws/codebuild/${var.department}/${var.project-name}-build"
  retention_in_days = var.retention-days
  tags = {
    TFName     = "${local.name}"
    Department = "${var.department}"
    Application = "${var.project-name}"
  }
}


# resource "aws_cloudwatch_log_group" "log_group_codebuild_deploy" {
#   name = "/aws/codebuild/${var.department}/${aws_codebuild_project.codebuild_vite_deploy.name}"
#   retention_in_days = var.cloudwatch_retention_days
#   tags = {
#     TFName     = "log_group_codebuild_deploy"
#     Department = "${var.department}"
#     Application = "${var.prefix}"
#   }
# }
