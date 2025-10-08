module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.24.0"

  cluster_name    = "${var.project_name}-eks"
  cluster_version = "1.32"

  cluster_endpoint_public_access = true
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_cluster_creator_admin_permissions = true

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
    }
  }

  tags = {
    Name = "${var.project_name}-eks"
  }
}

resource "aws_iam_role_policy" "eks_nodes_secrets_manager" {
  name = "${var.project_name}-eks-nodes-secrets-policy"
  role = module.eks.eks_managed_node_groups["default"].iam_role_name

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
          module.aurora.cluster_master_user_secret[0].secret_arn,
          "${module.aurora.cluster_master_user_secret[0].secret_arn}*"
        ]
      }
    ]
  })

  depends_on = [
    module.eks,
    module.aurora
  ]
}

# Política adicional para logs CloudWatch (se necessário)
resource "aws_iam_role_policy_attachment" "eks_nodes_cloudwatch" {
  role       = module.eks.eks_managed_node_groups["default"].iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"

  depends_on = [module.eks]
}