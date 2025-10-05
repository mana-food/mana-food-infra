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

resource "aws_eks_access_policy_association" "eks-access-policy" {
  cluster_name  = aws_eks_cluster.eks-cluster.name
  policy_arn    = var.policyArn
  principal_arn = var.principalArn

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_cluster" "eks-cluster" {
  name     = var.projectName
  role_arn = var.labRole

  vpc_config {
    subnet_ids         = [for subnet in data.aws_subnet.subnet : subnet.id if subnet.availability_zone != var.aws_region]
    security_group_ids = [aws_security_group.sg.id]
  }

  access_config {
    authentication_mode = var.accessConfig
  }
}

resource "aws_eks_node_group" "eks-node" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = var.nodeGroup
  node_role_arn   = var.labRole
  subnet_ids      = [for subnet in data.aws_subnet.subnet : subnet.id if subnet.availability_zone != var.aws_region]
  disk_size       = 50
  instance_types  = [var.instanceType]

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 2
  }

  update_config {
    max_unavailable = 1
  }
}
