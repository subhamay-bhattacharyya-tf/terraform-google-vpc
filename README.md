# Terraform Module for GCS Bucket

![Release](https://github.com/subhamay-bhattacharyya-tf/terraform-google-module-template/actions/workflows/ci.yaml/badge.svg)&nbsp;![GCP](https://img.shields.io/badge/GCP-4285F4?logo=googlecloud&logoColor=white)&nbsp;![Commit Activity](https://img.shields.io/github/commit-activity/t/subhamay-bhattacharyya-tf/terraform-google-module-template)&nbsp;![Last Commit](https://img.shields.io/github/last-commit/subhamay-bhattacharyya-tf/terraform-google-module-template)&nbsp;![Release Date](https://img.shields.io/github/release-date/subhamay-bhattacharyya-tf/terraform-google-module-template)&nbsp;![Repo Size](https://img.shields.io/github/repo-size/subhamay-bhattacharyya-tf/terraform-google-module-template)&nbsp;![File Count](https://img.shields.io/github/directory-file-count/subhamay-bhattacharyya-tf/terraform-google-module-template)&nbsp;![Issues](https://img.shields.io/github/issues/subhamay-bhattacharyya-tf/terraform-google-module-template)&nbsp;![Top Language](https://img.shields.io/github/languages/top/subhamay-bhattacharyya-tf/terraform-google-module-template)&nbsp;![Built with Claude Code](https://img.shields.io/badge/Built%20with-Claude%20Code-623CE4?logo=anthropic&logoColor=white)&nbsp;![Custom Endpoint](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/bsubhamay/476e6e7583432e960e6de16d5223e6a3/raw/terraform-google-module-template.json?)

A Terraform module for creating and managing a **Google Cloud Storage (GCS) bucket** on GCP.

## Overview

This module provisions a single `google_storage_bucket` resource via the `terraform-google-module-template` module. It accepts a small set of flat input variables and assembles the required `gcs_config` object, enforcing `uniform_bucket_level_access = true` and `public_access_prevention = "enforced"` by default.

## Requirements

| Requirement | Version |
|---|---|
| Terraform | >= 1.3.0 |
| Google Provider | >= 7.23.0 |

## Usage

```hcl
module "gcs_bucket" {
  source = "github.com/subhamay-bhattacharyya-tf/terraform-google-module-template"

  bucket_name = "my-portfolio-bucket"
  project_id  = "portfolio-site"
  location    = "US"
  environment = "prod"
}
```

## Input Variables

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| `bucket_name` | Name of the GCS bucket | `string` | — | yes |
| `project_id` | GCP project ID | `string` | `"portfolio-site"` | no |
| `region` | GCP region | `string` | `"us-central1"` | no |
| `location` | GCS bucket location | `string` | `"US"` | no |
| `storage_class` | Storage class | `string` | `"STANDARD"` | no |
| `force_destroy` | Force-destroy bucket on destroy | `bool` | `false` | no |
| `versioning` | Enable object versioning | `bool` | `false` | no |
| `labels` | Additional labels | `map(string)` | `{}` | no |
| `project` | Project label value | `string` | `"portfolio-site"` | no |
| `environment` | Environment label value | `string` | `"dev"` | no |

## Outputs

| Name | Description |
|---|---|
| `bucket_id` | The ID of the GCS bucket |
| `bucket_name` | The name of the GCS bucket |
| `bucket_project` | The project ID where the bucket is created |
| `bucket_location` | The location of the GCS bucket |
| `bucket_url` | The URL of the GCS bucket |
| `bucket_self_link` | The self link of the GCS bucket resource |
| `bucket_storage_class` | The storage class of the GCS bucket |
| `bucket_force_destroy` | Whether force_destroy is enabled |

## CI / Workload Identity Federation Setup

The Terratest job authenticates to GCP via [Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation) (service account impersonation). If the job fails with `Permission 'iam.serviceAccounts.getAccessToken' denied`, grant the WIF pool principal the required IAM binding:

```bash
gcloud iam service-accounts add-iam-policy-binding \
    "sa-17-cloud-storage@prj-17-cloud-storage-16748.iam.gserviceaccount.com" \
    --project="prj-17-cloud-storage-16748" \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/projects/578842011545/locations/global/workloadIdentityPools/github-actions/attribute.repository/subhamay-bhattacharyya-tf/terraform-google-module-template"
```

The three repository variables required by the CI workflow are:

| Variable | Description |
| --- | --- |
| `GCP_PROJECT_ID` | GCP project ID passed as `GOOGLE_CLOUD_PROJECT` to Terratest |
| `GCP_WORKLOAD_IDENTITY_PROVIDER` | Full WIF provider resource name |
| `GCP_SERVICE_ACCOUNT` | Service account email to impersonate |

## License

Apache 2.0 — see [LICENSE](LICENSE).
