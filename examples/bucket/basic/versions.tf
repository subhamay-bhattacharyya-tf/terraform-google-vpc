# -- examples/bucket/basic/versions.tf (Example)
# ============================================================================
# Example: Basic GCS Bucket - Version Requirements
# ============================================================================

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
  project = var.project_id
  region  = var.region
}
