variable "project_name" {
  description = "The name of the application."
  type = string
}

variable "department" {
  description = "The department that the application will belong to."
  type = string 
}

variable "vpc_id" {
  description = "The ID of the VPC that the application will belong to." 
  type = string  
}

variable "apps" {
  description = "The list of applications that will be deployed."
  type = list(object({
    name = string
    port = number
    health_check_path = string
    context_path = string
  }))
}