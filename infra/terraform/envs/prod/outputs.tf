# VPC Outputs
output "vpc_id" {
  description = "ID da VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block da VPC"
  value       = module.vpc.vpc_cidr
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = module.vpc.public_subnet_ids
}

# EKS Outputs
output "eks_cluster_name" {
  description = "Nome do cluster EKS"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint do cluster EKS"
  value       = module.eks.cluster_endpoint
  sensitive   = true
}

output "eks_cluster_arn" {
  description = "ARN do cluster EKS"
  value       = module.eks.cluster_arn
}

output "eks_cluster_version" {
  description = "Versão do Kubernetes"
  value       = module.eks.cluster_version
}

output "eks_cluster_security_group_id" {
  description = "Security Group do cluster"
  value       = module.eks.cluster_security_group_id
}

output "eks_oidc_provider_arn" {
  description = "ARN do OIDC provider"
  value       = module.eks.oidc_provider_arn
}

output "eks_configure_kubectl" {
  description = "Comando para configurar kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

# Aurora MySQL Outputs
output "aurora_cluster_id" {
  description = "ID do cluster Aurora"
  value       = module.aurora.cluster_id
}

output "aurora_cluster_endpoint" {
  description = "Endpoint do cluster Aurora (write)"
  value       = module.aurora.cluster_endpoint
}

output "aurora_reader_endpoint" {
  description = "Endpoint de leitura"
  value       = module.aurora.reader_endpoint
}

output "aurora_database_name" {
  description = "Nome do banco de dados"
  value       = module.aurora.database_name
}

output "aurora_port" {
  description = "Porta do Aurora MySQL"
  value       = module.aurora.port
}

output "aurora_secret_arn" {
  description = "ARN do secret com credenciais"
  value       = module.aurora.master_password_secret_arn
}

# Lambda Outputs
output "lambda_function_name" {
  description = "Nome da função Lambda"
  value       = module.lambda.function_name
}

output "lambda_function_arn" {
  description = "ARN da função Lambda"
  value       = module.lambda.function_arn
}

output "lambda_invoke_arn" {
  description = "ARN para invocar a Lambda"
  value       = module.lambda.invoke_arn
}

# General
output "region" {
  description = "Região AWS"
  value       = var.aws_region
}

output "environment" {
  description = "Ambiente"
  value       = var.environment
}

output "account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}