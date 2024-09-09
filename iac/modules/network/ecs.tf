resource "aws_ecs_cluster" "ecs_cluster" {
  name = local.name  
}

data "template_file" "task_template" {
  template = file("${path.module}/templates/ecs/task_definition.tpl")
  for_each = var.apps

  vars = {
    app_name = each.value.name
    app_image = each.value.image
    app_cpu = each.value.cpu
    app_memory = each.value.memory
    aws_region = data.aws_region.current.name
    app_port = each.value.port
    app_health_check_path = each.value.health_check_path
    app_start_delay = each.value.start_delay
    app_restart_delay = sum([each.value.start_delay, 60])
    app_department = var.department
    app_project_name =  var.project_name
  }
}

resource "aws_ecs_task_definition" "task_definition" {
  for_each = var.apps
  family = "${each.key}-task"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = each.value.cpu
  memory = each.value.memory
  container_definitions = data.template_file.task_template[each.key].rendered
  execution_role_arn = aws_iam_role.ecs_task_role.arn
}

resource "aws_security_group" "sg_ecs" {
  name        = "${local.name}-ecs-sg"
  vpc_id      = var.vpc_id
  description = "Security group for ECS services"

  dynamic "ingress" {
    for_each = var.apps
    iterator = app 
    content {
      from_port   = app.value.port
      to_port     = app.value.port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

resource "aws_ecs_service" "ecs_service" {
  for_each = var.apps
  name            = each.key
  cluster         = aws_ecs_cluster.ecs_cluster.id
  # task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  task_definition = aws_ecs_task_definition.task_definition[each.key].arn
  desired_count   = each.value.desired_count
  launch_type     = each.value.launch_type
  network_configuration {
    subnets         = [for subnet in data.aws_subnet.public : subnet.id]
    security_groups  = [aws_security_group.sg_ecs.id]
    # assign_public_ip = var.assign_public_ip
  }
  load_balancer {
    target_group_arn = aws_alb_target_group.target_group[each.key].arn
    container_name   = each.value.name
    container_port   = each.value.port
  }  
}