# ==========================================
# CONFIGURAÇÕES BÁSICAS
# ==========================================

variable "aws_region" {
  description = "Região da AWS para deploy"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "Região AWS deve estar no formato correto (ex: us-east-1)."
  }
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "mana-food"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Nome do projeto deve conter apenas letras minúsculas, números e hífens."
  }
}

variable "environment" {
  description = "Ambiente de deploy"
  type        = string
  default     = "prod"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Ambiente deve ser dev, staging ou prod."
  }
}

variable "availability_zones" {
  description = "Zonas de disponibilidade"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# ==========================================
# CONFIGURAÇÕES DE REDE
# ==========================================

variable "vpc_cidr" {
  description = "CIDR block para VPC"
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR deve ser um bloco CIDR válido."
  }
}

variable "public_subnets" {
  description = "CIDRs das subnets públicas"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "CIDRs das subnets privadas"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

# ==========================================
# CONFIGURAÇÕES EKS
# ==========================================

variable "eks_cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
  default     = "mana-food-eks"
}

variable "eks_cluster_version" {
  description = "Versão do Kubernetes"
  type        = string
  default     = "1.32"
}

variable "eks_instance_types" {
  description = "Tipos de instância para worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_desired_size" {
  description = "Número desejado de worker nodes"
  type        = number
  default     = 2
  
  validation {
    condition     = var.eks_desired_size >= 1 && var.eks_desired_size <= 10
    error_message = "Número desejado deve estar entre 1 e 10."
  }
}

variable "eks_min_size" {
  description = "Número mínimo de worker nodes"
  type        = number
  default     = 1
}

variable "eks_max_size" {
  description = "Número máximo de worker nodes"
  type        = number
  default     = 5
}

# ==========================================
# CONFIGURAÇÕES AURORA
# ==========================================

variable "aurora_engine_version" {
  description = "Versão do Aurora MySQL"
  type        = string
  default     = "8.0.mysql_aurora.3.10.1"
}

variable "aurora_min_capacity" {
  description = "Capacidade mínima do Aurora Serverless"
  type        = number
  default     = 0.5
}

variable "aurora_max_capacity" {
  description = "Capacidade máxima do Aurora Serverless"
  type        = number
  default     = 2.0
}

variable "aurora_database_name" {
  description = "Nome do banco de dados"
  type        = string
  default     = "appdb"
  
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.aurora_database_name))
    error_message = "Nome do banco deve começar com letra e conter apenas letras, números e underscore."
  }
}

variable "aurora_backup_retention_period" {
  description = "Período de retenção de backup em dias"
  type        = number
  default     = 7
  
  validation {
    condition     = var.aurora_backup_retention_period >= 1 && var.aurora_backup_retention_period <= 35
    error_message = "Período de retenção deve estar entre 1 e 35 dias."
  }
}

# ==========================================
# CONFIGURAÇÕES LAMBDA
# ==========================================

variable "lambda_runtime" {
  description = "Runtime da função Lambda"
  type        = string
  default     = "dotnet8"
}

variable "lambda_timeout" {
  description = "Timeout da função Lambda em segundos"
  type        = number
  default     = 30
  
  validation {
    condition     = var.lambda_timeout >= 1 && var.lambda_timeout <= 900
    error_message = "Timeout deve estar entre 1 e 900 segundos."
  }
}

variable "lambda_memory_size" {
  description = "Memória da função Lambda em MB"
  type        = number
  default     = 512
  
  validation {
    condition     = var.lambda_memory_size >= 128 && var.lambda_memory_size <= 10240
    error_message = "Memória deve estar entre 128 e 10240 MB."
  }
}

# ==========================================
# CONFIGURAÇÕES DE SEGURANÇA
# ==========================================

variable "allowed_cidr_blocks" {
  description = "Blocos CIDR permitidos para acesso ao EKS"
  type        = list(string)
  default     = ["0.0.0.0/0"] # ALTERE para IPs específicos em produção
}

variable "enable_cluster_creator_admin_permissions" {
  description = "Habilitar permissões de admin para o criador do cluster"
  type        = bool
  default     = true
}

# ==========================================
# CONFIGURAÇÕES DE MONITORAMENTO
# ==========================================

variable "cloudwatch_log_retention" {
  description = "Período de retenção dos logs do CloudWatch em dias"
  type        = number
  default     = 14
  
  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653
    ], var.cloudwatch_log_retention)
    error_message = "Período de retenção deve ser um valor válido do CloudWatch."
  }
}

# ==========================================
# CONFIGURAÇÕES DE ESTADO
# ==========================================

variable "bucket_state_name" {
  description = "Nome do bucket S3 para o estado remoto do Terraform"
  type        = string
  sensitive   = true
}

# ==========================================
# CONFIGURAÇÕES DE RECURSOS KUBERNETES
# ==========================================

variable "create_k8s_resources" {
  description = "Se deve criar recursos Kubernetes via Terraform"
  type        = bool
  default     = false
}

# ==========================================
# POLÍTICAS IAM - REMOVIDAS POIS SÃO PADRÃO AWS
# ==========================================

# ==========================================
# TAGS PADRÃO
# ==========================================

variable "additional_tags" {
  description = "Tags adicionais para aplicar aos recursos"
  type        = map(string)
  default     = {}
}

locals {
  common_tags = merge({
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    CreatedAt   = formatdate("YYYY-MM-DD", timestamp())
  }, var.additional_tags)
}