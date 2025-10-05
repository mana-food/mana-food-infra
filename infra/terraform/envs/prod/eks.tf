module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.eks_cluster_name
  cluster_version = "1.28"

  # Referencia as subnets criadas no módulo VPC
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    main = {
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 3
      desired_size   = 2

      ami_type       = "AL2_x86_64"
      capacity_type  = "ON_DEMAND"

      subnet_ids = module.vpc.private_subnets

      labels = {
        Environment = "prod"
        Project     = var.project_name
      }

      update_config = {
        max_unavailable_percentage = 25
      }
    }
  }

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
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  enable_cluster_creator_admin_permissions = true
  tags = {
    Environment = "prod"
    Project     = var.project_name
  }
}