data "aws_iam_policy_document" "codebuild_assume_role" {
  statement{
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }  
}

data "aws_iam_policy_document" "codebuild_policy" {
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
      "${aws_cloudwatch_log_group.log_group_codebuild.arn}:*"
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
}

resource "aws_iam_role" "iam_codebuild_role" {
 name = "${var.prefix}-codebuild_role" 
 assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
}

resource "aws_iam_role_policy" "iam_codebuild_policy_attach" {
  role = aws_iam_role.iam_codebuild_role.id
  policy = data.aws_iam_policy_document.codebuild_policy.json
}