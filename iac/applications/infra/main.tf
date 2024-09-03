module "infrastructure" {
  source       = "../../modules/network"
  department   = "communication"
  project_name = "example"
  vpc_id       = var.vpc_id
  apps = {
    frontend = {
      name              = "frontend"
      port              = 3000
      health_check_path = "/index.html"
      context_path      = "/frontend"
      desired_count = 0
      launch_type = "FARGATE"
      image = "public.ecr.aws/nginx/nginx:1.27.1-alpine3.20-perl"
      cpu = 256
      memory = 512,
      start_delay = 10
    },
    backend = {
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
    }
  }
}
