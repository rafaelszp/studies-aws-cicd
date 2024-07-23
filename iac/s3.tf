locals {
  bucket = "${var.prefix}-${var.cicd_bucket_name}"
}

resource "aws_s3_bucket" "bucket_cicd" {

  bucket = local.bucket
  force_destroy = true

  tags = {
    TFName     = "bucket_cicd"
    Department = "${var.department}"
    Application = "${var.prefix}"
  }

}

resource "aws_kms_key" "kms_bucket_encryption_key" {
  description = "Bucket encryption key for ${var.prefix}"
  deletion_window_in_days = 15

  tags = {
    TFName     = "kms_bucket_encryption_key"
    Department = "${var.department}"
    Application = "${var.prefix}"
    Name = "CICD Bucket key"
  }
}

resource "aws_kms_alias" "kms_bucket_key_alias" {
  name          = "alias/CICD-Bucket-Key"
  target_key_id = aws_kms_key.kms_bucket_encryption_key.id
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_cicd_server_encryption" {
  bucket = aws_s3_bucket.bucket_cicd.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
      kms_master_key_id = aws_kms_key.kms_bucket_encryption_key.arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.bucket_cicd.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}