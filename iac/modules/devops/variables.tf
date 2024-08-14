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

variable "repository-type" {
  type = string
  description = "Ex.: maven, npm" 
}

variable "repository-external-connection-name" {
  type = string
  description = "public:npmjs, public:maven-central"
}

variable "build-timeout" {
  type = number
}

variable "deploy-timeout" {
  type = number
  default = 5
}

variable "buildspec-file" {
  type = string
}

variable "deployspec-file" {
  type = string
}