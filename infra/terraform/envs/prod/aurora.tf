resource "aws_db_subnet_group" "aurora" {
  name       = "${var.project_name}-aurora"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name        = "${var.project_name}-aurora"
    Environment = "prod"
    Project     = var.project_name
  }
}

module "aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "9.2.0"

  name            = "${var.project_name}-aurora"
  engine          = "aurora-mysql"
  engine_version  = "8.0.mysql_aurora.3.10.1"
  database_name   = "appdb"
  master_username               = "admin"
  manage_master_user_password   = true 

  engine_mode = "provisioned"
  serverlessv2_scaling_configuration = {
    min_capacity = 0.5
    max_capacity = 2.0
  }

  instances = {
    main = {
      instance_class = "db.serverless"
    }
  }

  vpc_id                 = module.vpc.vpc_id
  db_subnet_group_name   = aws_db_subnet_group.aurora.name 
  vpc_security_group_ids = [aws_security_group.aurora.id]

  skip_final_snapshot = true

  tags = {
    Name        = "${var.project_name}-aurora"
    Environment = "prod"
    Project     = var.project_name
  }

  depends_on = [aws_db_subnet_group.aurora]
}

resource "aws_security_group" "aurora" {
  name_prefix = "${var.project_name}-aurora-sg-"
  description = "Security group for Aurora cluster"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "${var.project_name}-aurora-sg"
  }
}

resource "aws_security_group_rule" "aurora_from_lambda" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lambda_sg.id
  security_group_id        = aws_security_group.aurora.id
  description              = "MySQL/Aurora access from Lambda"
}