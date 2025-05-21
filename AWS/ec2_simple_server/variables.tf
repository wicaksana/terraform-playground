variable "region" {
  description = "AWS region"
  default = "us-east-1"
  type = string
}

variable "project_name" {
  description = "Project name; used as tag value"
  default = "simple-ec2-server"
  type = string
}

variable "ami_id" {
  description = "AMI ID"
  default = "ami-0953476d60561c955"  # Amazon Linux 2023 AMI 2023.7.20250512.0 x86_64 HVM kernel-6.1
  type = string
}

variable "instance_type" {
  default = "t2.micro"
  type = string
}

variable "key_name" {
  default = "ssh_key_pair"
  type = string
}