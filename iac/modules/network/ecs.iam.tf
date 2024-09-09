locals {
  array_log_arns = [for log in aws_cloudwatch_log_group.ecs_log : "\"${log.arn}\""]
}
data "template_file" "ecs_task_role_template" {
  template = file("${path.module}/templates/ecs/ecs_execution_policy.tpl")
}

data "template_file" "ecs_permissions_template" {
  template = file("${path.module}/templates/ecs/ecs_permissions.tpl")

  vars = {
    ecr_arns = local.ecr_arns
    ecs_log_group_arns = "[${join(", ",local.array_log_arns)}]"
    ssm_secrets_arns = local.ssm_secrets_arns
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ECSTaskRole"
  assume_role_policy = data.template_file.ecs_task_role_template.rendered  
}

resource "aws_iam_policy" "ecs_custom_policy" {
  name = "ECSTaskPolicy"
  policy = data.template_file.ecs_permissions_template.rendered
}

resource "aws_iam_role_policy_attachment" "ecs_custom_policy" {
  role = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_custom_policy.arn
}