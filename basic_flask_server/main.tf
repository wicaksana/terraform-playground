# Following this tutorial https://cloud.google.com/docs/terraform/get-started-with-terraform

resource "google_compute_network" "vpc_network" {
    name                    = "my-custom-mode-network"
    auto_create_subnetworks = false
    mtu                     = 1460
}

resource "google_compute_subnetwork" "default" {
    name                    = "my-custom-subnet"
    ip_cidr_range           = "10.0.1.0/24"
    region                  = "us-west1"
    network                 = google_compute_network.vpc_network.id
}

# create a single GCE instance
resource "google_compute_instance" "default" {
    name                    = "flask-vm"
    machine_type            = "f1-micro"
    zone                    = "us-west1-a"
    tags                    = ["ssh"]
    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-11"
        }
    }

    shielded_instance_config {
        enable_secure_boot = true
        enable_vtpm = true
        enable_integrity_monitoring = true
    }

    # install Flask
    metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python3-pip rsync; pip install flask"
    network_interface {
        subnetwork = google_compute_subnetwork.default.id
        access_config {
        # external access
        }
    }
}