module "lambda" {
  source = "../../modules/lambda"

  function_name = "${local.name_prefix}-processor"
  handler       = "ManaFood.Lambda::ManaFood.Lambda.Function::FunctionHandler"
  runtime       = var.lambda_runtime

  source_path = "${path.module}/../lambda/publish"

  memory_size = var.lambda_memory_size
  timeout     = var.lambda_timeout

  environment_variables = {
    ENVIRONMENT     = var.environment
    DATABASE_HOST   = module.aurora.cluster_endpoint
    DATABASE_NAME   = var.database_name
    DATABASE_PORT   = tostring(module.aurora.port)
    DATABASE_SECRET = module.aurora.master_password_secret_arn
    EKS_CLUSTER     = module.eks.cluster_name
    AWS_REGION      = var.aws_region
  }

  vpc_config = {
    subnet_ids         = module.vpc.private_subnet_ids
    security_group_ids = [module.vpc.lambda_security_group_id]
  }

  attach_policy_statements = true
  policy_statements = {
    secrets_manager = {
      effect = "Allow"
      actions = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      resources = [module.aurora.master_password_secret_arn]
    }
    rds = {
      effect = "Allow"
      actions = [
        "rds:DescribeDBClusters",
        "rds:DescribeDBInstances"
      ]
      resources = [module.aurora.cluster_arn]
    }
    eks = {
      effect = "Allow"
      actions = [
        "eks:DescribeCluster"
      ]
      resources = [module.eks.cluster_arn]
    }
  }

  tags = local.common_tags
}