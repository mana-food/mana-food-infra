module "aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "9.2.0"

  name            = "${var.project_name}-aurora"
  engine          = "aurora-mysql"
  engine_version  = "8.0.mysql_aurora.3.02.0"
  database_name   = "appdb"
  master_username = var.db_master_username
  master_password = var.db_master_password

  engine_mode = "serverless"
  serverlessv2_scaling_configuration = {
    min_capacity = 0.5
    max_capacity = 2.0
  }

  vpc_id                 = module.vpc.vpc_id
  subnets                = module.vpc.private_subnets
  vpc_security_group_ids = [aws_security_group.aurora.id]

  tags = {
    Name = "${var.project_name}-aurora"
  }
}

resource "aws_security_group" "aurora" {
  name_prefix = "${var.project_name}-aurora-sg-"
  description = "Security group for Aurora cluster"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "${var.project_name}-aurora-sg"
  }
}
