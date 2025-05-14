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

resource "google_service_account" "test_sa" {
  account_id   = var.sa_id
  display_name = "Test SA"
}

resource "google_project_iam_binding" "test_sa_iam_binding_logwriter" {
  project = var.gcp_project_id
  role    = "roles/logging.logWriter"
  members = [
    "serviceAccount:${google_service_account.test_sa.email}"
  ]
}

resource "google_project_iam_binding" "test_sa_iam_binding_metadatawriter" {
  project = var.gcp_project_id
  role    = "roles/stackdriver.resourceMetadata.writer"
  members = [
    "serviceAccount:${google_service_account.test_sa.email}"
  ]
}

resource "google_project_iam_binding" "test_sa_iam_binding_metricwriter" {
  project = var.gcp_project_id
  role    = "roles/monitoring.metricWriter"
  members = [
    "serviceAccount:${google_service_account.test_sa.email}"
  ]
}