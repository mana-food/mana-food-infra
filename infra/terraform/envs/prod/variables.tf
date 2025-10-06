# ==========================================
# CONFIGURAÇÕES BÁSICAS
# ==========================================

variable "aws_region" {
  description = "Região da AWS para deploy"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "mana-food"  
}

variable "availability_zones" {
  description = "Zonas de disponibilidade"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# ==========================================
# CONFIGURAÇÕES DE INFRAESTRUTURA
# ==========================================

variable "eks_cluster_name" {
  description = "Nome base para o cluster EKS"
  type        = string
  default     = "mana-food-eks"  # CORRIGIDO: consistência com project_name
}

variable "bucket_state_name" {
  description = "Nome do bucket S3 para o estado remoto do Terraform"
  type        = string
  sensitive   = true
}

# ==========================================
# CONFIGURAÇÕES DE RECURSOS KUBERNETES
# ==========================================

variable "create_k8s_resources" {
  description = "Se true, cria recursos Kubernetes (ConfigMap, Secret, Deployment, Service, HPA). False para criar apenas infraestrutura"
  type        = bool
  default     = false # Alterado para false para evitar criar recursos K8s no mesmo apply da infra
}

# ==========================================
# POLÍTICAS IAM (TODAS COM DEFAULT)
# ==========================================

variable "policy_eks_cluster" {
  description = "ARN da política para cluster EKS"
  type        = string
  default     = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  sensitive   = false  # CORRIGIDO: ARNs públicos não precisam ser sensitive
}

variable "policy_eks_service" {
  description = "ARN da política para serviços EKS"
  type        = string
  default     = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  sensitive   = false
}

variable "policy_eks_worker" {
  description = "ARN da política para worker nodes EKS"
  type        = string
  default     = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  sensitive   = false
}

variable "policy_vpc" {
  description = "ARN da política para VPC"
  type        = string
  default     = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
  sensitive   = false
}

variable "policy_rds" {
  description = "ARN da política para RDS"
  type        = string
  default     = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
  sensitive   = false
}

variable "policy_lambda" {
  description = "ARN da política para Lambda"
  type        = string
  default     = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
  sensitive   = false
}

variable "policy_iam_readonly" {
  description = "ARN da política IAM ReadOnly"
  type        = string
  default     = "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
  sensitive   = false
}