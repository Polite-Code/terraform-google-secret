terraform {
  required_providers {
    google = ">= 4.8"
  }
}

resource "google_project_service" "secretmanager" {
  service = "secretmanager.googleapis.com"
}

resource "google_secret_manager_secret" "secret" {
  project = var.project_id
  secret_id = var.secret_id


  replication {
    user_managed {
      dynamic "replicas" {
        for_each = var.locations
        content {
          location = replicas.value
        }
      }
    }
  }

  depends_on = [
    google_project_service.secretmanager
  ]
}

resource "google_secret_manager_secret_version" "secret" {
  secret      = google_secret_manager_secret.secret.id
  secret_data = var.secret_value

  lifecycle {
    ignore_changes =  all  # TODO: conditonal
  }

  depends_on = [
    google_project_service.secretmanager
  ]
}

resource "google_secret_manager_secret_iam_member" "secret" {
  for_each  = toset(var.accessors)
  project   = var.project_id
  secret_id = google_secret_manager_secret.secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = each.value
}

resource "google_secret_manager_secret_iam_member" "secret_admins" {
  for_each  = toset(var.admins)
  project   = var.project_id
  secret_id = google_secret_manager_secret.secret.secret_id
  role      = "roles/secretmanager.admin"
  member    = each.value
}

# TODO: add other types