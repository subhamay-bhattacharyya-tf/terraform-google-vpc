# Terraform Template Specification

Generate these files in the `/` directory:

**main.tf:**

- GCS bucket using the `terraform-google-module-template` module (source: `github.com/subhamay-bhattacharyya-tf/terraform-google-module-template`)
- Pass a `gcs_config` object with:
  - `bucket_name`: from variable
  - `project_id`: from variable
  - `location`: from variable (default `"US"`)
  - `storage_class`: from variable (default `"STANDARD"`)
  - `force_destroy`: from variable (default `false`)
  - `uniform_bucket_level_access`: `true`
  - `public_access_prevention`: `"enforced"`
  - `versioning`: from variable (default `false`)
  - `labels`: map including `project` and `environment` variables

**variables.tf:**

- Variables for: GCS Configuration (gcs_config) which is an object type variable

**outputs.tf:**

- Outputs for all standard GCS bucket attributes:
  - `bucket_id`
  - `bucket_name`
  - `bucket_project`
  - `bucket_location`
  - `bucket_url`
  - `bucket_self_link`
  - `bucket_storage_class`
  - `bucket_force_destroy`

**versions.tf:**

- Versions.tf should be in the following format 

```hcl

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.23.0"
    }
  }
}

provider "google" {
  region = var.region
}
```

**examples/:**

- `examples/bucket/basic/` with a main.tf that references the root module and passes example values for all variables. This should be a working example that can be validated separately from the root module.

**test/:**

This folder should contain the test cases for the module. The test cases should be written in Go and should use the Terratest framework. The test cases should be able to create a real GCS bucket, assert the outputs, and destroy the bucket after the test is done.

**package.json:**

Ensure the name is always the repository name.

**package-lock.json:**

Ensure the name is always the repository name.

**CONTRIBUTING.md:**

Ensure in the CONTRIBUTING.md, Reporting Issues must always links to the current repository.

**README.md:**

The custom endpoint batch should always point to the `current repository`.json.
