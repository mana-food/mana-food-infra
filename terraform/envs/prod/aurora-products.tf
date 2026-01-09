# ==========================================
# AURORA MYSQL SERVERLESS V2 - PRODUCTS
# ==========================================

resource "aws_db_subnet_group" "products" {
  name       = "${var.project_name}-products-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "${var.project_name}-products-subnet-group"
  }
}

resource "aws_security_group" "products_aurora" {
  name        = "${var.project_name}-products-aurora-sg"
  description = "Security group for Products Aurora MySQL"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
    description     = "Allow MySQL from EKS nodes"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-products-aurora-sg"
  }
}

resource "aws_rds_cluster" "products" {
  cluster_identifier      = "${var.project_name}-products"
  engine                  = "aurora-mysql"
  engine_mode             = "provisioned"
  database_name           = "products"
  master_username         = "admin"
  master_password         = random_password.products_db_password.result
  db_subnet_group_name    = aws_db_subnet_group.products.name
  vpc_security_group_ids  = [aws_security_group.products_aurora.id]
  skip_final_snapshot     = true
  backup_retention_period = 7
  preferred_backup_window = "03:00-04:00"

  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 2.0
  }

  tags = {
    Name = "${var.project_name}-products-aurora"
  }
}

resource "aws_rds_cluster_instance" "products" {
  identifier         = "${var.project_name}-products-instance"
  cluster_identifier = aws_rds_cluster.products.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.products.engine
  engine_version     = aws_rds_cluster.products.engine_version

  tags = {
    Name = "${var.project_name}-products-instance"
  }
}

resource "random_password" "products_db_password" {
  length  = 32
  special = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "products_db_password" {
  name = "${var.project_name}-products-db-password"

  tags = {
    Name = "${var.project_name}-products-db-password"
  }
}

resource "aws_secretsmanager_secret_version" "products_db_password" {
  secret_id     = aws_secretsmanager_secret.products_db_password.id
  secret_string = random_password.products_db_password.result
}

# ==========================================
# IAM ROLE PARA PRODUCT SERVICE (IRSA)
# ==========================================

resource "aws_iam_role" "product_service" {
  name = "${var.project_name}-product-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:default:product-service-sa"
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-product-service-role"
  }
}

resource "aws_iam_role_policy" "product_service_secrets" {
  name = "${var.project_name}-product-service-secrets-policy"
  role = aws_iam_role.product_service.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          aws_secretsmanager_secret.products_db_password.arn
        ]
      }
    ]
  })
}