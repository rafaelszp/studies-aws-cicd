module "devops" {
  source = "../../modules/devops"
  department = "communication"
  region = "us-east-2"
  project-name = "home-backend"
  codebuild-variables = []
  github-token = var.github-token
  repository-type = var.repository-type
  retention-days = var.retention-days
  repository-external-connection-name = var.repository-external-connection-name
  build-timeout = 10
  buildspec-file =  "cicd/backend.buildspec.yml"
  deployspec-file = "cicid/deploy.backend.buildspec.yml"
  pipeline-file-includes = ["backend/**/*","backend/*"]
  github-owner = var.github-owner
  github-repository = var.github-repository
  github-branch = var.github-branch
}