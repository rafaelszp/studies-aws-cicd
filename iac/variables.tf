data "aws_caller_identity" "current_caller_id" {}
data "aws_region" "region" {}

variable "prefix" {
 type = string 
}

variable "department" {
  type = string
}

variable "cicd_bucket_name" {
  type = string
}