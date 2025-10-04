output "cluster_id" {
  description = "ID do cluster"
  value       = aws_eks_cluster.main.id
}

output "cluster_name" {
  description = "Nome do cluster"
  value       = aws_eks_cluster.main.name
}

output "cluster_arn" {
  description = "ARN do cluster"
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "Endpoint do cluster"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_version" {
  description = "Versão do Kubernetes"
  value       = aws_eks_cluster.main.version
}

output "cluster_certificate_authority_data" {
  description = "Certificado do cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "cluster_security_group_id" {
  description = "Security Group do cluster"
  value       = aws_security_group.cluster.id
}

output "node_security_group_id" {
  description = "Security Group dos nodes"
  value       = aws_security_group.node_group.id
}

output "oidc_provider_arn" {
  description = "ARN do OIDC provider"
  value       = aws_iam_openid_connect_provider.cluster.arn
}

output "oidc_provider_url" {
  description = "URL do OIDC provider"
  value       = replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")
}

output "node_role_arn" {
  description = "ARN da role dos nodes"
  value       = aws_iam_role.node_group.arn
}