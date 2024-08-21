resource "aws_ssm_parameter" "secret" {
  name        = var.application-secret.name
  description = var.application-secret.description
  type        = "SecureString"
  value       = var.application-secret.value
  overwrite = true

  tags = {
    environment = "production"
    TFName     = "${local.name}-application-properties"
    Department = "${var.department}"
    Application = "${var.project-name}"
  }
}