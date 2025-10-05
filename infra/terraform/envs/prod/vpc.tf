module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "${var.project_name}-vpc"
  cidr = "10.0.0.0/16"

  # Subnets Públicas (para Load Balancers, NAT Gateway)
  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  # Subnets Privadas (para EKS Worker Nodes, Aurora)
  private_subnets = ["10.0.10.0/24", "10.0.11.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true # Para simplicidade, use apenas um NAT Gateway
  enable_dns_hostnames   = true
  enable_dns_support     = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}