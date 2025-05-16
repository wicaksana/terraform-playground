data "google_client_config" "default" {}

locals {
  vpc_name          = "${var.cluster_name}-vpc"
  subnet_name       = "${var.cluster_name}-subnet1"
  ip_range_services = "${var.cluster_name}-services"
  ip_range_pods     = "${var.cluster_name}-pods"
}

########################
# VPC 
########################

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
########################
# VPC 
########################

resource "google_compute_network" "custom_vpc" {
  project                 = var.gcp_project_id
  name                    = "${var.cluster_name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "custom_vpc_subnet1" {
  name          = "${google_compute_network.custom_vpc.name}-subnet1"
  network       = google_compute_network.custom_vpc.id
  ip_cidr_range = "10.200.0.0/16"
  region        = var.gcp_region
  secondary_ip_range {
    range_name    = local.ip_range_services
    ip_cidr_range = "192.168.1.0/24"
  }
  secondary_ip_range {
    range_name    = local.ip_range_pods
    ip_cidr_range = "192.168.64.0/22"
  }
}

########################
# GKE cluster + node pool
########################

module "gke" {
  source            = "terraform-google-modules/kubernetes-engine/google"
  version           = "36.3.0"
  project_id        = var.gcp_project_id
  name              = var.cluster_name
  region            = var.gcp_region
  network           = google_compute_network.custom_vpc.name
  subnetwork        = google_compute_subnetwork.custom_vpc_subnet1.name
  ip_range_services = local.ip_range_services
  ip_range_pods     = local.ip_range_pods
  deletion_protection = false  # make it easier to destroy.

  node_pools = [
    {
      name                       = "default-node-pool"
      machine_type               = "e2-medium"
      min_count                  = 1
      max_count                  = 3
      local_ssd_count            = 0
      spot                       = false
      disk_size_gb               = 100
      disk_type                  = "pd-standard"
      image_type                 = "COS_CONTAINERD"
      enable_gcfs                = false
      enable_gvnic               = false
      logging_variant            = "DEFAULT"
      auto_repair                = true
      auto_upgrade               = true
      service_account            = google_service_account.default_sa.email
      preemptible                = false
      initial_node_count         = 1
    }
  ]

  depends_on = [google_compute_subnetwork.custom_vpc_subnet1]
}