resource "aws_db_subnet_group" "aurora" {
  name       = "${var.project_name}-aurora"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "${var.project_name}-aurora"
  }
}

module "aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "9.2.0"

  name           = "${var.project_name}-aurora"
  engine         = "aurora-mysql"
  engine_version = "8.0.mysql_aurora.3.10.1"
  database_name  = "manafooddb"
  
  master_username             = "admin"
  manage_master_user_password = true
  
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

  vpc_id               = module.vpc.vpc_id
  db_subnet_group_name = aws_db_subnet_group.aurora.name
  vpc_security_group_ids = [aws_security_group.aurora.id]

  skip_final_snapshot = true

  tags = {
    Name = "${var.project_name}-aurora"
  }
}

resource "aws_security_group" "aurora" {
  name_prefix = "${var.project_name}-aurora-"
  description = "Aurora security group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda.id, module.eks.node_security_group_id]
  }

  tags = {
    Name = "${var.project_name}-aurora-sg"
  }
}