locals {
  subnets_by_name = { for s in var.vpc_config.subnets : s.name => s }
}
