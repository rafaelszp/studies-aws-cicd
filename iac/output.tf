
output "bucket_cicd_arn" {
  value = aws_s3_bucket.bucket_cicd.arn
}

output "acc" {
  value = data.aws_caller_identity.current_caller_id
  
}