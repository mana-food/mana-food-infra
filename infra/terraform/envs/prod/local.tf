locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }

  # Subnets configuration
  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  vpc_cidr = var.vpc_cidr

  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k + 10)]
  database_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k + 20)]
}