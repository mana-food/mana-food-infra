# ==========================================
# KMS KEY PARA AURORA
# ==========================================

resource "aws_kms_key" "aurora" {
  description             = "Chave KMS para Aurora cluster ${var.project_name}"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-aurora-kms"
  })
}

resource "aws_kms_alias" "aurora" {
  name          = "alias/${var.project_name}-aurora"
  target_key_id = aws_kms_key.aurora.key_id
}

# ==========================================
# DB SUBNET GROUP
# ==========================================

resource "aws_db_subnet_group" "aurora" {
  name       = "${var.project_name}-aurora-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-aurora-subnet-group"
  })
}

# ==========================================
# SECURITY GROUP PARA AURORA
# ==========================================

resource "aws_security_group" "aurora" {
  name_prefix = "${var.project_name}-aurora-sg-"
  description = "Security group para Aurora cluster"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-aurora-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
  
  revoke_rules_on_delete = true
}

# Regra de entrada do Lambda
resource "aws_security_group_rule" "aurora_from_lambda" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lambda_sg.id
  security_group_id        = aws_security_group.aurora.id
  description              = "MySQL access from Lambda"
}

# Regra de entrada do EKS
resource "aws_security_group_rule" "aurora_from_eks" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = module.eks.node_security_group_id
  security_group_id        = aws_security_group.aurora.id
  description              = "MySQL access from EKS nodes"
}

# ==========================================
# AURORA CLUSTER
# ==========================================

module "aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "9.2.0"

  name            = "${var.project_name}-aurora"
  engine          = "aurora-mysql"
  engine_version  = var.aurora_engine_version
  database_name   = var.aurora_database_name
  
  # Credenciais gerenciadas automaticamente
  master_username             = "admin"
  manage_master_user_password = true
  
  # Configuração Serverless v2
  engine_mode = "provisioned"
  serverlessv2_scaling_configuration = {
    min_capacity = var.aurora_min_capacity
    max_capacity = var.aurora_max_capacity
  }

  instances = {
    main = {
      instance_class      = "db.serverless"
      publicly_accessible = false
    }
  }

  # Rede e segurança
  vpc_id                 = module.vpc.vpc_id
  db_subnet_group_name   = aws_db_subnet_group.aurora.name
  vpc_security_group_ids = [aws_security_group.aurora.id]

  # Backup e manutenção
  backup_retention_period   = var.aurora_backup_retention_period
  preferred_backup_window   = "03:00-04:00"
  preferred_maintenance_window = "sun:04:00-sun:05:00"
  
  # Criptografia
  storage_encrypted = true
  kms_key_id       = aws_kms_key.aurora.arn

  # Monitoramento
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]
  monitoring_interval             = 60
  monitoring_role_arn            = aws_iam_role.aurora_monitoring.arn

  # Performance Insights
  performance_insights_enabled = true
  performance_insights_kms_key_id = aws_kms_key.aurora.arn

  # Não criar snapshot final em ambiente de teste
  skip_final_snapshot = var.environment != "prod"
  final_snapshot_identifier = var.environment == "prod" ? "${var.project_name}-aurora-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}" : null

  # Proteção contra deleção em produção
  deletion_protection = var.environment == "prod"

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-aurora"
  })

  depends_on = [aws_db_subnet_group.aurora]
}

# ==========================================
# IAM ROLE PARA MONITORAMENTO
# ==========================================

resource "aws_iam_role" "aurora_monitoring" {
  name = "${var.project_name}-aurora-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "aurora_monitoring" {
  role       = aws_iam_role.aurora_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}