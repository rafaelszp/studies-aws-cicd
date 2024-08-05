
resource "aws_codestarconnections_connection" "codestar_github" {
  provider_type = "GitHub" 
  name = "${var.prefix}-codestar"
}


resource "aws_codepipeline" "pipeline_vite_example" {
  name = "${var.prefix}-pipeline"
  role_arn = aws_iam_role.code_pipeline_role.arn
  pipeline_type = "V2"
  trigger {
    provider_type = "CodeStarSourceConnection"
    git_configuration {
      source_action_name = "Source"
      push {
        branches {
          includes = ["master","main"]
          excludes = ["dev-.*"]
        }
        file_paths {
          includes = ["frontend/**/*","frontend/*","error_pages/**/*"]
        }
      }
    }
  }

  artifact_store {
    location = aws_s3_bucket.bucket_cicd.bucket
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
      output_artifacts = ["source_output"]
      namespace = "SourceVariables"

      configuration = {
        FullRepositoryId = "${var.github_owner}/${var.github_repository}"
        BranchName = "${var.github_branch}"        
        ConnectionArn = aws_codestarconnections_connection.codestar_github.arn
      }

    }
    
  }
  stage{
    name = "Build"

    action {
      name = "FRONTEND-BUILD"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"
      input_artifacts = ["source_output"]
      output_artifacts = ["frontend_build_output"]
      configuration = {
        ProjectName = aws_codebuild_project.codebuild_vite_project.name
      }
    }
    action {
      name = "BACKEND-BUILD"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"
      input_artifacts = ["source_output"]
      output_artifacts = ["backend_build_output"]
      configuration = {
        ProjectName = aws_codebuild_project.codebuild_backend.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name = "DeployToS3"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"
      input_artifacts = ["frontend_build_output","backend_build_output"]
      output_artifacts = ["deploy_to_s3_output"]
      configuration = {
        ProjectName = aws_codebuild_project.codebuild_vite_deploy.name
        PrimarySource = "Source"
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
          }
        ])
      }

    }
  }

  tags = {
    TFName     = "pipeline_vite_example"
    Department = "${var.department}"
    Application = "${var.prefix}"
  }

}