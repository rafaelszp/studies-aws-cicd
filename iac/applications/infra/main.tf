module "infrastructure" {
  source                     = "../../modules/network"
  department                 = "communication"
  project_name               = "example"
  vpc_id                     = var.vpc_id
  apps = [{
    name              = "frontend"
    port              = 3000
    health_check_path = "/index.html"
    context_path      = "/frontend"
    },
    {
      name              = "backend"
      port              = 8080
      health_check_path = "/api/q/health"
      context_path      = "/api"
  }]
}
