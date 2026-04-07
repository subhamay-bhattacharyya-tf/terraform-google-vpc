# =============================================================================
# GCP VPC Module - Main
# Creates and manages a google_compute_network (VPC) and one or more
# google_compute_subnetwork resources driven by a single vpc_config object.
# =============================================================================

resource "google_compute_network" "this" {
  name                            = var.vpc_config.name
  project                         = var.vpc_config.project
  description                     = var.vpc_config.description
  auto_create_subnetworks         = var.vpc_config.auto_create_subnetworks
  routing_mode                    = var.vpc_config.routing_mode
  delete_default_routes_on_create = var.vpc_config.delete_default_routes_on_create
}

resource "google_compute_subnetwork" "this" {
  for_each = { for s in var.vpc_config.subnets : s.name => s }

  name                     = each.value.name
  project                  = var.vpc_config.project
  region                   = each.value.region
  network                  = google_compute_network.this.id
  ip_cidr_range            = each.value.ip_cidr_range
  description              = each.value.description
  private_ip_google_access = each.value.private_ip_google_access

  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ip_ranges
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }

  depends_on = [google_compute_network.this]
}
