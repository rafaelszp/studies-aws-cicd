variable "region" {
  description = "The region that the application will be deployed to."
  type = string
  default = "us-east-2"
}

variable "state_bucket" {
  description = "The name of the S3 bucket that will store the state file."
  type = string
}

variable "state_table" {
  description = "The name of the DynamoDB table that will store the state lock."
  type = string
}

variable "vpc_id" {
  description = "The ID of the VPC that the application will belong to."
  type = string  
}