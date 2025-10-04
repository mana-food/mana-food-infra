# variable "aws_region" {
#   default = "us-east-1"
# }

# variable "db_username" {}
# variable "db_password" {
#   sensitive = true
# }
#
# variable "subnets" {
#   type = list(string)
# }
#
# variable "eks_cluster_role_arn" {}
# variable "eks_node_role_arn" {}

### Novas variáveis
variable "aws_region" {
  description = "Região AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment deve ser dev, staging ou prod."
  }
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "mana-food"
}

variable "owner" {
  description = "Responsável pelo projeto"
  type        = string
  default     = "DevOps Team"
}

variable "cost_center" {
  description = "Centro de custo"
  type        = string
  default     = "Engineering"
}

# VPC Variables
variable "vpc_cidr" {
  description = "CIDR block da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Zonas de disponibilidade"
  type        = string
  default     = "us-east-1a"
}

# EKS Variables
variable "eks_cluster_version" {
  description = "Versão do Kubernetes"
  type        = string
  default     = "1.28"
}

variable "eks_node_instance_types" {
  description = "Tipos de instância dos nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_node_desired_size" {
  description = "Número desejado de nodes"
  type        = number
  default     = 3
}

variable "eks_node_min_size" {
  description = "Número mínimo de nodes"
  type        = number
  default     = 2
}

variable "eks_node_max_size" {
  description = "Número máximo de nodes"
  type        = number
  default     = 5
}

# Aurora MySQL Variables
variable "aurora_engine_version" {
  description = "Versão do Aurora MySQL"
  type        = string
  default     = "8.0.mysql_aurora.3.05.2"
}

variable "aurora_instance_class" {
  description = "Classe da instância Aurora"
  type        = string
  default     = "db.r6g.large"
}

variable "aurora_instances_count" {
  description = "Número de instâncias Aurora"
  type        = number
  default     = 2
}

variable "database_name" {
  description = "Nome do banco de dados"
  type        = string
  default     = "db_manafood"
}

variable "database_master_username" {
  description = "Usuário master do banco"
  type        = string
  default     = "admin"
  sensitive   = true
}

# Lambda Variables
variable "lambda_runtime" {
  description = "Runtime da Lambda"
  type        = string
  default     = "dotnet8"
}

variable "lambda_memory_size" {
  description = "Memória da Lambda em MB"
  type        = number
  default     = 512
}

variable "lambda_timeout" {
  description = "Timeout da Lambda em segundos"
  type        = number
  default     = 30
}

variable "vpc_config" {
  description = "Configuração opcional de VPC para a função Lambda"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}
