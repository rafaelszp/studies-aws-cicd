resource "aws_ecr_repository" "ecr_repo" {
  name = "${var.department}/${var.prefix}"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}
resource "aws_ecr_repository" "ecr_repo_backend" {
  name = "${var.department}/${var.prefix}-backend"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}