# Cria o IAM Role para a Lambda
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
}

# Políticas IAM básicas
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_exec.name
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.lambda_exec.name
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.project_name}-api-lambda"
  retention_in_days = 14
}

# Acesso ao S3 para artefatos
data "aws_s3_bucket" "code_bucket" {
  bucket = var.bucket_state_name
}

# Recurso para a função Lambda .NET
resource "aws_lambda_function" "dotnet_lambda" {
  function_name = "${var.project_name}-api-lambda"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "Bootstrap"
  runtime       = "dotnet8"
  timeout       = 30
  memory_size   = 512

  # Arquivo temporário (substituir depois)
  filename         = "dummy-lambda.zip"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  vpc_config {
    subnet_ids         = module.vpc.private_subnets
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      AURORA_ENDPOINT = module.aurora.cluster_endpoint
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic,
    aws_iam_role_policy_attachment.lambda_vpc,
    aws_cloudwatch_log_group.lambda_logs,
  ]
}

# Arquivo ZIP temporário
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/dummy-lambda.zip"
  source {
    content  = "dummy"
    filename = "dummy.txt"
  }
}

# Security Group para a Lambda
resource "aws_security_group" "lambda_sg" {
  name_prefix = "${var.project_name}-lambda-"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-lambda-sg"
  }
}
