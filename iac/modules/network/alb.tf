locals {
  default_app_name = [for key, value in var.apps: key if value.default == true][0]
}
resource "aws_alb" "alb" {
  name            = local.name
  subnets         = [for subnet in data.aws_subnet.public : subnet.id]
  security_groups = [aws_security_group.sg_alb.id]
}


resource "aws_alb_target_group" "target_group" {
  for_each = var.apps

  name        = each.key
  port        = each.value.port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  deregistration_delay = 10
  stickiness {
    type = "lb_cookie"
    cookie_duration = 3600
  }

  health_check {
    path                = each.value.health_check_path
    protocol            = "HTTP"
    port                = each.value.port
    interval            = 5
    timeout             = 3
    matcher             = "200,201"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

}

resource "aws_alb_listener" "listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.target_group[local.default_app_name].arn
  }
}

resource "aws_alb_listener_rule" "rule" {
  for_each     = var.apps
  listener_arn = aws_alb_listener.listener.arn
  priority = each.value.priority
  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.target_group[each.key].arn

  }
  condition {
    path_pattern {
      values = [each.value.context_path]
    }
  }
  depends_on = [ aws_alb.alb ]
}

resource "aws_security_group" "sg_alb" {
  name   = "${local.name}-alb-sg"
  vpc_id = var.vpc_id

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
