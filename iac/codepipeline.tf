
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
          includes = ["frontend/**/*.*"]
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
      name = "Build"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"
      input_artifacts = ["source_output"]
      output_artifacts = ["build_output"]
      configuration = {
        ProjectName = aws_codebuild_project.codebuild_vite_project.name
      }

    }
  }

}