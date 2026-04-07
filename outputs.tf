# =============================================================================
# GCP VPC Module - Outputs
# =============================================================================

output "vpc_id" {
  description = "Fully-qualified resource ID of the VPC."
  value       = google_compute_network.this.id
}

output "vpc_name" {
  description = "Name of the VPC."
  value       = google_compute_network.this.name
}

output "vpc_self_link" {
  description = "Self-link URI of the VPC."
  value       = google_compute_network.this.self_link
}

output "vpc_gateway_ipv4" {
  description = "Gateway IPv4 address assigned to the VPC."
  value       = google_compute_network.this.gateway_ipv4
}

output "subnets" {
  description = "List of subnet objects — each containing id, name, self_link, region, ip_cidr_range, gateway_address."
  value = [
    for s in values(google_compute_subnetwork.this) : {
      id              = s.id
      name            = s.name
      self_link       = s.self_link
      region          = s.region
      ip_cidr_range   = s.ip_cidr_range
      gateway_address = s.gateway_address
    }
  ]
}
