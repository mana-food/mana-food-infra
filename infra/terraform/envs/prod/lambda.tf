# ==========================================
# IAM ROLE PARA LAMBDA
# ==========================================

resource "aws_iam_role" "lambda_role" {
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
    Name = "${var.project_name}-lambda-role"
  }
}

# Políticas básicas
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

# Política customizada para RDS e Secrets Manager
resource "aws_iam_role_policy" "lambda_custom_policy" {
  name = "${var.project_name}-lambda-custom-policy"
  role = aws_iam_role.lambda_role.id

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
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "*"
      }
    ]
  })
}

# ==========================================
# SECURITY GROUP PARA LAMBDA
# ==========================================

resource "aws_security_group" "lambda" {
  name_prefix = "${var.project_name}-lambda-"
  description = "Security group para Lambda functions"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.project_name}-lambda-sg"
  }
}

# ==========================================
# CLOUDWATCH LOG GROUP
# ==========================================

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.project_name}-api"
  retention_in_days = 14

  tags = {
    Name = "${var.project_name}-lambda-logs"
  }
}

resource "aws_cloudwatch_log_group" "lambda_db_setup_logs" {
  name              = "/aws/lambda/${var.project_name}-db-setup"
  retention_in_days = 14

  tags = {
    Name = "${var.project_name}-lambda-db-setup-logs"
  }
}

# ==========================================
# FUNÇÃO LAMBDA DE SETUP DO BANCO
# ==========================================

