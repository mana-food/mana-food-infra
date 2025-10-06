# # Busca os dados do cluster EKS existente
# data "aws_eks_cluster" "eks" {
#   name = var.eks_cluster_name
# }
#
# data "aws_eks_cluster_auth" "eks" {
#   name = data.aws_eks_cluster.eks.name
# }

# Provedor Kubernetes: Depende da criação do EKS para obter as credenciais
data "aws_eks_cluster_auth" "cluster" {
  depends_on = [module.eks]
  name       = module.eks.cluster_name 
}

data "aws_eks_cluster" "cluster" {
  depends_on = [module.eks]
  name       = module.eks.cluster_name 
}

data "aws_vpc" "vpc" {
  cidr_block = "172.31.0.0/16"
}

data "aws_subnets" "subnets"{
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}

data "aws_subnet" "subnet" {
  for_each = toset(data.aws_subnets.subnets.ids)
  id       = each.value
}
