variable "department" {
  type = string
}

variable "project-name" {
 type = string 
 validation {
  condition = length(var.project-name) > 0 && length(var.project-name) < 33
  error_message = "Length of project-name must be between 1 and 32 characters"
 }
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
  validation {
    condition = can(regex("CODEPIPELINE|GITHUB", var.source-type))
    error_message = "source-type must be CODEPIPELINE or GITHUB"
  }
}

variable "codebuild-computer-type" {
  type = string
  default = "BUILD_GENERAL1_SMALL"
  validation {
    condition = can(regex("BUILD_GENERAL1_SMALL|BUILD_GENERAL1_MEDIUM|BUILD_GENERAL1_LARGE", var.codebuild-computer-type))
    error_message = "codebuild-computer-type must be BUILD_GENERAL1_SMALL, BUILD_GENERAL1_MEDIUM or BUILD_GENERAL1_LARGE"
  }
}

variable "codebuild-image"{
  type = string
  default = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  validation {
    condition = can(regex("aws/codebuild/amazonlinux2-x86_64-standard:5.0|aws/codebuild/amazonlinux2-x86_64-standard:3.0", var.codebuild-image))
    error_message = "codebuild-image must be aws/codebuild/amazonlinux2-x86_64-standard:5.0 or aws/codebuild/amazonlinux2-x86_64-standard:3.0"
  }

}

variable "codebuild-variables"{
  type = list(object({
    name = string
    value = string
  }))
}

variable "retention-days" {
  type = number
  validation {
    condition = can(regex("^[0-9]+$", var.retention-days))
    error_message = "retention-days must be a number"
  }
}

variable "repository-type" {
  type = string
  description = "Ex.: maven, npm" 
  validation {
    condition = can(regex("maven|npm", var.repository-type))
    error_message = "repository-type must be maven or npm" 
  }
}

variable "repository-external-connection-name" {
  type = string
  description = "public:npmjs, public:maven-central"
  validation {
    condition = can(regex("public:npmjs|public:maven-central", var.repository-external-connection-name))
    error_message = "repository-external-connection-name must be public:npmjs or public:maven-central"
  }
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

variable "github-owner" {
  type = string
}

variable "github-repository" {
  type = string
}

variable "github-branch" {
  type = string
}

variable "pipeline-file-includes" {
  type = list(string)
  description = "List of file-paths to watch modifications in the source of the pipeline"
  nullable = false
}

variable "pipeline-file-excludes" {
  type = list(string)
  description = "List of file-paths to ignore modifications in the source of the pipeline"
  default = null
  nullable = true
}

variable "pipeline-branch-includes" {
 type = list(string)
  description = "List of branches to watch modifications in the source of the pipeline"
  default = [ "master", "main","release-*" ]
}

variable "pipeline-branch-excludes" {
 type = list(string)
  description = "List of branches to ignore modifications in the source of the pipeline"
  default = [ "dev-*", "staging-*" ]
}