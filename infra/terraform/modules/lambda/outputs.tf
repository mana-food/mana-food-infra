output "function_name" {
  description = "Nome da função"
  value       = aws_lambda_function.main.function_name
}

output "function_arn" {
  description = "ARN da função"
  value       = aws_lambda_function.main.arn
}

output "invoke_arn" {
  description = "ARN para invocar"
  value       = aws_lambda_function.main.invoke_arn
}

output "qualified_arn" {
  description = "ARN qualificado"
  value       = aws_lambda_function.main.qualified_arn
}

output "version" {
  description = "Versão"
  value       = aws_lambda_function.main.version
}

output "role_arn" {
  description = "ARN da role"
  value       = aws_iam_role.lambda.arn
}

output "role_name" {
  description = "Nome da role"
  value       = aws_iam_role.lambda.name
}

output "log_group_name" {
  description = "Nome do log group"
  value       = aws_cloudwatch_log_group.lambda.name
}

output "alias_arn" {
  description = "ARN do alias"
  value       = var.create_alias ? aws_lambda_alias.main[0].arn : null
}