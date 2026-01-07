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

output "lambda_auth_url" {
  description = "Lambda Auth API Gateway URL"
  value       = "${aws_api_gateway_stage.lambda_auth_stage.invoke_url}/api/auth/login"
}

output "dynamodb_users_table_name" {
  description = "DynamoDB Users table name"
  value       = aws_dynamodb_table.users.name
}

output "dynamodb_users_table_arn" {
  description = "DynamoDB Users table ARN"
  value       = aws_dynamodb_table.users.arn
}

output "user_service_iam_role_arn" {
  description = "IAM Role ARN for User Service"
  value       = aws_iam_role.user_service_dynamodb.arn
}

output "api_gateway_load_balancer" {
  description = "API Gateway Load Balancer URL (after kubectl apply)"
  value       = "Run: kubectl get svc api-gateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
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

output "aurora_secret_arn" {
  description = "ARN do secret do Aurora no Secrets Manager"
  value       = module.aurora.cluster_master_user_secret[0].secret_arn
  sensitive   = true
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
    api_gateway_url      = "https://${aws_api_gateway_rest_api.lambda_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.lambda_stage.stage_name}"
  }
}