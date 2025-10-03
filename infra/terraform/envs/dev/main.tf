terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "manafood-terraform-tfstate"     # nome do bucket que você criou
    key            = "manafood-terraform.tfstate"     # caminho do arquivo no bucket
    region         = "us-east-1"                      # região do bucket
    dynamodb_table = "manafood-terraform-locks"       # tabela para lock
    encrypt        = true                             # criptografa o estado no S3
  }
}

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = module.eks.eks_endpoint
  cluster_ca_certificate = base64decode(module.eks.eks_certificate)
  token                  = data.aws_eks_cluster_auth.eks.token
}

# # VPC
# module "vpc" {
#   source = "../../modules/eks"
#   name   = "vpc-dev"
#   subnets = var.subnets
# }
#
# VPC
module "vpc" {
  source             = "../../modules/vpc"
  name               = "dev-vpc"
  cidr_block         = "10.0.0.0/16"
  subnets            = var.subnets
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b"]
}

# EKS
module "eks" {
  source           = "../../modules/eks"
  cluster_name     = "dev-eks-cluster"
  cluster_role_arn = var.eks_cluster_role_arn
  node_role_arn    = var.eks_node_role_arn
  subnet_ids       = module.vpc.public_subnet_ids
  # subnets = var.subnets
}

# API Gateway
module "api_gateway" {
  source      = "../../modules/gateway"
  name        = "dev-api"
  path_part   = "hello"
  description = "API para ambiente dev"
}

# Lambda
module "lambda" {
  source   = "../../modules/lambda"
  name     = "meu-lambda-dev"
  runtime  = "python3.9"
  handler  = "index.handler"
  filename = "lambda.zip"
}

# Aurora
module "aurora" {
  source             = "../../modules/aurora"
  cluster_identifier = "aurora-dev"
  db_username        = var.db_username
  db_password        = var.db_password
  subnet_ids         = module.vpc.public_subnet_ids
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  instance_count     = 1
  instance_class     = "db.t3.medium"
  publicly_accessible = false
}

# API Gateway
module "api_gateway" {
  source = "../../modules/gateway"
  name   = "api-dev"
}

### Kubernetes Resources

resource "kubernetes_manifest" "api_configmap" {
  manifest = yamldecode(file("${path.module}/../../../k8s/api-configmap.yaml"))
}

resource "kubernetes_manifest" "api_secret" {
  manifest = yamldecode(file("${path.module}/../../../k8s/api-secret.yaml"))
}

resource "kubernetes_manifest" "api_deployment" {
  manifest = yamldecode(file("${path.module}/../../../k8s/api-deployment.yaml"))
  depends_on = [
    kubernetes_manifest.api_configmap,
    kubernetes_manifest.api_secret
  ]
}

resource "kubernetes_manifest" "api_service" {
  manifest = yamldecode(file("${path.module}/../../../k8s/api-service.yaml"))
  depends_on = [
    kubernetes_manifest.api_deployment
  ]
}

resource "kubernetes_manifest" "api_hpa" {
  manifest = yamldecode(file("${path.module}/../../../k8s/api-hpa.yaml"))
  depends_on = [
    kubernetes_manifest.api_deployment
  ]
}
