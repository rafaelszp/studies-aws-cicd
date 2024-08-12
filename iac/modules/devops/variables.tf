variable "department" {
  type = string
}

variable "project-name" {
 type = string 
}

variable "region" {
 type = string 
}

variable "github-token" {
  type = string
}

variable "source-type" {
  type = string
  default = "CODEPIPELINE"
}

variable "codebuild-computer-type" {
  type = string
  default = "BUILD_GENERAL1_SMALL"
}

variable "codebuild-image"{
  type = string
  default = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"

}

variable "codebuild-variables"{
  type = list(object({
    name = string
    value = string
  }))
}

variable "retention-days" {
  type = number
}
  
}