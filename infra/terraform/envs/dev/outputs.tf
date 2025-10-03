output "lambda_arn" {
  value = module.lambda.lambda_arn
}

output "aurora_endpoint" {
  value = module.aurora.db_endpoint
}

output "aurora_instance_endpoints" {
  value = [for i in module.aurora.db_instance_endpoints : i]
}

output "eks_name" {
  value = module.eks.cluster_name
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "api_id" {
  value = module.api_gateway.api_id
}

output "eks_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "eks_certificate" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}

output "eks_name_cluster" {
  value = aws_eks_cluster.this.name
}