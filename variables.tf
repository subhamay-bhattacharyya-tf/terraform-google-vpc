# ============================================================================
# GCS Bucket - Variables
# ============================================================================

variable "bucket_name" {
  description = "Name of the GCS bucket."
  type        = string
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

variable "location" {
  description = "GCS bucket location."
  type        = string
  default     = "US"
}

variable "storage_class" {
  description = "Storage class for the bucket."
  type        = string
  default     = "STANDARD"
}

variable "force_destroy" {
  description = "Whether to force-destroy the bucket on Terraform destroy."
  type        = bool
  default     = false
}

variable "versioning" {
  description = "Whether to enable object versioning."
  type        = bool
  default     = false
}

variable "labels" {
  description = "Additional labels to apply to the bucket."
  type        = map(string)
  default     = {}
}

variable "project" {
  description = "Project label value."
  type        = string
  default     = "portfolio-site"
}

variable "environment" {
  description = "Environment label value."
  type        = string
  default     = "dev"
}
