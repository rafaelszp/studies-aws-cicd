variable "github-token" {
  type = string
}

variable "retention-days" {
  type = number
  default = 14
}
variable "repository-external-connection-name" {
  type = string
  default = "public:maven-central"
}

variable "repository-type" {
  type = string
  default = "maven"
}