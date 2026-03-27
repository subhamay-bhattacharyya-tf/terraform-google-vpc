# ============================================================================
# GCS Bucket Module - Main
# Creates and manages a Google Cloud Storage bucket.
# ============================================================================

resource "google_storage_bucket" "this" {
  name                        = var.bucket_name
  project                     = var.project_id
  location                    = var.location
  storage_class               = upper(var.storage_class)
  force_destroy               = var.force_destroy
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  labels = merge(var.labels, {
    project     = var.project
    environment = var.environment
  })

  versioning {
    enabled = var.versioning
  }
}
