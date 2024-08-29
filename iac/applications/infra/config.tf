terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.58"
    }
  }
  backend "s3" {}
}

provider "aws" {
  region = "us-east-2"
}