locals {
  name = "${var.department}-${var.project-name}"
}

resource "aws_s3_bucket" "bucket-devops" {

  bucket = local.name
  force_destroy = true

  tags = {
    Name     = "${local.name}"
    Department = "${var.department}"
    Application = "${var.project-name}"
  }

}

resource "aws_s3_bucket_lifecycle_configuration" "bucket-devops_lifecycle" {

  bucket = aws_s3_bucket.bucket-devops.id

  rule {
    id = "${local.name}-build-log"
    status = "Enabled"
    expiration {
      days = 30
    }
    filter {
     prefix = "${local.name}-logs/"
    }
  }

  rule {
    id = "${local.name}-build-cache"
    status = "Enabled"
    expiration {
      days = 365
    }
    filter {
     prefix = "${local.name}-buildcache/"
    }
  }

  rule {
    id = "${local.name}-pip"
    status = "Enabled"
    expiration {
      days = 3
    }
    filter {
     prefix = "${local.name}-pip/"
    }
  }

  rule {
    id = "${local.name}/"
    status = "Enabled"
    filter {
     prefix = "${local.name}/"
    }

    transition {
      days = 31 #after 15 days the storage class will be changed
      storage_class = "STANDARD_IA"
    }

    transition {
      days = 91 #after 90 days the storage class will be changed
      storage_class = "DEEP_ARCHIVE"
    }
  }


}

data "aws_kms_key" "s3_kms_key" {
  key_id = "alias/aws/s3"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket-devops_server_encryption" {
  bucket = aws_s3_bucket.bucket-devops.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
      kms_master_key_id = data.aws_kms_key.s3_kms_key.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.bucket-devops.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}