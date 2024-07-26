resource "aws_codebuild_source_credential" "github_token_credential" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = "${var.github_token}"
}
resource "aws_codebuild_project" "codebuild_vite_project" {

  name = "${var.prefix}-build"
  # encryption_key = aws_kms_key.kms_bucket_encryption_key.arn
  encryption_key = data.aws_kms_key.s3_kms_key.arn
  project_visibility = "PRIVATE"

  tags = {
    TFName     = "codebuild_vite_project"
    Department = "${var.department}"
    Application = "${var.prefix}"
  }
  
  description = "Build project for ${var.prefix}"
  build_timeout = 5
  service_role = aws_iam_role.iam_codebuild_role.arn

  # artifacts {
  #   type = "S3"
  #   location = aws_s3_bucket.bucket_cicd.bucket
  #   name = var.prefix
  # }

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type = "S3"
    location = "${aws_s3_bucket.bucket_cicd.bucket}/${var.prefix}-buildcache"
  }

  source {
    # location = "https://github.com/rafaelszp/studies-aws-cicd.git"
    buildspec = "cicd/frontend.buildspec.yml"
    # git_clone_depth = 1
    # type = "GITHUB"
    type = "${var.cicd_source_type}"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode = false
    type = "LINUX_CONTAINER"
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
      group_name = "/aws/codebuild/${var.department}/${var.prefix}-build"
    }
    s3_logs {
      location = "${aws_s3_bucket.bucket_cicd.bucket}/${var.prefix}-logs/build"
      status = "ENABLED"
      encryption_disabled = false
    }
  }
  
}


# resource "aws_codebuild_webhook" "codebuild_vite_project_webook_filter" {
#  project_name = aws_codebuild_project.codebuild_vite_project.name
#  build_type = "BUILD" 
#  filter_group {
#    filter {
#      type = "EVENT"
#      pattern = "PUSH"
#    }
#    filter {
#      type = "FILE_PATH"
#      pattern = "^frontend/.*"
#    }
#  }
# }

####################################################################################################
##### DEPLOY
####################################################################################################

resource "aws_codebuild_project" "codebuild_vite_deploy" {

  name  = "${var.prefix}-deploy"
  encryption_key = data.aws_kms_key.s3_kms_key.arn
  project_visibility = "PRIVATE"
  description = "Deploy project for ${var.prefix}"
  build_timeout = 5
  service_role = aws_iam_role.iam_codebuild_role.arn

  source {
    type = "CODEPIPELINE"
    buildspec = "cicd/deploy-to-s3.buildspec.yml"
  }

  tags = {
    TFName     = "codebuild_vite_deploy"
    Department = "${var.department}"
    Application = "${var.prefix}"
  }
  

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode = false
    type = "LINUX_CONTAINER"

    environment_variable {
      name = "BUCKET_URL"
      value = "s3://${aws_s3_bucket.bucket_cicd.bucket}" 
    }

    environment_variable {
      name = "PROJECT_NAME"
      value = "${var.prefix}"
    }
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
      group_name = "/aws/codebuild/${var.department}/${var.prefix}-deploy"
    }
    s3_logs {
      location = "${aws_s3_bucket.bucket_cicd.bucket}/${var.prefix}-logs/deploy"
      status = "ENABLED"
      encryption_disabled = false
    }
  }

}