variable "aws_region" {
  description = "Região da AWS para deploy."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome base para os recursos."
  type        = string
  default     = "dotnet-app"
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

variable "projectName" {
  default = "eks-manafood"
}

variable "labRole" {
  default = "arn:aws:iam::239569854352:role/LabRole"
}

variable "accessConfig" {
  default = "API_AND_CONFIG_MAP"
}

variable "nodeGroup" {
  default = "manafood-node-group"
}

variable "instanceType" {
  default = "t3.medium"
}

variable "principalArn" {
  default = "arn:aws:iam::239569854352:role/voclabs"
}

variable "policyArn" {
  default = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
}