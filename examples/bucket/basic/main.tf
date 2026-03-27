# -- examples/bucket/basic/main.tf (Example)
# ============================================================================
# Example: Basic GCS Bucket
# ============================================================================

module "gcs_bucket" {
  source = "../../.."

  bucket_name   = "my-portfolio-bucket"
  project_id    = "portfolio-site"
  location      = "US"
  storage_class = "STANDARD"
  force_destroy = false
  versioning    = false
  project       = "portfolio-site"
  environment   = "dev"
  labels = {
    managed-by = "terraform"
  }
}
