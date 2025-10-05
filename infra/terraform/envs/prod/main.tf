terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}

# REMOVER todos os recursos IAM duplicados
# REMOVER recursos K8s (serão aplicados via YAML)

# Manter apenas se necessário para testes
resource "kubernetes_manifest" "api_configmap" {
  count      = var.create_k8s_resources ? 1 : 0
  depends_on = [module.eks]
  manifest   = yamldecode(file("${path.module}/../../../k8s/api-configmap.yaml"))
}