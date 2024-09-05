resource "aws_cloudwatch_log_group" "ecs_log" {
  for_each = var.apps
  name = "/aws/ecs/${var.project_name}-${each.value.name}"
  retention_in_days = var.retention_days
}