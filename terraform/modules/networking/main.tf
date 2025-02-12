# modules/networking/main.tf
resource "google_compute_network" "vpc_network" {
  name                    = "magic-vpc-${var.environment}"
  auto_create_subnetworks = false

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_subnetwork" "subnet" {
  name          = "magic-subnet-${var.environment}"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc_network.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http-${var.environment}"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]

  lifecycle {
    create_before_destroy = true
  }
}