data "archive_file" "lambda_db_setup" {
  type        = "zip"
  output_path = "${path.module}/lambda-db-setup.zip"
  source {
    content = <<EOF
import json
import pymysql
import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    try:
        logger.info("🗄️ Iniciando setup do banco Mana Food...")
        
        # Obter credenciais do Aurora
        rds_client = boto3.client('rds')
        secrets_client = boto3.client('secretsmanager')
        
        # Buscar informações do cluster
        cluster_info = rds_client.describe_db_clusters(DBClusterIdentifier='mana-food-aurora')
        cluster = cluster_info['DBClusters'][0]
        
        endpoint = cluster['Endpoint']
        port = cluster['Port']
        
        # Obter credenciais
        if 'MasterUserSecret' in cluster and cluster['MasterUserSecret']:
            secret_arn = cluster['MasterUserSecret']['SecretArn']
            secret_response = secrets_client.get_secret_value(SecretId=secret_arn)
            secret_data = json.loads(secret_response['SecretString'])
            username = secret_data['username']
            password = secret_data['password']
        else:
            username = 'admin'
            password = event.get('password', 'TempPassword123!')
        
        logger.info(f"Conectando ao Aurora: {endpoint}:{port}")
        
        # Conectar ao MySQL
        connection = pymysql.connect(
            host=endpoint,
            port=port,
            user=username,
            password=password,
            charset='utf8mb4',
            cursorclass=pymysql.cursors.DictCursor,
            connect_timeout=60,
            read_timeout=60,
            write_timeout=60
        )
        
        with connection.cursor() as cursor:
            logger.info("✅ Conexão estabelecida!")
            
            # Criar database
            cursor.execute("CREATE DATABASE IF NOT EXISTS manafooddb")
            cursor.execute("USE manafooddb")
            
            # Tabela de usuários
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS users (
                    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
                    cpf VARCHAR(11) NOT NULL UNIQUE,
                    name VARCHAR(255) NOT NULL,
                    email VARCHAR(255),
                    phone VARCHAR(20),
                    user_type ENUM('cliente', 'admin', 'gerente') DEFAULT 'cliente',
                    password_hash VARCHAR(255),
                    is_active BOOLEAN DEFAULT TRUE,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                    
                    INDEX idx_cpf (cpf),
                    INDEX idx_email (email),
                    INDEX idx_user_type (user_type),
                    INDEX idx_active (is_active)
                )
            """)
            
            # Inserir dados de teste
            users_data = [
                ('12345678901', 'Cliente Teste Mana Food', 'cliente@test.com', 'cliente'),
                ('98765432100', 'Admin Sistema Mana Food', 'admin@manafood.com', 'admin'),
                ('11111111111', 'Gerente Mana Food', 'gerente@manafood.com', 'gerente')
            ]
            
            for cpf, name, email, user_type in users_data:
                cursor.execute("""
                    INSERT IGNORE INTO users (id, cpf, name, email, user_type, is_active) 
                    VALUES (UUID(), %s, %s, %s, %s, TRUE)
                """, (cpf, name, email, user_type))
            
            connection.commit()
            
            # Verificar dados inseridos
            cursor.execute("SELECT COUNT(*) as count FROM users")
            users_count = cursor.fetchone()['count']
            
            logger.info(f"✅ Setup concluído! Usuários: {users_count}")
            
            return {
                'statusCode': 200,
                'body': json.dumps({
                    'message': 'Banco Mana Food configurado com sucesso!',
                    'users_count': users_count,
                    'endpoint': endpoint
                })
            }
            
    except Exception as e:
        logger.error(f"❌ Erro no setup: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e),
                'message': 'Falha no setup do banco'
            })
        }
    finally:
        if 'connection' in locals():
            connection.close()
EOF
    filename = "lambda_function.py"
  }
}

resource "aws_lambda_function" "db_setup" {
  function_name = "${var.project_name}-db-setup"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  timeout       = 300
  memory_size   = 256

  filename         = data.archive_file.lambda_db_setup.output_path
  source_code_hash = data.archive_file.lambda_db_setup.output_base64sha256

  vpc_config {
    subnet_ids         = module.vpc.private_subnets
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      AURORA_ENDPOINT = module.aurora.cluster_endpoint
      AURORA_PORT     = "3306"
      DATABASE_NAME   = "manafooddb"
    }
  }

  # Usar layer público do PyMySQL
  layers = ["arn:aws:lambda:sa-east-1:336392948345:layer:AWSSDKPandas-Python312:8"]

  tags = {
    Name = "${var.project_name}-db-setup-lambda"
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic,
    aws_iam_role_policy_attachment.lambda_vpc,
    aws_cloudwatch_log_group.lambda_db_setup_logs
  ]
}

# ==========================================
# FUNÇÃO LAMBDA PRINCIPAL (.NET 9)
# ==========================================

resource "aws_lambda_function" "api" {
  function_name = "${var.project_name}-api"
  role          = aws_iam_role.lambda_role.arn
  handler       = "bootstrap"
  runtime       = "provided.al2023"
  timeout       = 30
  memory_size   = 512

  # Usar o arquivo ZIP da build ou dummy se não existir
  filename         = fileexists("lambda-deployment.zip") ? "lambda-deployment.zip" : data.archive_file.lambda_dummy.output_path
  source_code_hash = fileexists("lambda-deployment.zip") ? filebase64sha256("lambda-deployment.zip") : data.archive_file.lambda_dummy.output_base64sha256

  vpc_config {
    subnet_ids         = module.vpc.private_subnets
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      AURORA_ENDPOINT        = module.aurora.cluster_endpoint
      AURORA_PORT           = "3306"
      DATABASE_NAME         = "manafooddb"
      ASPNETCORE_ENVIRONMENT = "Production"
      # ❌ REMOVIDO AWS_REGION (variável reservada)
    }
  }

  tags = {
    Name = "${var.project_name}-lambda"
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic,
    aws_iam_role_policy_attachment.lambda_vpc,
    aws_cloudwatch_log_group.lambda_logs,
    aws_lambda_function.db_setup  # Garantir que o setup do DB rode primeiro
  ]
}

# ==========================================
# ARQUIVO DUMMY PARA LAMBDA (se não existir o real)
# ==========================================

data "archive_file" "lambda_dummy" {
  type        = "zip"
  output_path = "${path.module}/lambda-dummy.zip"
  source {
    content  = "exports.handler = async (event) => ({ statusCode: 200, body: 'Hello from dummy Lambda!' });"
    filename = "index.js"
  }
}

# ==========================================
# API GATEWAY PARA LAMBDA
# ==========================================

resource "aws_api_gateway_rest_api" "lambda_api" {
  name        = "${var.project_name}-api"
  description = "API Gateway para Lambda ${var.project_name}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Name = "${var.project_name}-api-gateway"
  }
}

resource "aws_api_gateway_resource" "lambda_resource" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  parent_id   = aws_api_gateway_rest_api.lambda_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "lambda_method" {
  rest_api_id   = aws_api_gateway_rest_api.lambda_api.id
  resource_id   = aws_api_gateway_resource.lambda_resource.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  resource_id = aws_api_gateway_resource.lambda_resource.id
  http_method = aws_api_gateway_method.lambda_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api.invoke_arn
}

resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.lambda_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "lambda_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.lambda_api.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "lambda_stage" {
  deployment_id = aws_api_gateway_deployment.lambda_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.lambda_api.id
  stage_name    = "prod"

  tags = {
    Name = "${var.project_name}-api-stage"
  }
}