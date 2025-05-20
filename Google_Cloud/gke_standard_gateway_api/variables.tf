variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-east1"
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
  default     = "gtw-cluster"
}

