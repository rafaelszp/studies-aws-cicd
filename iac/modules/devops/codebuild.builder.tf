
resource "aws_codebuild_source_credential" "github_token_credential" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = "${var.github-token}"
}


######################################################################
#################### BUILD PROJECT
######################################################################
resource "aws_codebuild_project" "codebuild-builder" {

  name = "${local.name}-build"
  # encryption_key = aws_kms_key.kms_bucket_encryption_key.arn
  encryption_key = data.aws_kms_key.s3_kms_key.arn
  project_visibility = "PRIVATE"

  tags = {
    TFName     = "${local.name}-builder"
    Department = "${var.department}"
    Application = "${var.project-name}"
  }
  
  description = "Build project for ${local.name}"
  build_timeout = var.build-timeout
  service_role = aws_iam_role.iam-codebuild-role.arn


  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type = "S3"
    location = "${aws_s3_bucket.bucket-devops.bucket}/${var.department}/${var.project-name}/build/cache"
  }

  source {
    buildspec = "${var.buildspec-file}"
    type = "${var.source-type}"
  }

  environment {
    compute_type = "${var.codebuild-computer-type}"
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

    environment_variable {
      name = "BUCKET_URL"
      value = "s3://${aws_s3_bucket.bucket-devops.bucket}" 
    }

    environment_variable {
      name = "PROJECT_NAME"
      value = "${local.name}"
    }

    environment_variable {
      name = "REPOSITORY_URL"
      value = "${local.repository-name}"
    }

    environment_variable {
      name = "REPOSITORY_NAME"
      value = "${aws_codeartifact_repository.artifact-repo.repository}"
    }

    environment_variable {
      name = "REPOSITORY_OWNER"
      value = "${aws_codeartifact_domain.artifact-domain.owner}"
    }

    environment_variable {
      name = "REPOSITORY_DOMAIN"
      value = "${aws_codeartifact_domain.artifact-domain.domain}"
    }

    environment_variable {
      name = "REPOSITORY_REGION"
      value = "${data.aws_region.region.name}"
    }

    environment_variable {
      name = "ECR_LOGIN_URL"
      value = "${data.aws_caller_identity.current_caller_id.account_id}.dkr.ecr.${data.aws_region.region.name}.amazonaws.com"
    }

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