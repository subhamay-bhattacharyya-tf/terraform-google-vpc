# GCS Bucket - Basic Example

Creates a Google Cloud Storage bucket with optional versioning, labels, public access prevention, and storage class configuration.

## Source

```hcl
module "gcs_bucket" {
  source = "../../.."

  gcs_config = merge(var.gcs, {
    project_id = coalesce(var.gcs.project_id, var.project_id)
  })
}
```

## Usage

```bash
# Initialize
terraform init

# Plan
terraform plan \
  -var='project_id=my-gcp-project' \
  -var='gcs={"bucket_name":"my-gcs-bucket-123","location":"US","versioning":true}'

# Apply
terraform apply \
  -var='project_id=my-gcp-project' \
  -var='gcs={"bucket_name":"my-gcs-bucket-123","location":"US","versioning":true}'
```

## Inputs

| Name       | Description                    | Type   | Default |
| ---------- | ------------------------------ | ------ | ------- |
| project_id | Google Cloud project ID        | string | -       |
| gcs        | GCS bucket configuration object| object | -       |

### gcs Object

| Property                    | Type        | Default  | Description                                                        |
| --------------------------- | ----------- | -------- | ------------------------------------------------------------------ |
| bucket_name                 | string      | -        | Name of the GCS bucket (required)                                  |
| project_id                  | string      | null     | Optional project override (falls back to top-level project_id)     |
| location                    | string      | US       | Bucket location                                                    |
| storage_class               | string      | STANDARD | Bucket storage class                                               |
| force_destroy               | bool        | false    | Delete bucket even if it contains objects                          |
| uniform_bucket_level_access | bool        | true     | Enable uniform bucket-level access                                 |
| public_access_prevention    | string      | enforced | Public access prevention mode                                      |
| versioning                  | bool        | false    | Enable object versioning                                           |
| labels                      | map(string) | {}       | Labels to apply to the bucket                                      |

## Outputs

| Name             | Description                              |
| ---------------- | ---------------------------------------- |
| bucket_id        | The ID of the bucket                     |
| bucket_name      | The name of the bucket                   |
| bucket_project   | The project ID where the bucket is created |
| bucket_location  | The location of the bucket               |
| bucket_url       | The URL of the bucket                    |
| bucket_self_link | The self link of the bucket              |

## Requirements

- Terraform >= 1.3.0
- Google provider >= 7.23.0