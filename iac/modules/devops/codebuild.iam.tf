
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

data "aws_iam_policy_document" "codebuild-policy" {
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
      "${aws_cloudwatch_log_group.log-group-codebuild-build.arn}",
      "${aws_cloudwatch_log_group.log-group-codebuild-deploy.arn}",
      "${aws_cloudwatch_log_group.log-group-codebuild-build.arn}:*",
      "${aws_cloudwatch_log_group.log-group-codebuild-deploy.arn}:*",
    ]
  }
  statement {
    effect = "Allow"
    resources = [
      "arn:aws:s3:::codepipeline-${data.aws_region.region.name}-*"
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
      "arn:aws:codebuild:${data.aws_region.region.name}:${data.aws_caller_identity.current_caller_id.account_id}:report-group/${local.name}-*"
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
      "arn:aws:codeartifact:${data.aws_region.region.name}:${data.aws_caller_identity.current_caller_id.account_id}:domain/${aws_codeartifact_domain.artifact-domain.domain}",
      "arn:aws:codeartifact:${data.aws_region.region.name}:${data.aws_caller_identity.current_caller_id.account_id}:repository/${aws_codeartifact_domain.artifact-domain.domain}/*",
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
      "*"
    ]
  }

  statement {
    effect = "Allow"
    sid = "AllowCodeBuildToReadSSM"
    actions = [
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
    ]
    resources = [
      "${aws_ssm_parameter.secret.arn}",
      "arn:aws:ssm:${data.aws_region.region.name}:${data.aws_caller_identity.current_caller_id.account_id}:*"
    ]
  }
}

data "template_file" "codebuild_ecs_update_template" {
  template = file("${path.module}/templates/codebuild_ecs_update.tpl")
  vars = {
    region = data.aws_region.region.name
    account_id = data.aws_caller_identity.current_caller_id.account_id
    task_execution_role_name = "${var.department}_ECSTaskRole"
  }
}

resource "aws_iam_policy" "codebuild_ecs_update_policy" {
  name = "${var.department}_CodeBuildECSPolicy"
  policy = data.template_file.codebuild_ecs_update_template.rendered
}

resource "aws_iam_role_policy_attachment" "codebuild_ecs_update_policy" {
  role = aws_iam_role.iam-codebuild-role.name
  policy_arn = aws_iam_policy.codebuild_ecs_update_policy.arn
}
