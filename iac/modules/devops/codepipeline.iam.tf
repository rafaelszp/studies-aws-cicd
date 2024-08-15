resource "aws_iam_role" "code-pipeline-role" {
  name               = "${local.name}-codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline-assume-role-policy.json
}


resource "aws_iam_role_policy" "iam_codepipeline-role-policy" {
  name   = "CodePipelineInlinePolicy"
  role   = aws_iam_role.code-pipeline-role.id
  policy = templatefile("${path.module}/templates/codepipeline_policy.tpl", {})
}

data "aws_iam_policy_document" "codepipeline-assume-role-policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}