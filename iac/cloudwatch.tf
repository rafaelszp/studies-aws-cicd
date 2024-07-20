resource "aws_cloudwatch_log_group" "log_group_codebuild" {
  name = "/aws/codebuild/${var.department}/${var.prefix}"
  retention_in_days = 1 
  tags = {
    TFName     = "log_group_codebuild"
    Department = "${var.department}"
    Application = "${var.prefix}"
  }
}