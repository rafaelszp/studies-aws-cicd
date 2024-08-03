resource "aws_ecr_repository" "ecr_repo" {
  name = "${var.department}/${var.prefix}"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

# data "aws_iam_policy_document" "ecr_codebuild_policy" {
#   statement {
#     sid    = "CodeBuildPolicy"
#     effect = "Allow"

#     principals {
#       type        = "AWS"
#       identifiers = ["${data.aws_caller_identity.current_caller_id.account_id}"]
#     }

#     actions = [
#       "ecr:GetDownloadUrlForLayer",
#       "ecr:BatchGetImage",
#       "ecr:BatchCheckLayerAvailability",
#       "ecr:PutImage",
#       "ecr:InitiateLayerUpload",
#       "ecr:UploadLayerPart",
#       "ecr:CompleteLayerUpload",
#       "ecr:DescribeRepositories",
#       "ecr:GetRepositoryPolicy",
#       "ecr:ListImages",
#       "ecr:DeleteRepository",
#       "ecr:BatchDeleteImage",
#       "ecr:SetRepositoryPolicy",
#       "ecr:DeleteRepositoryPolicy",
#       "ecr:GetAuthorizationToken",
#     ]
#   }
# }

# resource "aws_ecr_repository_policy" "example" {
#   repository = aws_ecr_repository.ecr_repo.name
#   policy     = data.aws_iam_policy_document.ecr_codebuild_policy.json
# }