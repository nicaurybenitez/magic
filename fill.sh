#!/bin/bash

# Navigate to the project root
cd magic-project

# Populate networking module files
cat << 'EOF' > terraform/modules/networking/main.tf
resource "google_compute_network" "vpc_network" {
  name                    = "magic-vpc-${var.environment}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "magic-subnet-${var.environment}"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc_network.id
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
}
EOF

cat << 'EOF' > terraform/modules/networking/variables.tf
variable "environment" {
  description = "Environment (staging/prod)"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
}
EOF

cat << 'EOF' > terraform/modules/networking/outputs.tf
output "vpc_id" {
  value = google_compute_network.vpc_network.id
}

output "subnet_id" {
  value = google_compute_subnetwork.subnet.id
}
EOF

# Populate cloud_run module files
cat << 'EOF' > terraform/modules/cloud_run/main.tf
resource "google_cloud_run_service" "service" {
  name     = "magic-service-${var.environment}"
  location = var.region

  template {
    spec {
      containers {
        image = var.container_image
        ports {
          container_port = 8080
        }
        resources {
          limits = {
            cpu    = var.cpu_limit
            memory = var.memory_limit
          }
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}
EOF

cat << 'EOF' > terraform/modules/cloud_run/variables.tf
variable "environment" {
  description = "Environment (staging/prod)"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "container_image" {
  description = "Container image to deploy"
  type        = string
}

variable "cpu_limit" {
  description = "CPU limit for Cloud Run service"
  type        = string
  default     = "1000m"
}

variable "memory_limit" {
  description = "Memory limit for Cloud Run service"
  type        = string
  default     = "512Mi"
}
EOF

# Populate environments/prod files
cat << 'EOF' > terraform/environments/prod/main.tf
provider "google" {
  project = var.project_id
  region  = var.region
}

module "networking" {
  source = "../../modules/networking"
  
  environment = "prod"
  region      = var.region
  subnet_cidr = "10.0.0.0/24"
}

module "cloud_run" {
  source = "../../modules/cloud_run"
  
  environment     = "prod"
  region         = var.region
  container_image = var.container_image
  cpu_limit      = "2000m"
  memory_limit   = "1Gi"
}
EOF

cat << 'EOF' > terraform/environments/prod/variables.tf
variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "container_image" {
  description = "Container image to deploy"
  type        = string
}
EOF

cat << 'EOF' > terraform/environments/prod/terraform.tfvars
project_id      = "magic-prod"
region          = "us-central1"
container_image = "gcr.io/magic-prod/api:latest"
EOF

# Create similar files for staging environment with adjusted values
cat << 'EOF' > terraform/environments/staging/main.tf
provider "google" {
  project = var.project_id
  region  = var.region
}

module "networking" {
  source = "../../modules/networking"
  
  environment = "staging"
  region      = var.region
  subnet_cidr = "10.1.0.0/24"
}

module "cloud_run" {
  source = "../../modules/cloud_run"
  
  environment     = "staging"
  region         = var.region
  container_image = var.container_image
  cpu_limit      = "1000m"
  memory_limit   = "512Mi"
}
EOF

cat << 'EOF' > terraform/environments/staging/variables.tf
variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "container_image" {
  description = "Container image to deploy"
  type        = string
}
EOF

cat << 'EOF' > terraform/environments/staging/terraform.tfvars
project_id      = "magic-staging"
region          = "us-central1"
container_image = "gcr.io/magic-staging/api:latest"
EOF

# Populate iam module files with basic structure
cat << 'EOF' > terraform/modules/iam/main.tf
resource "google_project_iam_member" "cloud_run_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "allUsers"
}
EOF

cat << 'EOF' > terraform/modules/iam/variables.tf
variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
}
EOF

cat << 'EOF' > terraform/modules/iam/outputs.tf
# Add outputs as needed
EOF

echo "All Terraform files have been populated with their content!"
