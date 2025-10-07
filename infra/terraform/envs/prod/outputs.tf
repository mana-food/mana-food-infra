# ==========================================
# OUTPUTS DA INFRAESTRUTURA
# ==========================================

# EKS Outputs
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

# Aurora Outputs
output "aurora_endpoint" {
  description = "Endpoint do cluster Aurora MySQL"
  value       = module.aurora.cluster_endpoint
}

output "aurora_port" {
  description = "Porta do cluster Aurora"
  value       = module.aurora.cluster_port
}

output "aurora_database_name" {
  description = "Nome do banco de dados"
  value       = module.aurora.cluster_database_name
}

# Lambda Outputs
output "lambda_function_name" {
  description = "Nome da função Lambda"
  value       = aws_lambda_function.api.function_name
}

output "lambda_function_arn" {
  description = "ARN da função Lambda"
  value       = aws_lambda_function.api.arn
}

output "lambda_db_setup_function_name" {
  description = "Nome da função Lambda de setup do DB"
  value       = aws_lambda_function.db_setup.function_name
}

output "lambda_api_url" {
  description = "URL da API Gateway para Lambda"
  value       = "https://${aws_api_gateway_rest_api.lambda_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.lambda_stage.stage_name}"
}

# VPC Outputs
output "vpc_id" {
  description = "ID da VPC"
  value       = module.vpc.vpc_id
}

# URLs e comandos úteis
output "kubectl_command" {
  description = "Comando para configurar kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "app_service_command" {
  description = "Comando para verificar o serviço da aplicação"
  value       = "kubectl get svc mana-food-service -o wide"
}

# Informações de deployment
output "deployment_info" {
  description = "Informações do deployment"
  value = {
    region               = var.aws_region
    project_name         = var.project_name
    eks_cluster          = module.eks.cluster_name
    aurora_cluster       = module.aurora.cluster_id
    lambda_function      = aws_lambda_function.api.function_name
    lambda_db_setup      = aws_lambda_function.db_setup.function_name
    api_gateway_url      = "https://${aws_api_gateway_rest_api.lambda_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.lambda_stage.stage_name}"
  }
}