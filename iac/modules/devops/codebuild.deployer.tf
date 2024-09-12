######################################################################
#################### DEPLOY PROJECT
######################################################################
resource "aws_codebuild_project" "codebuild-deployer" {

  name  = "${local.name}-deploy"
  encryption_key = data.aws_kms_key.s3_kms_key.arn
  project_visibility = "PRIVATE"
  description = "Deploy project for ${local.name}"
  build_timeout = var.deploy-timeout
  service_role = aws_iam_role.iam-codebuild-role.arn

  source {
    type = "CODEPIPELINE"
    buildspec = "${var.deployspec-file}"
  }

  tags = {
    TFName     = "${local.name}-deployer"
    Department = "${var.department}"
    Application = "${var.project-name}"
  }
  

  artifacts {
    type = "CODEPIPELINE"
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
      name = "ECR_REPOSITORY_URL"
      value = "${aws_ecr_repository.ecr-repo.repository_url}"
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
    environment_variable {
      name = "ECS_TASK_ROLE_ARN"
      value = "arn:aws:iam:${data.aws_caller_identity.current_caller_id.account_id}:role/${var.department}_ECSTaskRole"
    }
    environment_variable {
      name = "ECS_CLUSTER_ID"
      value = "${var.ecs-cluster-id}"
    }
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
      group_name = "/aws/codebuild/${var.department}/${var.project-name}-deploy"
    }
    s3_logs {
      location = "${aws_s3_bucket.bucket-devops.bucket}/${var.department}/${var.project-name}/deploy/logs"
      status = "ENABLED"
      encryption_disabled = false
    }
  }

}
