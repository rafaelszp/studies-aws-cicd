locals {
  source_output = "${var.department}-${var.project-name}-source_output"
  build_output = "${var.department}-${var.project-name}-build_output"
  deploy_output = "${var.department}-${var.project-name}-deploy_output"
}


resource "aws_codestarconnections_connection" "codestar-github" {
  provider_type = "GitHub" 
  name = "${var.project-name}-codestar"
}


resource "aws_codepipeline" "pipeline-project" {
  name = "${local.name}-pipeline"
  role_arn = aws_iam_role.code-pipeline-role.arn
  pipeline_type = "V2"
  trigger {
    provider_type = "CodeStarSourceConnection"
    git_configuration {
      source_action_name = "Source"
      push {
        branches {
          includes = var.pipeline-branch-includes
          excludes = var.pipeline-branch-excludes
        }
        file_paths {
          includes = var.pipeline-file-includes
          excludes = var.pipeline-file-excludes
        }
      }
    }
  }

  artifact_store {
    location = aws_s3_bucket.bucket-devops.bucket
    type = "S3"
  }

  stage {
    name = "Source"

    action {
      name = "Source"
      category = "Source"
      owner = "AWS"
      provider = "CodeStarSourceConnection"
      version = "1"
      output_artifacts = ["${local.source_output}"]
      namespace = "SourceVariables"

      configuration = {
        FullRepositoryId = "${var.github-owner}/${var.github-repository}"
        BranchName = "${var.github-branch}"        
        ConnectionArn = aws_codestarconnections_connection.codestar-github.arn
      }
    }
  }
  stage{
    name = "Build"

    action {
      name = "BUILD"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"
      input_artifacts = ["${local.source_output}"]
      output_artifacts = ["${local.build_output}"]
      configuration = {
        ProjectName = aws_codebuild_project.codebuild-builder.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name = "Deploy"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"
      input_artifacts = ["${local.source_output}","${local.build_output}"]
      output_artifacts = ["${local.deploy_output}"]
      configuration = {
        ProjectName = aws_codebuild_project.codebuild-deployer.name
        PrimarySource = "${local.source_output}"
        EnvironmentVariables = jsonencode([
          {
            name = "GITHUB_COMMIT_ID"
            value =  "#{SourceVariables.CommitId}"
            type = "PLAINTEXT"
          },
          {
            name = "GITHUB_BRANCH_NAME"
            value =  "#{SourceVariables.BranchName}"
            type = "PLAINTEXT"
          },
          {
            name = "BUILD_OUTPUT_NAME"
            type = "PLAINTEXT"
            value = "${local.build_output}"
          },
          {
            name = "DEPLOY_OUTPUT_NAME"
            type = "PLAINTEXT"
            value = "${local.deploy_output}"
          }
        ])
      }
    }
  }

  tags = {
    TFName     = "${local.name}-pipiline"
    Department = "${var.department}"
    Application = "${var.project-name}"
  }

}