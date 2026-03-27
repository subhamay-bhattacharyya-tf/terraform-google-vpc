# ============================================================================
# GCS Bucket Module - Outputs
# ============================================================================

output "bucket_id" {
  description = "The ID of the GCS bucket."
  value       = google_storage_bucket.this.id
}

output "bucket_name" {
  description = "The name of the GCS bucket."
  value       = google_storage_bucket.this.name
}

output "bucket_project" {
  description = "The project ID where the bucket is created."
  value       = google_storage_bucket.this.project
}

output "bucket_location" {
  description = "The location of the GCS bucket."
  value       = google_storage_bucket.this.location
}

output "bucket_url" {
  description = "The URL of the GCS bucket."
  value       = google_storage_bucket.this.url
}

output "bucket_self_link" {
  description = "The self link of the GCS bucket resource."
  value       = google_storage_bucket.this.self_link
}

output "bucket_storage_class" {
  description = "The storage class of the GCS bucket."
  value       = google_storage_bucket.this.storage_class
}

output "bucket_force_destroy" {
  description = "Whether force_destroy is enabled for the GCS bucket."
  value       = google_storage_bucket.this.force_destroy
}
