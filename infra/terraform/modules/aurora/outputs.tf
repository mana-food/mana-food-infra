output "cluster_id" {
  description = "ID do cluster"
  value       = aws_rds_cluster.main.id
}

output "cluster_arn" {
  description = "ARN do cluster"
  value       = aws_rds_cluster.main.arn
}

output "cluster_endpoint" {
  description = "Endpoint do cluster (write)"
  value       = aws_rds_cluster.main.endpoint
}

output "reader_endpoint" {
  description = "Endpoint de leitura"
  value       = aws_rds_cluster.main.reader_endpoint
}

output "database_name" {
  description = "Nome do banco"
  value       = aws_rds_cluster.main.database_name
}

output "master_username" {
  description = "Usuário master"
  value       = aws_rds_cluster.main.master_username
  sensitive   = true
}

output "port" {
  description = "Porta"
  value       = aws_rds_cluster.main.port
}

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.aurora.id
}

output "master_password_secret_arn" {
  description = "ARN do secret com senha"
  value       = aws_secretsmanager_secret.master_password.arn
}

output "instance_ids" {
  description = "IDs das instâncias"
  value       = aws_rds_cluster_instance.main[*].id
}

output "instance_endpoints" {
  description = "Endpoints das instâncias"
  value       = aws_rds_cluster_instance.main[*].endpoint
}