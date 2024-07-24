
output "bucket_cicd_arn" {
  value = aws_s3_bucket.bucket_cicd.arn
}

output "bucket_cicd_name" {
  value = aws_s3_bucket.bucket_cicd.bucket
}

output "account" {
  value = data.aws_caller_identity.current_caller_id
}

output "codebuild_project_arn" {
  value = aws_codebuild_project.codebuild_vite_project.arn
}

output "cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.log_group_codebuild.name
}

# output "kms_key_arn" {
#   value = aws_kms_key.kms_bucket_encryption_key.arn
# }