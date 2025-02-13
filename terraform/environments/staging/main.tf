terraform {
  backend "gcs" {
    bucket = "magic-project-ezzy-terraform-state"
    prefix = "terraform/state/staging"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

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
