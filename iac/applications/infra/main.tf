module "infrastructure" {
  source       = "../../modules/network"
  department   = "communication"
  project_name = "home"
  vpc_id       = var.vpc_id
  retention_days = 14
  apps = {
    frontend = {
      default = true
      name              = "frontend"
      port              = 3000
      health_check_path = "/index.html"
      context_path      = "/"
      desired_count = 0
      launch_type = "FARGATE"
      image = "public.ecr.aws/nginx/nginx:1.27.1-alpine3.20-perl"
      cpu = 256
      memory = 512
      start_delay = 10
      priority = 100
      revision = 14
    },
    backend = {
      default = false
      name              = "backend"
      port              = 8080
      health_check_path = "/api/q/health"
      context_path      = "/api"
      desired_count = 0
      launch_type = "FARGATE"
      image = "public.ecr.aws/nginx/nginx:1.27.1-alpine3.20-perl"
      cpu = 256
      memory = 512
      start_delay = 10
      priority = 110
      revision = -1
    }
  }
}
