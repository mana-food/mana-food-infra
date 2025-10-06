output "eks_cluster_name" {
  description = "Nome do Cluster EKS."
  value       = module.eks.cluster_name
}

output "db_endpoint" {
  description = "Endpoint do cluster Aurora MySQL."
  value       = module.aurora.cluster_endpoint
}

output "lambda_function_name" {
  description = "Nome da função Lambda .NET."
  value       = aws_lambda_function.dotnet_lambda.function_name
}

output "lambda_function_arn" {
  description = "ARN da função Lambda"
  value       = aws_lambda_function.dotnet_lambda.arn
}

output "lambda_security_group_id" {
  description = "ID do Security Group da Lambda"
  value       = aws_security_group.lambda_sg.id
}