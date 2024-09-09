output "log_groups" {
  value = module.infrastructure.log_groups
}

output "alb_dns_name" {
  value = module.infrastructure.alb.dns_name
}