module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr

  # Subnets usando variáveis
  azs             = var.availability_zones
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  # NAT Gateway para acesso à internet das subnets privadas
  enable_nat_gateway     = true
  single_nat_gateway     = true # Para economia em produção, considere false
  enable_dns_hostnames   = true
  enable_dns_support     = true

  # Tags consistentes
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-vpc"
    "kubernetes.io/cluster/${var.project_name}-eks" = "shared"
  })

  # Tags específicas para subnets públicas (para LoadBalancers)
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/${var.project_name}-eks" = "shared"
  }

  # Tags específicas para subnets privadas (para worker nodes)
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.project_name}-eks" = "owned"
  }
}