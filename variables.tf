variable "project_id" {
  type = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "The project_id must contain alphanumeric characters or hyphens and be between 6 and 30 characters long."
  }

  description = <<EOD
The GCP project identifier where the secret will be created.
EOD
}

variable "secret_id" {
  type = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,255}$", var.secret_id))
    error_message = "The secret_id must contain alphanumeric, hyphen, and underscore characters, up to 255 characters long."
  }

  description = <<EOD
The secret identifier to create; this value must be unique within the project.
EOD
}

variable "secret_value" {
  type      = string
  default   = null
  nullable  = true
  sensitive = true

  description = <<EOD
The secret payload to store in Secret Manager. If null or blank, a secret version
will NOT be created and must be populated outside this module. Binary values should
be base64-encoded before use.
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
  type    = bool
  default = false

  description = <<EOD
If true, updates to secret_value are ignored after the initial version is created.
If false, updates to secret_value create new secret versions.
EOD
}

variable "locations" {
  type    = list(string)
  default = []

  validation {
    condition     = alltrue([for location in var.locations : trimspace(location) != ""])
    error_message = "Each location must be a non-empty region string."
  }

  description = <<EOD
Optional replication regions for user-managed replication. If empty, replication
defaults to automatic.
EOD
}
