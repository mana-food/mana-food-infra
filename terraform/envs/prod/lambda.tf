# ==========================================
# IAM ROLE PARA LAMBDA AUTH
# ==========================================

resource "aws_iam_role" "lambda_auth_role" {
  name = "${var.project_name}-lambda-auth-role"

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
    Name = "${var.project_name}-lambda-auth-role"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_auth_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_auth_role.name
}

# Política para acessar DynamoDB Users table
resource "aws_iam_role_policy" "lambda_auth_dynamodb_policy" {
  name = "${var.project_name}-lambda-auth-dynamodb-policy"
  role = aws_iam_role.lambda_auth_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Query"
        ]
        Resource = [
          aws_dynamodb_table.users.arn,
          "${aws_dynamodb_table.users.arn}/index/CpfIndex"
        ]
      }
    ]
  })
}

# ==========================================
# CLOUDWATCH LOG GROUP
# ==========================================

resource "aws_cloudwatch_log_group" "lambda_auth_logs" {
  name              = "/aws/lambda/${var.project_name}-auth"
  retention_in_days = 14

  tags = {
    Name = "${var.project_name}-lambda-auth-logs"
  }
}

# ==========================================
# FUNÇÃO LAMBDA AUTH .NET 9
# ==========================================

resource "aws_lambda_function" "auth" {
  function_name = "${var.project_name}-auth"
  role          = aws_iam_role.lambda_auth_role.arn
  handler       = "bootstrap"
  runtime       = "provided.al2023"
  timeout       = 30
  memory_size   = 512

  filename         = fileexists("lambda-auth-deployment.zip") ? "lambda-auth-deployment.zip" : data.archive_file.lambda_auth_dummy.output_path
  source_code_hash = fileexists("lambda-auth-deployment.zip") ? filebase64sha256("lambda-auth-deployment.zip") : data.archive_file.lambda_auth_dummy.output_base64sha256

  environment {
    variables = {
      ASPNETCORE_ENVIRONMENT    = "Production"
      Jwt__SecretKey            = var.jwt_secret_key
      Jwt__Issuer               = "ManaFood"
      Jwt__Audience             = "ManaFoodUsers"
      Jwt__ExpirationMinutes    = "60"
      DYNAMODB_TABLE_NAME       = aws_dynamodb_table.users.name
    }
  }

  tags = {
    Name = "${var.project_name}-lambda-auth"
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_auth_basic,
    aws_cloudwatch_log_group.lambda_auth_logs,
    aws_dynamodb_table.users
  ]
}

# ==========================================
# ARQUIVO DUMMY (caso não exista build real)
# ==========================================

data "archive_file" "lambda_auth_dummy" {
  type        = "zip"
  output_path = "${path.module}/lambda-auth-dummy.zip"
  source {
    content  = "exports.handler = async (event) => ({ statusCode: 200, body: 'Hello from Auth Lambda!' });"
    filename = "index.js"
  }
}

# ==========================================
# API GATEWAY PARA LAMBDA AUTH
# ==========================================

resource "aws_api_gateway_rest_api" "lambda_auth_api" {
  name        = "${var.project_name}-auth-api"
  description = "API Gateway para Lambda Auth ${var.project_name}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Name = "${var.project_name}-auth-api-gateway"
  }
}

# Recurso greedy proxy: /{proxy+}
resource "aws_api_gateway_resource" "lambda_auth_resource" {
  rest_api_id = aws_api_gateway_rest_api.lambda_auth_api.id
  parent_id   = aws_api_gateway_rest_api.lambda_auth_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "lambda_auth_method" {
  rest_api_id   = aws_api_gateway_rest_api.lambda_auth_api.id
  resource_id   = aws_api_gateway_resource.lambda_auth_resource.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_auth_integration" {
  rest_api_id = aws_api_gateway_rest_api.lambda_auth_api.id
  resource_id = aws_api_gateway_resource.lambda_auth_resource.id
  http_method = aws_api_gateway_method.lambda_auth_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.auth.invoke_arn
}

# Método ANY no root "/"
resource "aws_api_gateway_method" "lambda_auth_root_method" {
  rest_api_id   = aws_api_gateway_rest_api.lambda_auth_api.id
  resource_id   = aws_api_gateway_rest_api.lambda_auth_api.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_auth_root_integration" {
  rest_api_id             = aws_api_gateway_rest_api.lambda_auth_api.id
  resource_id             = aws_api_gateway_rest_api.lambda_auth_api.root_resource_id
  http_method             = aws_api_gateway_method.lambda_auth_root_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.auth.invoke_arn
}

# Permissão para API Gateway invocar Lambda
resource "aws_lambda_permission" "api_gateway_auth_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auth.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.lambda_auth_api.execution_arn}/*/*"
}

# Deployment & Stage
resource "aws_api_gateway_deployment" "lambda_auth_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_auth_integration,
    aws_api_gateway_integration.lambda_auth_root_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.lambda_auth_api.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "lambda_auth_stage" {
  deployment_id = aws_api_gateway_deployment.lambda_auth_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.lambda_auth_api.id
  stage_name    = "prod"

  tags = {
    Name = "${var.project_name}-auth-api-stage"
  }
}