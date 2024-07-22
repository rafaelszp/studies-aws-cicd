
resource "aws_codepipeline" "pipeline_vite_example" {
  name = "${var.prefix}-pipeline"
  role_arn = aws_iam_role.code_pipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.bucket_cicd.bucket
    type = "S3"
  }

  stage {
    name = "Source"

    action {
      name = "Source"
      category = "Source"
      owner = "ThirdParty"
      provider = "GitHub"
      version = "2"
      output_artifacts = ["source_output"]

      configuration = {
        OAuthToken = "${var.github_token}"
        Owner = "${var.github_owner}"
        Repo = "${var.github_repository}"
        Branch = "${var.github_branch}"        
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
      version = "2"
      input_artifacts = ["source_output"]
      output_artifacts = ["build_output"]
      configuration = {
        ProjectName = aws_codebuild_project.codebuild_vite_project.name
      }

    }
  }

}