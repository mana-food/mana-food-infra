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

  tags = {
    Name        = "${var.project_name}-lambda-role"
    Environment = "prod"
    Project     = var.project_name
  }
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_exec.name
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.lambda_exec.name
}

# ==========================================
# CLOUDWATCH LOGS
# ==========================================

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.project_name}-api-lambda"
  retention_in_days = 14

  tags = {
    Name        = "${var.project_name}-lambda-logs"
    Environment = "prod"
    Project     = var.project_name
  }
}

# ==========================================
# S3 BUCKET PARA CÓDIGO
# ==========================================

data "aws_s3_bucket" "code_bucket" {
  bucket = var.bucket_state_name
}

# ==========================================
# ARQUIVO ZIP TEMPORÁRIO (DUMMY)
# ==========================================

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/dummy-lambda.zip"
  
  source {
    content  = "dummy"
    filename = "dummy.txt"
  }
}

# ==========================================
# SECURITY GROUP PARA LAMBDA
# ==========================================

resource "aws_security_group" "lambda_sg" {
  name_prefix = "${var.project_name}-lambda-"
  description = "Security group for Lambda functions"
  vpc_id      = module.vpc.vpc_id

  # Permitir todo tráfego de saída
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.project_name}-lambda-sg"
    Environment = "prod"
    Project     = var.project_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ==========================================
# FUNÇÃO LAMBDA .NET
# ==========================================

resource "aws_lambda_function" "dotnet_lambda" {
  function_name = "${var.project_name}-api-lambda"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "Bootstrap"
  runtime       = "dotnet8"
  timeout       = 30
  memory_size   = 512

  # Arquivo temporário (substituir depois com deploy real)
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  vpc_config {
    subnet_ids         = module.vpc.private_subnets
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      AURORA_ENDPOINT = module.aurora.cluster_endpoint
      ENVIRONMENT     = "production"
    }
  }

  tags = {
    Name        = "${var.project_name}-api-lambda"
    Environment = "prod"
    Project     = var.project_name
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic,
    aws_iam_role_policy_attachment.lambda_vpc,
    aws_cloudwatch_log_group.lambda_logs,
  ]
}

# ==========================================
# OUTPUTS REMOVIDOS - FICARÃO NO outputs.tf
# ==========================================