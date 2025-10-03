output "db_endpoint" {
  value = aws_rds_cluster.this.endpoint
}

output "db_instance_endpoints" {
  value = [for i in aws_rds_cluster_instance.this : i.endpoint]
}
