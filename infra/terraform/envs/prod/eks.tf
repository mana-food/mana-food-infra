module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.1.0"

  cluster_name    = "${var.project_name}-eks"
  cluster_version = "1.27"

  # Referencia as subnets criadas no módulo VPC
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 3
      desired_size = 2
      instance_types = ["t3.medium"] # Tipo de instância para os nós
      subnet_ids     = module.vpc.private_subnets
    }
  }

  tags = {
    Name = "${var.project_name}-eks"
  }
}

# Security Group para permitir que os nós EKS acessem o Aurora
resource "aws_security_group_rule" "eks_to_aurora_access" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"

  source_security_group_id = module.eks.cluster_security_group_id
  security_group_id        = aws_security_group.aurora.id
  description              = "Allow EKS cluster to connect to Aurora"
}
