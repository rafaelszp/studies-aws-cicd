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
  type = map(object({
    name = string
    port = number
    health_check_path = string
    context_path = string
    desired_count = number
    launch_type = string
    image = string
    cpu = number #int millicores units
    memory = number #int MiB units
    start_delay = number #int in seconds
    default = bool
    priority = number
  }))
}

variable "retention_days" {
  description = "The number of days to retain the logs."
  type = number
}


variable "environment_name" {
  type = string
  default = "production"  
}