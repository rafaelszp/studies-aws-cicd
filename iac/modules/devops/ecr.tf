resource "aws_ecr_repository" "ecr-repo" {
  name = "${var.department}/${var.project-name}"
  image_tag_mutability = "MUTABLE"
  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "ecr-lifecycle" {
  repository = aws_ecr_repository.ecr-repo.name
  policy = jsonencode({
    rules = [
      {
        rulePriority = 2
        description = "Expire images older than 14 days"
        selection = {
          tagStatus = "untagged"
          countType = "sinceImagePushed"
          countUnit = "days"
          countNumber = 14
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 1
        description = "Expire images older than 30 days with tag main-* or feature-*"
        selection = {
          tagStatus = "tagged"
          tagPrefixList = var.ecr-tags-to-cycle
          countType = "sinceImagePushed"
          countUnit = "days"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
  
}