locals {
  vpc_config = jsondecode(file("${path.module}/vpc_config.json"))
}

module "vpc" {
  source = "../../../"

  vpc_config = local.vpc_config
}
