locals {
  array_log_arns = [for log in aws_cloudwatch_log_group.ecs_log : "\"${log.arn}:*\""]
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
    region = data.aws_region.current.name
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.department}_ECSTaskRole"
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

data "template_file" "ecs_asg_role_template" {
  template = file("${path.module}/templates/ecs/ecs_asg.tpl")
}

resource "aws_iam_role" "ecs_asg_role" {
  name = "${var.department}_ECSASGRole"
  assume_role_policy = data.template_file.ecs_asg_role_template.rendered
}


resource "aws_iam_role_policy_attachment" "ecs_asg_policy_attachment" {
  role = aws_iam_role.ecs_asg_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}