resource "aws_cloudwatch_log_group" "log_group_codebuild" {
  name = "/aws/codebuild/${var.department}/${aws_codebuild_project.codebuild_vite_project.name}"
  retention_in_days = 1 
  tags = {
    TFName     = "log_group_codebuild"
    Department = "${var.department}"
    Application = "${var.prefix}"
  }
}

resource "aws_cloudwatch_log_group" "log_group_codebuild_deploy" {
  name = "/aws/codebuild/${var.department}/${aws_codebuild_project.codebuild_vite_deploy.name}"
  retention_in_days = 1 
  tags = {
    TFName     = "log_group_codebuild_deploy"
    Department = "${var.department}"
    Application = "${var.prefix}"
  }
}