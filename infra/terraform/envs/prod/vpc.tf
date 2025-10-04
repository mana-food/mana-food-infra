module "vpc" {
  source = "../../modules/vpc"

  name_prefix         = local.name_prefix
  vpc_cidr            = var.vpc_cidr
  availability_zones  = local.azs
  public_subnets      = local.public_subnets
  private_subnets     = local.private_subnets
  database_subnets    = local.database_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = var.environment == "dev" ? true : false
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.common_tags
}