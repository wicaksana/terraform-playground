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

###########################################################
# Service account & IAM roles
###########################################################
resource "google_service_account" "default_sa" {
  account_id   = "default-sa"
  display_name = "GKE SA - ${var.cluster_name}"
}

resource "google_project_iam_binding" "default_sa_iam_binding_logwriter" {
  project = var.gcp_project_id
  role    = "roles/logging.logWriter"
  members = [
    "serviceAccount:${google_service_account.default_sa.email}"
  ]
}

resource "google_project_iam_binding" "default_sa_iam_binding_metadatawriter" {
  project = var.gcp_project_id
  role    = "roles/stackdriver.resourceMetadata.writer"
  members = [
    "serviceAccount:${google_service_account.default_sa.email}"
  ]
}

resource "google_project_iam_binding" "default_sa_iam_binding_metricwriter" {
  project = var.gcp_project_id
  role    = "roles/monitoring.metricWriter"
  members = [
    "serviceAccount:${google_service_account.default_sa.email}"
  ]
}

###########################################################
# New VPC network and subnet(s)
###########################################################
resource "google_compute_network" "custom_vpc" {
  project = var.gcp_project_id
  name = "${var.cluster_name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "custom_vpc_subnet1" {
  name = "${google_compute_network.custom_vpc.name}-subnet1"
  network = google_compute_network.custom_vpc.id
  ip_cidr_range = "10.200.0.0/16"
  region = var.gcp_region
  secondary_ip_range {
    range_name = "services-range"
    ip_cidr_range = "192.168.1.0/24"
  }
  secondary_ip_range {
    range_name = "pod-ranges"
    ip_cidr_range = "192.168.64.0/22"
  }
}
###########################################################
# GKE cluster & node pool
###########################################################

resource "google_container_cluster" "main_cluster" {
  name                     = var.cluster_name
  location                 = var.gcp_region
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false # just to make it simpler to destroy later.
  
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
    managed_prometheus {
      enabled = true
    }
  }
  
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  network = google_compute_network.custom_vpc.id
  subnetwork = google_compute_subnetwork.custom_vpc_subnet1.id

  ip_allocation_policy {
    cluster_secondary_range_name = "pod-ranges"
    services_secondary_range_name = "services-range" 
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