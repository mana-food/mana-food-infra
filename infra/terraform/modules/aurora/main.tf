# Gerar senha aleatória
resource "random_password" "master" {
  length  = 16
  special = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Armazenar senha no Secrets Manager
resource "aws_secretsmanager_secret" "master_password" {
  name_prefix             = "${var.cluster_identifier}-password-"
  description             = "Master password for Aurora cluster ${var.cluster_identifier}"
  recovery_window_in_days = var.secret_recovery_window_days

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "master_password" {
  secret_id = aws_secretsmanager_secret.master_password.id
  secret_string = jsonencode({
    username = var.master_username
    password = random_password.master.result
    engine   = var.engine
    host     = aws_rds_cluster.main.endpoint
    port     = aws_rds_cluster.main.port
    dbname   = var.database_name
  })
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name_prefix = "${var.cluster_identifier}-subnet-group-"
  subnet_ids  = var.subnet_ids
  description = "Subnet group for Aurora cluster ${var.cluster_identifier}"

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_identifier}-subnet-group"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group
resource "aws_security_group" "aurora" {
  name_prefix = "${var.cluster_identifier}-sg-"
  description = "Security group for Aurora cluster ${var.cluster_identifier}"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_identifier}-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Regra de ingresso para CIDR blocks
resource "aws_security_group_rule" "aurora_ingress_cidr" {
  count = length(var.allowed_cidr_blocks) > 0 ? 1 : 0

  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.aurora.id
  description       = "Allow MySQL access from CIDR blocks"
}

# Regra de ingresso para Security Groups
resource "aws_security_group_rule" "aurora_ingress_sg" {
  count = length(var.allowed_security_group_ids)

  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = var.allowed_security_group_ids[count.index]
  security_group_id        = aws_security_group.aurora.id
  description              = "Allow MySQL access from security group"
}

resource "aws_security_group_rule" "aurora_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aurora.id
  description       = "Allow all outbound traffic"
}

# Parameter Group
resource "aws_rds_cluster_parameter_group" "main" {
  name_prefix = "${var.cluster_identifier}-cluster-pg-"
  family      = var.engine == "aurora-mysql" ? "aurora-mysql8.0" : "aurora-mysql5.7"
  description = "Cluster parameter group for ${var.cluster_identifier}"

  dynamic "parameter" {
    for_each = var.cluster_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", "immediate")
    }
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_parameter_group" "main" {
  name_prefix = "${var.cluster_identifier}-instance-pg-"
  family      = var.engine == "aurora-mysql" ? "aurora-mysql8.0" : "aurora-mysql5.7"
  description = "Instance parameter group for ${var.cluster_identifier}"

  dynamic "parameter" {
    for_each = var.instance_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", "immediate")
    }
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# IAM Role para Enhanced Monitoring
resource "aws_iam_role" "monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0

  name_prefix = "${var.cluster_identifier}-monitoring-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "monitoring.rds.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0

  role       = aws_iam_role.monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# Aurora Cluster
resource "aws_rds_cluster" "main" {
  cluster_identifier     = var.cluster_identifier
  engine                 = var.engine
  engine_version         = var.engine_version
  engine_mode            = "provisioned"
  database_name          = var.database_name
  master_username        = var.master_username
  master_password        = random_password.master.result

  db_subnet_group_name            = aws_db_subnet_group.main.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.main.name
  vpc_security_group_ids          = [aws_security_group.aurora.id]

  port = 3306

  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  storage_encrypted   = true
  kms_key_id          = var.kms_key_id

  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.cluster_identifier}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  copy_tags_to_snapshot = true

  apply_immediately = var.apply_immediately

  serverlessv2_scaling_configuration {
    max_capacity = var.serverlessv2_max_capacity
    min_capacity = var.serverlessv2_min_capacity
  }

  tags = merge(
    var.tags,
    {
      Name = var.cluster_identifier
    }
  )

  lifecycle {
    ignore_changes = [final_snapshot_identifier]
  }
}

# Aurora Instances
resource "aws_rds_cluster_instance" "main" {
  count = var.instances_count

  identifier         = "${var.cluster_identifier}-instance-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.main.id

  engine         = aws_rds_cluster.main.engine
  engine_version = aws_rds_cluster.main.engine_version

  instance_class = var.instance_class

  db_parameter_group_name = aws_db_parameter_group.main.name

  publicly_accessible = false

  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_interval > 0 ? aws_iam_role.monitoring[0].arn : null

  performance_insights_enabled    = var.performance_insights_enabled
  performance_insights_kms_key_id = var.performance_insights_enabled ? var.kms_key_id : null
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  apply_immediately = var.apply_immediately

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_identifier}-instance-${count.index + 1}"
    }
  )
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count = var.create_cloudwatch_alarms ? var.instances_count : 0

  alarm_name          = "${var.cluster_identifier}-instance-${count.index + 1}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "CPU utilization is too high"
  alarm_actions       = var.alarm_actions

  dimensions = {
    DBInstanceIdentifier = aws_rds_cluster_instance.main[count.index].identifier
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "disk_queue_depth_high" {
  count = var.create_cloudwatch_alarms ? var.instances_count : 0

  alarm_name          = "${var.cluster_identifier}-instance-${count.index + 1}-disk-queue-depth-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DiskQueueDepth"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "64"
  alarm_description   = "Disk queue depth is too high"
  alarm_actions       = var.alarm_actions

  dimensions = {
    DBInstanceIdentifier = aws_rds_cluster_instance.main[count.index].identifier
  }

  tags = var.tags
}