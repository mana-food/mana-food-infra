variable "aws_region" {
  description = "Região da AWS para deploy."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto."
  type        = string
  default     = "manafood"
}

variable "eks_cluster_name" {
  description = "Nome base para o recurso eks cluster"
  type        = string
  default     = "manafood-eks"
}


variable "db_master_username" {
  description = "Nome de usuário mestre do Aurora."
  type        = string
  sensitive   = true
}

variable "db_master_password" {
  description = "Senha mestre do Aurora."
  type        = string
  sensitive   = true
}

variable "bucket_state_name" {
  description = "Nome do bucket S3 para o estado remoto do Terraform."
  type        = string
  sensitive   = true
}


variable "policy_eks_cluster" {
  type        = string
  sensitive   = true
  default     = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

variable "policy_eks_service" {
  type        = string
  sensitive   = true
  default     = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

variable "policy_eks_worker" {
  type        = string
  sensitive   = true
  default     = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

variable "policy_vpc" {
  type        = string
  sensitive   = true
  default     = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

variable "policy_rds" {
  type        = string
  sensitive   = true
  default     = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

variable "policy_lambda" {
  type        = string
  sensitive   = true
  default     = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
}

variable "policy_iam_readonly" {
  type        = string
  sensitive   = true
  default     = "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
}
