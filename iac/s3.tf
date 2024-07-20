locals {
  bucket = "${var.prefix}-${var.cicd_bucket_name}"
}


resource "aws_s3_bucket" "bucket_cicd" {

  bucket = local.bucket

  tags = {
    TFName     = "bucket_cicd"
    Department = "${var.department}"
    Application = "${var.prefix}"
  }

}