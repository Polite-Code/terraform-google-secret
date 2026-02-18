terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.20.0, < 8.0.0"
    }
  }
}

locals {
  has_secret_value = var.secret_value != null && trimspace(var.secret_value) != ""
}

resource "google_project_service" "secretmanager" {
  project            = var.project_id
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_secret_manager_secret" "secret" {
  project   = var.project_id
  secret_id = var.secret_id

  replication {
    dynamic "auto" {
      for_each = length(var.locations) == 0 ? [1] : []
      content {}
    }

    dynamic "user_managed" {
      for_each = length(var.locations) > 0 ? [1] : []
      content {
        dynamic "replicas" {
          for_each = toset(var.locations)
          content {
            location = replicas.value
          }
        }
      }
    }
  }

  depends_on = [
    google_project_service.secretmanager
  ]
}

resource "google_secret_manager_secret_version" "secret" {
  count = local.has_secret_value && !var.ignore_new_versions ? 1 : 0

  secret          = google_secret_manager_secret.secret.id
  secret_data     = var.secret_value
  deletion_policy = "DISABLE"

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_secret_manager_secret_version" "secret_ignored" {
  count = local.has_secret_value && var.ignore_new_versions ? 1 : 0

  secret          = google_secret_manager_secret.secret.id
  secret_data     = var.secret_value
  deletion_policy = "DISABLE"

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [secret_data]
  }
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
