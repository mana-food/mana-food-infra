module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.24.0"

  cluster_name    = "${var.project_name}-eks"
  cluster_version = "1.32"

  cluster_endpoint_public_access = true
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_cluster_creator_admin_permissions = true

  enable_irsa = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 3
      desired_size   = 2

    metadata_options = {
      http_endpoint               = "enabled"
      http_tokens                 = "required"
      http_put_response_hop_limit = 1

      }
    }
  }

  tags = {
    Name = "${var.project_name}-eks"
    Environment = "production"
  }
}

# Data source para obter o ARN do secret de forma mais robusta
data "aws_secretsmanager_secret" "aurora_secret" {
  depends_on = [module.aurora]
  arn        = module.aurora.cluster_master_user_secret[0].secret_arn
}

# Política IAM robusta para EKS nodes acessarem Secrets Manager
resource "aws_iam_role_policy" "eks_nodes_secrets_manager" {
  name = "${var.project_name}-eks-nodes-secrets-policy"
  role = module.eks.eks_managed_node_groups["default"].iam_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSecretsManagerAccess"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          data.aws_secretsmanager_secret.aurora_secret.arn,
          "${data.aws_secretsmanager_secret.aurora_secret.arn}*",
          "arn:aws:secretsmanager:${var.aws_region}:*:secret:rds!cluster-*"
        ]
      },
      {
        Sid    = "AllowListSecrets"
        Effect = "Allow"
        Action = [
          "secretsmanager:ListSecrets"
        ]
        Resource = "*"
      }
    ]
  })

  depends_on = [
    module.eks,
    module.aurora,
    data.aws_secretsmanager_secret.aurora_secret
  ]
}

# Política AWS managed adicional para Secrets Manager (backup)
resource "aws_iam_role_policy_attachment" "eks_nodes_secrets_manager_managed" {
  role       = module.eks.eks_managed_node_groups["default"].iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  
  depends_on = [module.eks]
}

# Política para logs CloudWatch
resource "aws_iam_role_policy_attachment" "eks_nodes_cloudwatch" {
  role       = module.eks.eks_managed_node_groups["default"].iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"

  depends_on = [module.eks]
}