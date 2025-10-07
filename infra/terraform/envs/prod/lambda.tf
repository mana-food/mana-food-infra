# ==========================================
# KMS KEY PARA LAMBDA
# ==========================================

resource "aws_kms_key" "lambda" {
  description             = "Chave KMS para Lambda functions ${var.project_name}"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-lambda-kms"
  })
}

resource "aws_kms_alias" "lambda" {
  name          = "alias/${var.project_name}-lambda"
  target_key_id = aws_kms_key.lambda.key_id
}

# ==========================================
# IAM ROLE E POLICIES PARA LAMBDA
# ==========================================

resource "aws_iam_role" "lambda_exec" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-lambda-role"
  })
}

# Policies básicas
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_exec.name
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.lambda_exec.name
}

# Policy personalizada para acessar Aurora e Secrets Manager
resource "aws_iam_policy" "lambda_custom" {
  name        = "${var.project_name}-lambda-custom-policy"
  description = "Política personalizada para Lambda acessar Aurora e Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds:DescribeDBClusters",
          "rds:DescribeDBInstances",
          "rds-db:connect"
        ]
        Resource = [
          module.aurora.cluster_arn,
          "${module.aurora.cluster_arn}:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = module.aurora.cluster_master_user_secret[0].secret_arn
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = [
          aws_kms_key.lambda.arn,
          aws_kms_key.aurora.arn
        ]
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_custom" {
  policy_arn = aws_iam_policy.lambda_custom.arn
  role       = aws_iam_role.lambda_exec.name
}

# ==========================================
# CLOUDWATCH LOGS
# ==========================================

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.project_name}-api-lambda"
  retention_in_days = var.cloudwatch_log_retention
  kms_key_id       = aws_kms_key.lambda.arn

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-lambda-logs"
  })
}

# ==========================================
# SECURITY GROUP PARA LAMBDA
# ==========================================

resource "aws_security_group" "lambda_sg" {
  name_prefix = "${var.project_name}-lambda-"
  description = "Security group para funções Lambda"
  vpc_id      = module.vpc.vpc_id

  # Saída para Aurora
  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "MySQL access to Aurora"
  }

  # Saída para internet (APIs externas, updates, etc)
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS outbound"
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP outbound"
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-lambda-sg"
  })

  lifecycle {
    create_before_destroy = true
  }

  revoke_rules_on_delete = true
}

# ==========================================
# ARQUIVO DUMMY PARA LAMBDA
# ==========================================

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda-dummy.zip"
  
  source {
    content = jsonencode({
      message = "Placeholder Lambda function for ${var.project_name}"
      instructions = "Replace this with your actual .NET 8 Lambda deployment package"
    })
    filename = "dummy.json"
  }
}

# ==========================================
# FUNÇÃO LAMBDA
# ==========================================

resource "aws_lambda_function" "dotnet_lambda" {
  function_name = "${var.project_name}-api-lambda"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "Bootstrap"
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size

  # Arquivo temporário - substituir no deployment real
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  # Configuração VPC
  vpc_config {
    subnet_ids         = module.vpc.private_subnets
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  # Variáveis de ambiente
  environment {
    variables = {
      AURORA_ENDPOINT     = module.aurora.cluster_endpoint
      AURORA_PORT         = tostring(module.aurora.cluster_port)
      DATABASE_NAME       = var.aurora_database_name
      ENVIRONMENT         = var.environment
      SECRET_ARN          = module.aurora.cluster_master_user_secret[0].secret_arn
      KMS_KEY_ID          = aws_kms_key.lambda.key_id
    }
  }

  # Criptografia
  kms_key_arn = aws_kms_key.lambda.arn

  # Dead letter queue (opcional)
  # dead_letter_config {
  #   target_arn = aws_sqs_queue.lambda_dlq.arn
  # }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-api-lambda"
  })

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic,
    aws_iam_role_policy_attachment.lambda_vpc,
    aws_iam_role_policy_attachment.lambda_custom,
    aws_cloudwatch_log_group.lambda_logs,
  ]
}

# ==========================================
# LAMBDA PERMISSIONS (se necessário para API Gateway)
# ==========================================

# resource "aws_lambda_permission" "api_gateway" {
#   statement_id  = "AllowAPIGatewayInvoke"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.dotnet_lambda.function_name
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
# }