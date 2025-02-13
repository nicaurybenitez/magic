resource "google_cloud_run_service" "web" {
  name     = "magic-web-${var.environment}"
  location = var.region

  template {
    spec {
      containers {
        image = var.container_image
        ports {
          container_port = 80
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

resource "google_cloud_run_service_iam_member" "public_access" {
  service  = google_cloud_run_service.web.name
  location = google_cloud_run_service.web.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}