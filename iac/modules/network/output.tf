output "alb" {
  value = {
    arn                   = aws_alb.alb.arn
    dns_name              = aws_alb.alb.dns_name
    id                    = aws_alb.alb.id,
    target_group_arns     = [for target_group in aws_alb_target_group.target_group : target_group.arn]
    alb_security_group_id = aws_security_group.sg_alb.id
  }
}

output "ecs" {
  value = {
    cluster_name = aws_ecs_cluster.ecs_cluster.name
    cluster_id   = aws_ecs_cluster.ecs_cluster.id
    services = [for service in aws_ecs_service.ecs_service : {
      name = service.name
    }]
    task_definitions = [for task_definition in data.template_file.task_template : {
      json = task_definition.rendered
    }]
  }
}

output "log_groups" {
  value = [for log_group in aws_cloudwatch_log_group.ecs_log : {
    name = log_group.name
  }]
}

output "vpc" {
  value = {
    vpc_id         = data.aws_vpc.vpc.id
    vpc_cidr_block = data.aws_vpc.vpc.cidr_block
  }
}
