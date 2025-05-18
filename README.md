# terraform-google-secret

This module provisions a Google Secret Manager secret, populates an initial version, and grants IAM access to specified principals.

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:------:|
| `project_id` | The GCP project identifier where the secret will be created. | `string` | n/a | yes |
| `secret_id` | The secret identifier to create; this value must be unique within the project. | `string` | n/a | yes |
| `secret_value` | The secret payload to store in Secret Manager; if blank or null a versioned secret value will **not** be created. Binary values should be base64 encoded before use. | `string` | n/a | yes |
| `accessors` | Optional list of IAM account identifiers that will be granted accessor (read-only) permission to the secret. | `list(string)` | `[]` | no |
| `admins` | Optional list of IAM account identifiers that will be granted admin (all permissions) permission to the secret. | `list(string)` | `[]` | no |
| `ignore_new_versions` | Whether to ignore changes to secret versions created outside this module. | `bool` | `true` | no |
| `locations` | List of locations used for user-managed replication. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| `id` | The fully-qualified id of the Secret Manager key that contains the secret. |
| `secret_id` | The project-local id Secret Manager key that contains the secret. Should match the input `id`. |

## Example

```hcl
module "secret" {
  source       = "./terraform-google-secret"  # adjust path as needed

  project_id   = "my-project"
  secret_id    = "db-password"
  secret_value = "s3cr3t"

  accessors = [
    "user:appuser@example.com"
  ]

  admins = [
    "group:admin@example.com"
  ]

  locations = ["us-central1", "us-east1"]
}
```
