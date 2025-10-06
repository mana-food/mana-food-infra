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

# IMPORTAR IAM User existente em vez de criar
import {
  to = aws_iam_user.manafood_terraform
  id = "manafood-terraform"
}

resource "aws_iam_user" "manafood_terraform" {
  name = "manafood-terraform"
}

resource "aws_iam_user_policy_attachment" "administrator_access" {
  user       = aws_iam_user.manafood_terraform.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# EKS
resource "aws_iam_user_policy_attachment" "eks_cluster" {
  user       = aws_iam_user.manafood_terraform.name
  policy_arn = var.policy_eks_cluster
}

resource "aws_iam_user_policy_attachment" "eks_service" {
  user       = aws_iam_user.manafood_terraform.name
  policy_arn = var.policy_eks_service
}

resource "aws_iam_user_policy_attachment" "eks_worker" {
  user       = aws_iam_user.manafood_terraform.name
  policy_arn = var.policy_eks_worker
}

# VPC
resource "aws_iam_user_policy_attachment" "vpc" {
  user       = aws_iam_user.manafood_terraform.name
  policy_arn = var.policy_vpc
}

# RDS (Aurora MySQL)
resource "aws_iam_user_policy_attachment" "rds" {
  user       = aws_iam_user.manafood_terraform.name
  policy_arn = var.policy_rds
}

# Lambda
resource "aws_iam_user_policy_attachment" "lambda" {
  user       = aws_iam_user.manafood_terraform.name
  policy_arn = var.policy_lambda
}

# IAM - somente leitura
resource "aws_iam_user_policy_attachment" "iam_readonly" {
  user       = aws_iam_user.manafood_terraform.name
  policy_arn = var.policy_iam_readonly
}

resource "aws_iam_user_policy_attachment" "eks_worker_policy" {
  user       = aws_iam_user.manafood_terraform.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}