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

# Acesso ao S3 para artefatos
data "aws_s3_bucket" "code_bucket" {
  bucket = var.bucket_state_name
}

# Recurso para a função Lambda .NET
resource "aws_lambda_function" "dotnet_lambda" {
  function_name = "${var.project_name}-api-lambda"
  role          = aws_iam_role.lambda_exec.arn
  handler = "My.Dotnet.Lambda::My.Dotnet.Lambda.Function::FunctionHandler" # Altere para seu handler .NET
  runtime = "dotnet8" # Altere para sua versão
  timeout       = 30
  memory_size = 256

  # Usar o arquivo ZIP do seu código compilado
  s3_bucket = data.aws_s3_bucket.code_bucket.id
  s3_key    = "dotnet_lambda.zip" # Suba seu .NET zipado para este bucket

  # Coloca a Lambda na VPC (Subnets Privadas)
  vpc_config {
    subnet_ids = module.vpc.private_subnets
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      AURORA_ENDPOINT = module.aurora.cluster_endpoint
      # Adicione outras variáveis, como credenciais do DB (de preferência via Secrets Manager)
    }
  }
}
resource "aws_security_group_rule" "lambda_to_aurora_access" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.aurora.id
  source_security_group_id = aws_security_group.lambda_sg.id
  description              = "Allow Lambda to access Aurora"

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [description]
  }
}

# Security Group para a Lambda (Permite saída para o Aurora)
resource "aws_security_group" "lambda_sg" {
  name   = "${var.project_name}-lambda-sg"
  vpc_id = module.vpc.vpc_id

  tags = {
    Name = "${var.project_name}-lambda-sg"
  }
}

# Regra de saída da Lambda -> Aurora
resource "aws_security_group_rule" "lambda_egress_to_aurora" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lambda_sg.id
  security_group_id        = aws_security_group.aurora.id
  description              = "Allow Lambda to connect to Aurora"
}

# Regra de entrada (no Aurora) permitindo conexão da Lambda
resource "aws_security_group_rule" "aurora_ingress_from_lambda" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lambda_sg.id
  security_group_id        = aws_security_group.aurora.id
  description              = "Allow Lambda to connect to Aurora"
}
