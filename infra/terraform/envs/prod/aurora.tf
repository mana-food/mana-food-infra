module "aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "9.2.0"

  name            = "${var.project_name}-aurora"
  engine          = "aurora-mysql"
  engine_version  = "8.0.mysql_aurora.3.02.0"
  database_name   = "appdb"
  master_username = var.db_master_username
  master_password = var.db_master_password

  # CORRIGIDO: Usar serverless v2 
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
  subnets                = module.vpc.private_subnets
  vpc_security_group_ids = [aws_security_group.aurora.id]

  skip_final_snapshot = true

  tags = {
    Name = "${var.project_name}-aurora"
  }
}