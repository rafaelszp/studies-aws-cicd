output "log_groups" {
  value = module.infrastructure.log_groups
}

output "alb_dns_name" {
  value = module.infrastructure.alb.dns_name
}

output "ecs_cluster" {
  value = module.infrastructure.ecs  
}

output "task_definitions" {
  value = module.infrastructure.ecs_task_definitions
}