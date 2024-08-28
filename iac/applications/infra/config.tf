terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.58"
    }
  }
  backend "s3" {
    bucket = "${var.state_bucket}"
    key = "example-01/terraform.tfstate"
    dynamodb_table = "${var.state_table}"
    region = "${variable.region}"
  }
}

provider "aws" {
  region = "${variable.region}"
}