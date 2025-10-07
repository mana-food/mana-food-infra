# ==========================================
# PROVIDER AWS
# ==========================================

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "prod"
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}

# ==========================================
# PROVIDER KUBERNETES
# ==========================================

provider "kubernetes" {
  host                   = var.create_k8s_resources ? data.aws_eks_cluster.cluster.endpoint : ""
  cluster_ca_certificate = var.create_k8s_resources ? base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data) : ""
  token                  = var.create_k8s_resources ? data.aws_eks_cluster_auth.cluster.token : ""

  exec {
    api_version = "client.authentication.k8s.io/v1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      var.eks_cluster_name,
      "--region",
      var.aws_region
    ]
  }
}

# ==========================================
# PROVIDER HELM
# ==========================================

provider "helm" {
  # CORRIGIDO: Helm usa a mesma configuração do Kubernetes provider
  # NÃO usa bloco "kubernetes" aninhado!
  
  kubernetes {
    host                   = var.create_k8s_resources ? data.aws_eks_cluster.cluster.endpoint : ""
    cluster_ca_certificate = var.create_k8s_resources ? base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data) : ""
    token                  = var.create_k8s_resources ? data.aws_eks_cluster_auth.cluster.token : ""
  }
}

# ==========================================
# PROVIDER KUBECTL
# ==========================================

provider "kubectl" {
  host                   = var.create_k8s_resources ? data.aws_eks_cluster.cluster.endpoint : ""
  cluster_ca_certificate = var.create_k8s_resources ? base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data) : ""
  token                  = var.create_k8s_resources ? data.aws_eks_cluster_auth.cluster.token : ""
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      var.eks_cluster_name,
      "--region",
      var.aws_region
    ]
  }
}