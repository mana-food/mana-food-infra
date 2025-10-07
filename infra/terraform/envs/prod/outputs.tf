# ==========================================
# OUTPUTS DA INFRAESTRUTURA
# ==========================================

# VPC Outputs
output "vpc_id" {
  description = "ID da VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block da VPC"
  value       = module.vpc.vpc_cidr_block
}

output "private_subnets" {
  description = "IDs das subnets privadas"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "IDs das subnets públicas"
  value       = module.vpc.public_subnets
}

# EKS Outputs
output "eks_cluster_id" {
  description = "ID do cluster EKS"
  value       = module.eks.cluster_id
}

output "eks_cluster_name" {
  description = "Nome do cluster EKS"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint do cluster EKS"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_version" {
  description = "Versão do cluster EKS"
  value       = module.eks.cluster_version
}

output "eks_cluster_security_group_id" {
  description = "ID do security group do cluster EKS"
  value       = module.eks.cluster_security_group_id
}

output "eks_node_security_group_id" {
  description = "ID do security group dos worker nodes"
  value       = module.eks.node_security_group_id
}

output "eks_oidc_issuer_url" {
  description = "URL do OIDC provider do EKS"
  value       = module.eks.cluster_oidc_issuer_url
}

# Aurora Outputs
output "aurora_cluster_id" {
  description = "ID do cluster Aurora"
  value       = module.aurora.cluster_id
}

output "aurora_cluster_endpoint" {
  description = "Endpoint do cluster Aurora"
  value       = module.aurora.cluster_endpoint
}

output "aurora_cluster_reader_endpoint" {
  description = "Endpoint de leitura do cluster Aurora"
  value       = module.aurora.cluster_reader_endpoint
}

output "aurora_cluster_port" {
  description = "Porta do cluster Aurora"
  value       = module.aurora.cluster_port
}

output "aurora_database_name" {
  description = "Nome do banco de dados Aurora"
  value       = module.aurora.cluster_database_name
}

output "aurora_master_username" {
  description = "Username master do Aurora"
  value       = module.aurora.cluster_master_username
  sensitive   = true
}

output "aurora_cluster_arn" {
  description = "ARN do cluster Aurora"
  value       = module.aurora.cluster_arn
}

output "aurora_security_group_id" {
  description = "ID do security group do Aurora"
  value       = aws_security_group.aurora.id
}

output "aurora_secret_arn" {
  description = "ARN do secret com credenciais do Aurora"
  value       = module.aurora.cluster_master_user_secret[0].secret_arn
  sensitive   = true
}

# Lambda Outputs
output "lambda_function_name" {
  description = "Nome da função Lambda"
  value       = aws_lambda_function.dotnet_lambda.function_name
}

output "lambda_function_arn" {
  description = "ARN da função Lambda"
  value       = aws_lambda_function.dotnet_lambda.arn
}

output "lambda_invoke_arn" {
  description = "ARN de invocação da função Lambda"
  value       = aws_lambda_function.dotnet_lambda.invoke_arn
}

output "lambda_security_group_id" {
  description = "ID do security group da Lambda"
  value       = aws_security_group.lambda_sg.id
}

output "lambda_role_arn" {
  description = "ARN da role da Lambda"
  value       = aws_iam_role.lambda_exec.arn
}

# Security Outputs
output "lambda_kms_key_id" {
  description = "ID da chave KMS para Lambda"
  value       = aws_kms_key.lambda.key_id
}

output "aurora_kms_key_id" {
  description = "ID da chave KMS para Aurora"
  value       = aws_kms_key.aurora.key_id
}

# Connectivity Outputs
output "kubeconfig_command" {
  description = "Comando para configurar kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

# Connection Info para aplicações
output "connection_info" {
  description = "Informações de conexão para aplicações"
  value = {
    aurora_endpoint = module.aurora.cluster_endpoint
    aurora_port     = module.aurora.cluster_port
    database_name   = var.aurora_database_name
    secret_arn      = module.aurora.cluster_master_user_secret[0].secret_arn
    lambda_function = aws_lambda_function.dotnet_lambda.function_name
    eks_cluster     = module.eks.cluster_name
  }
  sensitive = true
}

# Deployment Info
output "deployment_info" {
  description = "Informações de deployment"
  value = {
    environment       = var.environment
    project_name      = var.project_name
    aws_region        = var.aws_region
    deployed_at       = timestamp()
    terraform_version = "1.6.0"
  }
}