# =============================================================================
# GCP VPC Module - Variables
# =============================================================================

variable "vpc_config" {
  description = "Configuration for the GCP VPC and its subnets. Load from a JSON file at the call site via jsondecode(file(...))."
  type = object({
    name                            = string
    project                         = string
    description                     = optional(string, "")
    auto_create_subnetworks         = optional(bool, false)
    routing_mode                    = optional(string, "REGIONAL")
    delete_default_routes_on_create = optional(bool, false)
    subnets = list(object({
      name                     = string
      region                   = string
      ip_cidr_range            = string
      description              = optional(string, "")
      private_ip_google_access = optional(bool, true)
      secondary_ip_ranges = optional(list(object({
        range_name    = string
        ip_cidr_range = string
      })), [])
    }))
  })

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,61}[a-z0-9]$", var.vpc_config.name))
    error_message = "vpc name must be 2-63 characters, start with a letter, end with a letter or digit, and contain only lowercase letters, digits, and hyphens."
  }

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.vpc_config.project))
    error_message = "project must be a valid GCP project ID (6-30 chars, lowercase letters, digits, hyphens)."
  }

  validation {
    condition     = contains(["REGIONAL", "GLOBAL"], var.vpc_config.routing_mode)
    error_message = "routing_mode must be one of: REGIONAL, GLOBAL."
  }

  validation {
    condition     = length(var.vpc_config.subnets) > 0
    error_message = "At least one subnet must be defined in vpc_config.subnets."
  }

  validation {
    condition     = var.vpc_config.auto_create_subnetworks == false
    error_message = "auto_create_subnetworks must be false when subnets are defined explicitly."
  }

  validation {
    condition = alltrue([
      for s in var.vpc_config.subnets : can(cidrhost(s.ip_cidr_range, 0))
    ])
    error_message = "Each subnet ip_cidr_range must be a valid CIDR notation."
  }

  validation {
    condition = alltrue([
      for s in var.vpc_config.subnets :
      alltrue([for r in s.secondary_ip_ranges : can(cidrhost(r.ip_cidr_range, 0))])
    ])
    error_message = "Each secondary_ip_range ip_cidr_range must be a valid CIDR notation."
  }

  validation {
    condition = alltrue([
      for s in var.vpc_config.subnets : can(regex("^[a-z][a-z0-9-]{0,61}[a-z0-9]$", s.name))
    ])
    error_message = "Each subnet name must match GCP naming rules: 2-63 chars, start with letter, end with letter or digit, lowercase letters/digits/hyphens only."
  }
}
