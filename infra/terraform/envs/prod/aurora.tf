module "aurora" {
  source = "../../modules/aurora"

  cluster_identifier = "${local.name_prefix}-aurora"
  engine             = "aurora-postgresql"
  engine_version     = var.aurora_engine_version

  database_name   = var.database_name
  master_username = var.database_master_username

  vpc_id                 = module.vpc.vpc_id
  subnet_ids             = module.vpc.database_subnet_ids

  instance_class    = var.aurora_instance_class
  instances_count   = var.aurora_instances_count

  backup_retention_period = var.environment == "prod" ? 7 : 1
  preferred_backup_window = "03:00-04:00"
  preferred_maintenance_window = "sun:04:00-sun:05:00"

  enabled_cloudwatch_logs_exports = ["postgresql"]

  deletion_protection = var.environment == "prod" ? true : false
  skip_final_snapshot = var.environment != "prod"

  tags = local.common_tags
}