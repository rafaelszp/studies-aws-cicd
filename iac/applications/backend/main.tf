module "devops" {
  source = "../../modules/devops"
  department = "communication"
  region = "us-east-2"
  project-name = "home-backend"
  codebuild-variables = []
  github-token = var.github-token
}