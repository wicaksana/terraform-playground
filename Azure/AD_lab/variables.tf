variable "project_name" {
  description = "Project name"
  type        = string
  default     = "ad-lab"
}

variable "region" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "admin" {
  description = "Username for admin"
  type        = string
}

variable "password" {
  description = "Password for admin"
  type        = string
  sensitive   = true
}