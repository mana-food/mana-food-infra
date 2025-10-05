output "eks_cluster_name" {
  description = "Nome do Cluster EKS."
  value       = module.eks.cluster_id
}

output "db_endpoint" {
  description = "Endpoint do cluster Aurora MySQL."
  value       = module.aurora.cluster_endpoint
}

output "lambda_function_name" {
  description = "Nome da função Lambda .NET."
  value       = aws_lambda_function.dotnet_lambda.function_name
}