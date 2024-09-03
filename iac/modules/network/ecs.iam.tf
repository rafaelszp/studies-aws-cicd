data "template_file" "ecs_task_role_template" {
  template = file("${path.module}/templates/ecs/ecs_execution_policy.tpl")
}

data "template_file" "ecs_permissions_template" {
  template = file("${path.module}/templates/ecs/ecs_permissions.tpl")

  vars = {
    ecr_arns = "*" #array
    ecr_log_group_arns = "*" #array
    ssm_secrets_arns = "*" #array
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ECSTaskRole"
  assume_role_policy = data.template_file.ecs_task_role_template.rendered  
}