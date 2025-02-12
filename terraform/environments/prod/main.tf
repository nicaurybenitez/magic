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
