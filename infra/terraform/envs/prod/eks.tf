module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.24.0"

  cluster_name    = var.eks_cluster_name
  cluster_version = var.eks_cluster_version

  # Configuração de acesso
  cluster_endpoint_public_access       = true
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access_cidrs = var.allowed_cidr_blocks

  # Rede
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  # Permissões
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions

  # Addons essenciais
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

  # Worker nodes
  eks_managed_node_groups = {
    default = {
      instance_types = var.eks_instance_types
      
      min_size     = var.eks_min_size
      max_size     = var.eks_max_size
      desired_size = var.eks_desired_size

      # Configurações do disco
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 50
            volume_type           = "gp3"
            encrypted             = true
            delete_on_termination = true
          }
        }
      }

      # Labels e taints
      labels = merge(local.common_tags, {
        Environment = var.environment
        NodeGroup   = "default"
      })

      # Configurações de update
      update_config = {
        max_unavailable_percentage = 25
      }
    }
  }

  # Logs do cluster
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_retention

  # Tags
  tags = merge(local.common_tags, {
    Name = var.eks_cluster_name
  })
}