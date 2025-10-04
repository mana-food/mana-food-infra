module "eks" {
  source = "../../modules/eks"

  cluster_name    = "${local.name_prefix}-cluster"
  cluster_version = var.eks_cluster_version

  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids

  node_groups = {
    main = {
      desired_size = var.eks_node_desired_size
      min_size     = var.eks_node_min_size
      max_size     = var.eks_node_max_size

      instance_types = var.eks_node_instance_types
      capacity_type  = "ON_DEMAND"

      labels = {
        Environment = var.environment
        NodeGroup   = "main"
      }

      tags = merge(
        local.common_tags,
        {
          "k8s.io/cluster-autoscaler/enabled"                 = "true"
          "k8s.io/cluster-autoscaler/${local.name_prefix}-cluster" = "owned"
        }
      )
    }
  }

  tags = local.common_tags
}