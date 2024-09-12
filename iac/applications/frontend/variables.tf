variable "github-token" {
  type = string
}

variable "retention-days" {
  type = number
  default = 14
}
variable "repository-external-connection-name" {
  type = string
  default = "public:npmjs"
}

variable "repository-type" {
  type = string
  default = "npm"
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

variable "application-secret"{
  type = object({
    name = string
    value = string
    description = string
  })
}

variable "ecs-cluster-id" {
  type = string  
}

variable "ecs-service-arn" {
  type = string
}

