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

output "lambda_function_name" {
  description = "Lambda Auth function name"
  value       = aws_lambda_function.auth.function_name
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

output "vpc_id" {
  description = "ID da VPC"
  value       = module.vpc.vpc_id
}

output "kubectl_command" {
  description = "Comando para configurar kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}