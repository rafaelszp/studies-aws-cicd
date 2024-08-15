resource "aws_ecr_repository" "ecr-repo" {
  name = "${var.department}/${var.project-name}"
  image_tag_mutability = "MUTABLE"
  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
  }
}