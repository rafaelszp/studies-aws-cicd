resource "aws_appautoscaling_target" "ecs_target" {
  for_each = var.apps
  max_capacity = each.value.max_capacity
  min_capacity = each.value.min_capacity
  resource_id = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs_service[each.key].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"  
  role_arn = aws_iam_role.ecs_asg_role.arn
}

resource "aws_appautoscaling_policy" "ecs_up" {
  for_each = var.apps
  name = "${each.key}-scale-up"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
  resource_id = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs_service[each.key].name}"
  policy_type = "StepScaling"
  step_scaling_policy_configuration {
    adjustment_type = "ChangeInCapacity"
    cooldown = 60
    metric_aggregation_type = "Average"
    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment = 1
    }
  }
  depends_on = [ aws_appautoscaling_target.ecs_target ]  
}