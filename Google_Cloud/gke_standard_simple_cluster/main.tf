terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.33.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

resource "google_service_account" "default_sa" {
  account_id   = "default-sa-id"
  display_name = "GKE SA - main cluster"
}

resource "google_container_cluster" "main_cluster" {
  name                     = var.cluster_name
  location                 = var.gcp_region
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false # just to make it simpler to destroy later.
  monitoring_config {
    managed_prometheus {
      enabled = true
    }
  }
}

resource "google_container_node_pool" "main_cluster_preemptible_node" {
  name       = "main-cluster-node-pool"
  location   = var.gcp_region
  cluster    = google_container_cluster.main_cluster.name
  node_count = 1

  node_config {
    preemptible     = true
    machine_type    = "e2-medium"
    service_account = google_service_account.default_sa.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}