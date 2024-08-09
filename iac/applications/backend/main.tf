module "devops" {
  source = "../../modules/devops"
  department = "devops"
  region = "us-east-2"
  project-name = "home-frontend"
}