output "id" {
  value       = google_secret_manager_secret.secret.id
  description = <<EOD
The fully-qualified ID of the Secret Manager secret.
EOD
}

output "secret_id" {
  value       = google_secret_manager_secret.secret.secret_id
  description = <<EOD
The project-local Secret Manager secret ID. Should match the input `secret_id`.
EOD
}
