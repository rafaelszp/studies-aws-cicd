
resource "aws_codebuild_source_credential" "github_token_credential" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = "${var.github-token}"
}
resource "aws_codebuild_project" "codebuild_project" {

  name = "${local.name}-build"
  # encryption_key = aws_kms_key.kms_bucket_encryption_key.arn
  encryption_key = data.aws_kms_key.s3_kms_key.arn
  project_visibility = "PRIVATE"

  tags = {
    TFName     = "${local.name}"
    Department = "${var.department}"
    Application = "${var.project-name}"
  }
  
  description = "Build project for ${local.name}"
  build_timeout = 5
  service_role = aws_iam_role.iam-codebuild-role.arn


  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type = "S3"
    location = "${aws_s3_bucket.bucket-devops.bucket}/${var.department}/${var.project-name}/build/cache"
  }

  source {
    buildspec = "var.buildspec-file"
    type = "${var.source-type}"
  }

  environment {
    # compute_type = "BUILD_GENERAL1_SMALL"
    compute_type = "${var.codebuild-computer-type}"
    # image = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    image = "${var.codebuild-image}"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode = false
    type = "LINUX_CONTAINER"

    dynamic "environment_variable" {
     iterator = variable 
     for_each = var.codebuild-variables
     content {
      name = variable.value["name"]
      value = variable.value["value"]
     }
    }

    # environment_variable {
    #   name = "NPM_REPOSITORY_URL"
    #   value = "${aws_codeartifact_domain.nodejs_artifact_domain.domain}-${aws_codeartifact_domain.nodejs_artifact_domain.owner}.d.codeartifact.${data.aws_region.region.name}.amazonaws.com/npm/${aws_codeartifact_repository.node_artifact_repo.repository}"
    # }

    # environment_variable {
    #   name = "NPM_REPOSITORY_NAME"
    #   value = "${aws_codeartifact_repository.node_artifact_repo.repository}"
    # }

    # environment_variable {
    #   name = "NPM_REPOSITORY_OWNER"
    #   value = "${aws_codeartifact_domain.nodejs_artifact_domain.owner}"
    # }
    # environment_variable {
    #   name = "NPM_REPOSITORY_DOMAIN"
    #   value = "${aws_codeartifact_domain.nodejs_artifact_domain.domain}"
    # }

    # environment_variable {
    #   name = "NPM_REPOSITORY_REGION"
    #   value = "${data.aws_region.region.name}"
    # }
  }


  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
      group_name = "/aws/codebuild/${var.department}/${var.project-name}-build"
    }
    s3_logs {
      location = "${aws_s3_bucket.bucket-devops.bucket}/${var.department}/${var.project-name}/build/logs"
      status = "ENABLED"
      encryption_disabled = false
    }
  }
}



resource "aws_iam_role" "iam-codebuild-role" {
  name               = "${local.name}-codebuild_role"
  assume_role_policy = data.aws_iam_policy_document.codebuild-assume-role.json
}

data "aws_iam_policy_document" "codebuild-assume-role" {
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

resource "aws_iam_role_policy" "iam-codebuild-policy-attach" {
  name   = "CodeBuildInlinePolicy"
  role   = aws_iam_role.iam-codebuild-role.id
  policy = data.aws_iam_policy_document.codebuild-policy.json
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
      "${aws_s3_bucket.bucket-devops.arn}",
      "${aws_s3_bucket.bucket-devops.arn}/*"
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
      "${aws_cloudwatch_log_group.log_group_codebuild_backend.arn}:*",
      "${aws_cloudwatch_log_group.log_group_codebuild_backend.arn}",
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
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:DeleteRepository",
      "ecr:BatchDeleteImage",
      "ecr:SetRepositoryPolicy",
      "ecr:DeleteRepositoryPolicy",
    ]
    resources = [
      # "${aws_ecr_repository.ecr_repo.arn}",
      "*"
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