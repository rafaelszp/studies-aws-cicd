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

resource "aws_s3_bucket_lifecycle_configuration" "bucket_cicd_lifecycle" {

  bucket = aws_s3_bucket.bucket_cicd.id

  rule {
    id = "${var.prefix}-build-log"
    status = "Enabled"
    expiration {
      days = 30
    }
    filter {
     prefix = "${var.prefix}-logs/"
    }
  }

  rule {
    id = "${var.prefix}-build-cache"
    status = "Enabled"
    expiration {
      days = 365
    }
    filter {
     prefix = "${var.prefix}-buildcache/"
    }
  }

  rule {
    id = "${var.prefix}-pip"
    status = "Enabled"
    expiration {
      days = 3
    }
    filter {
     prefix = "${var.prefix}-pip/"
    }
  }

  rule {
    id = "${var.prefix}/"
    status = "Enabled"
    filter {
     prefix = "${var.prefix}/"
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

# resource "aws_kms_key" "kms_bucket_encryption_key" {
#   description = "Bucket encryption key for ${var.prefix}"
#   deletion_window_in_days = 15

#   tags = {
#     TFName     = "kms_bucket_encryption_key"
#     Department = "${var.department}"
#     Application = "${var.prefix}"
#     Name = "CICD Bucket key"
#   }
# }

# resource "aws_kms_alias" "kms_bucket_key_alias" {
#   name          = "alias/CICD-Bucket-Key"
#   target_key_id = aws_kms_key.kms_bucket_encryption_key.id
# }

data "aws_kms_key" "s3_kms_key" {
  key_id = "alias/aws/s3"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_cicd_server_encryption" {
  bucket = aws_s3_bucket.bucket_cicd.id
  # rule {
  #   apply_server_side_encryption_by_default {
  #     sse_algorithm = "aws:kms"
  #     kms_master_key_id = aws_kms_key.kms_bucket_encryption_key.arn
  #   }
  # }
  # rule {
  #   apply_server_side_encryption_by_default {
  #     sse_algorithm = "AES256"
  #   }
  # }
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
      kms_master_key_id = data.aws_kms_key.s3_kms_key.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.bucket_cicd.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}