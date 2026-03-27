# -- examples/bucket/basic/variables.tf (Example)
# ============================================================================
# Example: Basic GCS Bucket - Variables
# ============================================================================

variable "bucket_name" {
  description = "Name of the GCS bucket."
  type        = string
  default     = "my-portfolio-bucket"
}

variable "project_id" {
  description = "GCP project ID."
  type        = string
  default     = "portfolio-site"
}

variable "region" {
  description = "GCP region."
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment label value."
  type        = string
  default     = "dev"
}
