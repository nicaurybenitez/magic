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
