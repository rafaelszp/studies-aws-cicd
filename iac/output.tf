
output "bucket_cicd_arn" {
  value = aws_s3_bucket.bucket_cicd.arn
}

output "bucket_cicd_name" {
  value = aws_s3_bucket.bucket_cicd.bucket
}

output "account" {
  value = data.aws_caller_identity.current_caller_id
}

output "build_project_arn" {
  value = aws_codebuild_project.codebuild_vite_project.arn
}
output "deploy_s3_project_arn" {
  value = aws_codebuild_project.codebuild_vite_deploy.arn
}

output "log_group_build" {
  value = aws_cloudwatch_log_group.log_group_codebuild.name
}
output "log_group_deploy" {
  value = aws_cloudwatch_log_group.log_group_codebuild_deploy.name
}

output "kms_key_arn" {
  value = data.aws_kms_key.s3_kms_key.arn
}

output "repository_domain" {
  value = aws_codeartifact_domain.nodejs_artifact_domain
}

output "repository_nodejs" {
  value = aws_codeartifact_repository.node_artifact_repo
}

output "ecr_repository_url" {
  value = "${aws_ecr_repository.ecr_repo.repository_url}"
}