# -- examples/bucket/basic/outputs.tf (Example)
# ============================================================================
# Example: Basic GCS Bucket - Outputs
# ============================================================================

output "bucket_id" {
  description = "The ID of the bucket"
  value       = module.gcs_bucket.bucket_id
}

output "bucket_name" {
  description = "The name of the bucket"
  value       = module.gcs_bucket.bucket_name
}

output "bucket_project" {
  description = "The project ID where the bucket is created"
  value       = module.gcs_bucket.bucket_project
}

output "bucket_location" {
  description = "The location of the bucket"
  value       = module.gcs_bucket.bucket_location
}

output "bucket_url" {
  description = "The URL of the bucket"
  value       = module.gcs_bucket.bucket_url
}

output "bucket_self_link" {
  description = "The self link of the bucket"
  value       = module.gcs_bucket.bucket_self_link
}

output "bucket_storage_class" {
  description = "The storage class of the bucket"
  value       = module.gcs_bucket.bucket_storage_class
}

output "bucket_force_destroy" {
  description = "Whether force_destroy is enabled for the bucket"
  value       = module.gcs_bucket.bucket_force_destroy
}