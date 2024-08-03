data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}


data "aws_iam_policy_document" "codepipeline_assume_role_policy" {
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
data "aws_iam_policy_document" "codebuild_policy" {
  policy_id = "CodeBuildPermissions"
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]
    resources = [
      "${aws_s3_bucket.bucket_cicd.arn}",
      "${aws_s3_bucket.bucket_cicd.arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "${aws_cloudwatch_log_group.log_group_codebuild.arn}",
      "${aws_cloudwatch_log_group.log_group_codebuild.arn}:*",
      "${aws_cloudwatch_log_group.log_group_codebuild_deploy.arn}",
      "${aws_cloudwatch_log_group.log_group_codebuild_deploy.arn}:*",
    ]
  }
  statement {
    effect = "Allow"
    resources = [
      "arn:aws:s3:::codepipeline-us-east-1-*"
    ]
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases",
      "codebuild:BatchPutCodeCoverages"
    ]
    resources = [
      "arn:aws:codebuild:${data.aws_region.region.name}:${data.aws_caller_identity.current_caller_id.account_id}:report-group/${var.prefix}-*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "codeartifact:GetAuthorizationToken",
      "codeartifact:DescribePackageVersion",
      "codeartifact:DescribeRepository",
      "codeartifact:GetPackageVersionReadme",
      "codeartifact:GetRepositoryEndpoint",
      "codeartifact:ListPackages",
      "codeartifact:ListPackageVersions",
      "codeartifact:ListPackageVersionAssets",
      "codeartifact:ListPackageVersionDependencies",
      "codeartifact:ReadFromRepository",
      "codeartifact:PublishPackageVersion",
      "codeartifact:PutPackageMetadata",
      "codeartifact:UpdatePackageGroup",
      "codeartifact:UpdatePackageVersionsStatus",
      "codeartifact:UpdateRepository",
      "codeartifact:DisposePackageVersions",
      "codeartifact:DeletePackageGroup",
      "codeartifact:CreatePackageGroup"
    ]
    resources = [
      "arn:aws:codeartifact:${data.aws_region.region.name}:${data.aws_caller_identity.current_caller_id.account_id}:domain/${aws_codeartifact_domain.nodejs_artifact_domain.domain}",
      "arn:aws:codeartifact:${data.aws_region.region.name}:${data.aws_caller_identity.current_caller_id.account_id}:repository/${aws_codeartifact_domain.nodejs_artifact_domain.domain}/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "sts:GetServiceBearerToken"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "sts:AWSServiceName"
      values = [
        "codeartifact.amazonaws.com",
        "codebuild.amazonaws.com",
        "codepipeline.amazonaws.com",
      ]
    }
  }

  statement {
    sid = "CodeBuildInlineECRPolicy"
    effect = "Allow"
    resources = [
      "${aws_ecr_repository.ecr_repo.arn}",
      "${aws_ecr_repository.ecr_repo.arn}/*",
    ]
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetAuthorizationToken"
     ]
  }

  # statement {
  #   effect = "Allow"
  #   actions = [
  #     "kms:GenerateDataKey"
  #   ]
  #   resources = [
  #     "${aws_kms_key.kms_bucket_encryption_key.arn}"
  #   ]
  # }
}

resource "aws_iam_role" "iam_codebuild_role" {
  name               = "${var.prefix}-codebuild_role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
}

resource "aws_iam_role" "code_pipeline_role" {
  name               = "${var.prefix}-codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role_policy.json
}

resource "aws_iam_role_policy" "iam_codebuild_policy_attach" {
  name   = "CodeBuildInlinePolicy"
  role   = aws_iam_role.iam_codebuild_role.id
  policy = data.aws_iam_policy_document.codebuild_policy.json
}

resource "aws_iam_role_policy" "iam_codepipeline_role_policy" {
  name   = "CodePipelineInlinePolicy"
  role   = aws_iam_role.code_pipeline_role.id
  policy = templatefile("${path.module}/templates/codepipeline_policy.tpl", {})
}
