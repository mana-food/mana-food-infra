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

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

# VPC
module "vpc" {
  source             = "../../modules/vpc"
  name               = "manafood-vpc"
  cidr_block         = "10.0.0.0/16"
  subnets            = var.subnets
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  availability_zones = ["us-east-1"]
}

# EKS
module "eks" {
  source           = "../../modules/eks"
  cluster_name     = "manafood-eks-cluster"
  cluster_role_arn = var.eks_cluster_role_arn
  node_role_arn    = var.eks_node_role_arn
  subnet_ids       = module.vpc.public_subnet_ids
  # subnets = var.subnets
}

# # API Gateway
# module "api_gateway" {
#   source      = "../../modules/gateway"
#   name        = "manafood-api-gateway"
#   path_part   = "hello"
#   description = "API para ambiente de produção"
# }

# Lambda
module "lambda" {
  source      = "../../modules/lambda"
  name        = "manafood-lambda-dotnet"
  runtime     = "dotnet9"
  handler     = "MeuProjeto::MeuProjeto.Function::FunctionHandler"
  filename    = "lambda-dotnet.zip"
  timeout     = 10
  memory_size = 256
}

# Aurora
module "aurora" {
  source             = "../../modules/aurora"
  cluster_identifier = "manafood-bd-aurora"
  db_username        = var.db_username
  db_password        = var.db_password
  subnet_ids         = module.vpc.public_subnet_ids
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  instance_count     = 1
  instance_class     = "db.t3.medium"
  publicly_accessible = false
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
