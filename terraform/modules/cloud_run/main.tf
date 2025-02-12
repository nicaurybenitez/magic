# modules/cloud_run/main.tf
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

  lifecycle {
    create_before_destroy = true
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# IAM policy for Cloud Run service
resource "google_cloud_run_service_iam_member" "public_access" {
  service  = google_cloud_run_service.service.name
  location = google_cloud_run_service.service.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}