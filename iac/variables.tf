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


variable "cicd_source_type" {
 type = string 
 default = "CODEPIPELINE"
 #value = "GITHUB"
}

variable "github_token" {
  type = string
}

variable "github_owner" {
  type = string
}

variable "github_repository" {
 type = string 
}

variable "github_branch" {
  type = string
}