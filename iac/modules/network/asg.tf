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
    #60-75
    step_adjustment {
      metric_interval_lower_bound = 0
      metric_interval_upper_bound = 15
      scaling_adjustment = 2
    }
    #75-90
    step_adjustment {
      metric_interval_lower_bound = 15
      metric_interval_upper_bound = 30
      scaling_adjustment = 5
    }
    #90-inf
    step_adjustment {
      metric_interval_lower_bound = 30
      scaling_adjustment = 10
    }
  }
  depends_on = [ aws_appautoscaling_target.ecs_target ]  
}

resource "aws_appautoscaling_policy" "ecs_down" {
  for_each = var.apps
  name = "${each.key}-scale-down"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
  resource_id = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs_service[each.key].name}"
  policy_type = "StepScaling"

  step_scaling_policy_configuration {
    adjustment_type = "ChangeInCapacity"
    cooldown = 60
    metric_aggregation_type = "Average"
    #10-0
    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment = -1
    }
  }
  depends_on = [ aws_appautoscaling_target.ecs_target ]  
}

resource "aws_cloudwatch_metric_alarm" "ecs_service_up" {
  for_each = var.apps
  alarm_actions = [aws_appautoscaling_policy.ecs_up[each.key].arn]
  alarm_name = replace("${each.key}_cpu_utilization_high","-","_")
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 2 # 2 minutes (period * evaluation_periods)
  metric_name = "CPUUtilization"
  namespace = "AWS/ECS"
  period = 60
  statistic = "Average"
  threshold = 60
  dimensions = {
    ClusterName = aws_ecs_cluster.ecs_cluster.name
    ServiceName = aws_ecs_service.ecs_service[each.key].name
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_service_down" {
  for_each = var.apps
  alarm_actions = [aws_appautoscaling_policy.ecs_down[each.key].arn]
  alarm_name = replace("${each.key}_cpu_utilization_low","-","_")
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = 2 # 2 minutes (period * evaluation_periods)
  metric_name = "CPUUtilization"
  namespace = "AWS/ECS"
  period = 60
  statistic = "Average"
  threshold = 10
  dimensions = {
    ClusterName = aws_ecs_cluster.ecs_cluster.name
    ServiceName = aws_ecs_service.ecs_service[each.key].name
  }
}