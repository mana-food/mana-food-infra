variable "cluster_identifier" {
  description = "Identificador do cluster"
  type        = string
}

variable "engine" {
  description = "Engine do Aurora"
  type        = string
  default     = "aurora-mysql"
}

variable "engine_version" {
  description = "Versão do engine"
  type        = string
}

variable "database_name" {
  description = "Nome do banco de dados"
  type        = string
}

variable "master_username" {
  description = "Usuário master"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "subnet_ids" {
  description = "IDs das subnets"
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks permitidos"
  type        = list(string)
  default     = []
}

variable "allowed_security_group_ids" {
  description = "Security groups permitidos"
  type        = list(string)
  default     = []
}

variable "instance_class" {
  description = "Classe da instância"
  type        = string
}

variable "instances_count" {
  description = "Número de instâncias"
  type        = number
  default     = 1
}

variable "backup_retention_period" {
  description = "Dias de retenção de backup"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "Janela de backup"
  type        = string
  default     = "03:00-04:00"
}

variable "preferred_maintenance_window" {
  description = "Janela de manutenção"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "enabled_cloudwatch_logs_exports" {
  description = "Logs para exportar"
  type        = list(string)
  default     = []
}

variable "kms_key_id" {
  description = "KMS key ID"
  type        = string
  default     = ""
}

variable "deletion_protection" {
  description = "Proteção contra deleção"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Pular snapshot final"
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Aplicar mudanças imediatamente"
  type        = bool
  default     = false
}

variable "monitoring_interval" {
  description = "Intervalo de monitoramento"
  type        = number
  default     = 0
}

variable "performance_insights_enabled" {
  description = "Habilitar Performance Insights"
  type        = bool
  default     = false
}

variable "performance_insights_retention_period" {
  description = "Retenção do Performance Insights"
  type        = number
  default     = 7
}

variable "auto_minor_version_upgrade" {
  description = "Auto upgrade de versão minor"
  type        = bool
  default     = true
}

variable "cluster_parameters" {
  description = "Parâmetros do cluster"
  type        = list(map(string))
  default     = []
}

variable "instance_parameters" {
  description = "Parâmetros das instâncias"
  type        = list(map(string))
  default     = []
}

variable "serverlessv2_max_capacity" {
  description = "Capacidade máxima ServerlessV2"
  type        = number
  default     = 1.0
}

variable "serverlessv2_min_capacity" {
  description = "Capacidade mínima ServerlessV2"
  type        = number
  default     = 0.5
}

variable "secret_recovery_window_days" {
  description = "Dias de recuperação do secret"
  type        = number
  default     = 7
}

variable "create_cloudwatch_alarms" {
  description = "Criar alarmes CloudWatch"
  type        = bool
  default     = false
}

variable "alarm_actions" {
  description = "Ações dos alarmes"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}