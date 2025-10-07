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

# ==========================================
# IAM USER MANAGEMENT (se necessário)
# ==========================================

# Se o usuário já existe, use data source em vez de resource
data "aws_iam_user" "existing_terraform_user" {
  user_name = "manafood-terraform"
}

# Apenas anexar políticas se o usuário existir
resource "aws_iam_user_policy_attachment" "administrator_access" {
  count      = length(data.aws_iam_user.existing_terraform_user.user_name) > 0 ? 1 : 0
  user       = data.aws_iam_user.existing_terraform_user.user_name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Ou, se preferir criar um novo usuário:
# resource "aws_iam_user" "manafood_terraform" {
#   name = "manafood-terraform"
#   
#   tags = local.common_tags
# }