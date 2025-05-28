variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name; used as tag value"
  default     = "monitored-server"
  type        = string
}
