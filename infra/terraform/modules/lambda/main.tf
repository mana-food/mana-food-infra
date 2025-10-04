# Criar arquivo ZIP do código Lambda
data "archive_file" "lambda" {
  count = var.source_path != "" ? 1 : 0

  type        = "zip"
  source_dir  = var.source_path
  output_path = "${path.module}/lambda_function.zip"
}

# IAM Role para Lambda
resource "aws_iam_role" "lambda" {
  name_prefix = "${var.function_name}-role-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

# Policy para VPC (se configurado)
resource "aws_iam_role_policy_attachment" "lambda_vpc_execution" {
  count = var.vpc_config != null ? 1 : 0

  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Policy básica de execução
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Policies customizadas
resource "aws_iam_role_policy" "lambda_custom" {
  count = var.attach_policy_statements ? 1 : 0

  name_prefix = "${var.function_name}-policy-"
  role        = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for k, v in var.policy_statements : {
        Effect   = v.effect
        Action   = v.actions
        Resource = v.resources
      }
    ]
  })
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# Lambda Function
resource "aws_lambda_function" "main" {
  function_name = var.function_name
  role          = aws_iam_role.lambda.arn
  runtime       = var.runtime
  handler       = var.handler

  filename         = try(data.archive_file.lambda[0].output_path, null)
  source_code_hash = try(data.archive_file.lambda[0].output_base64sha256, null)

  memory_size = var.memory_size
  timeout     = var.timeout

  vpc_config = var.vpc_config != null ? {
    subnet_ids         = var.vpc_config.subnet_ids
    security_group_ids = var.vpc_config.security_group_ids
  } : null

  environment {
    variables = var.environment_variables
  }

  tags = merge(
    var.tags,
    { Name = var.function_name }
  )
}

# Lambda Alias
resource "aws_lambda_alias" "main" {
  count = var.create_alias ? 1 : 0

  name             = var.alias_name
  description      = "Alias for ${var.function_name}"
  function_name    = aws_lambda_function.main.function_name
  function_version = var.publish ? aws_lambda_function.main.version : "$LATEST"

  lifecycle {
    ignore_changes = [function_version]
  }
}

# Lambda Permission para API Gateway
resource "aws_lambda_permission" "apigw" {
  count = var.allow_api_gateway ? 1 : 0

  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = var.api_gateway_source_arn
}

# Lambda Permission para EventBridge
resource "aws_lambda_permission" "eventbridge" {
  count = var.allow_eventbridge ? 1 : 0

  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "events.amazonaws.com"
  source_arn    = var.eventbridge_rule_arn
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "errors" {
  count = var.create_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.function_name}-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Sum"
  threshold           = var.error_alarm_threshold
  alarm_description   = "Lambda function errors"
  alarm_actions       = var.alarm_actions

  dimensions = {
    FunctionName = aws_lambda_function.main.function_name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "throttles" {
  count = var.create_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.function_name}-throttles"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Sum"
  threshold           = var.throttle_alarm_threshold
  alarm_description   = "Lambda function throttles"
  alarm_actions       = var.alarm_actions

  dimensions = {
    FunctionName = aws_lambda_function.main.function_name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "duration" {
  count = var.create_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.function_name}-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Average"
  threshold           = var.duration_alarm_threshold
  alarm_description   = "Lambda function duration"
  alarm_actions       = var.alarm_actions

  dimensions = {
    FunctionName = aws_lambda_function.main.function_name
  }

  tags = var.tags
}