variable "project_id" {
  type = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "The project_id must be a string of alphanumeric or hyphens, between 6 and 3o characters in length."
  }
  description = <<EOD
The GCP project identifier where the secret will be created.
EOD
}

variable "secret_id" {
  type = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,255}$", var.secret_id))
    error_message = "The secret id must be a string of alphanumeric, hyphen, and underscore characters, and upto 255 characters in length."
  }
  description = <<EOD
The secret identifier to create; this value must be unique within the project.
EOD
}

variable "secret_value" {
  type        = string
  sensitive = true
  description = <<EOD
The secret payload to store in Secret Manager; if blank or null a versioned secret
value will NOT be created and must be populated outside of this module. Binary
values should be base64 encoded before use.
EOD
}

variable "accessors" {
  type    = list(string)
  default = []
  ##validation {
  #  condition     = length(join("", [for acct in var.accessors : can(regex("^(?:group|serviceAccount|user):[^@]+@[^@]*$", acct)) ? "x" : ""])) == length(var.accessors)
  #  error_message = "Each accessors value must be a valid IAM account identifier; e.g. user:jdoe@company.com, group:admins@company.com, serviceAccount:service@project.iam.gserviceaccount.com."
  #}
  description = <<EOD
An optional list of IAM account identifiers that will be granted accessor (read-only)
permission to the secret.
EOD
}

variable "admins" {
  type    = list(string)
  default = []
  #validation {
  #  condition     = length(join("", [for acct in var.admins : can(regex("^(?:group|serviceAccount|user):[^@]+@[^@]*$", acct)) ? "x" : ""])) == length(var.admins)
  #  error_message = "Each admin value must be a valid IAM account identifier; e.g. user:jdoe@company.com, group:admins@company.com, serviceAccount:service@project.iam.gserviceaccount.com."
  #}
  description = <<EOD
An optional list of IAM account identifiers that will be granted admin (all permissions)
permission to the secret.
EOD
}

variable "ignore_new_versions" {
  type = bool
  default = true
}