variable "function_name" {
  description = "Nome da função Lambda"
  type        = string
}

variable "description" {
  description = "Descrição da função"
  type        = string
  default     = ""
}

variable "handler" {
  description = "Handler da função"
  type        = string
}

variable "runtime" {
  description = "Runtime da função"
  type        = string
}

variable "source_path" {
  description = "Caminho do código fonte"
  type        = string
  default     = ""
}

variable "memory_size" {
  description = "Memória em MB"
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Timeout em segundos"
  type        = number
  default     = 3
}

variable "reserved_concurrent_executions" {
  description = "Execuções concorrentes reservadas"
  type        = number
  default     = -1
}

variable "environment_variables" {
  description = "Variáveis de ambiente"
  type        = map(string)
  default     = {}
}

variable "vpc_config" {
  description = "Configuração VPC"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

variable "dead_letter_target_arn" {
  description = "ARN do target para dead letter"
  type        = string
  default     = ""
}

variable "tracing_mode" {
  description = "Modo de tracing (Active ou PassThrough)"
  type        = string
  default     = null
}

variable "layers" {
  description = "Lambda layers ARNs"
  type        = list(string)
  default     = []
}

variable "attach_policy_statements" {
  description = "Anexar policy statements customizadas"
  type        = bool
  default     = false
}

variable "policy_statements" {
  description = "Policy statements customizadas"
  type = map(object({
    effect    = string
    actions   = list(string)
    resources = list(string)
  }))
  default = {}
}

variable "log_retention_days" {
  description = "Dias de retenção dos logs"
  type        = number
  default     = 7
}

variable "create_alias" {
  description = "Criar alias"
  type        = bool
  default     = false
}

variable "alias_name" {
  description = "Nome do alias"
  type        = string
  default     = "live"
}

variable "publish" {
  description = "Publicar versão"
  type        = bool
  default     = false
}

variable "allow_api_gateway" {
  description = "Permitir API Gateway"
  type        = bool
  default     = false
}

variable "api_gateway_source_arn" {
  description = "ARN do API Gateway"
  type        = string
  default     = ""
}

variable "allow_eventbridge" {
  description = "Permitir EventBridge"
  type        = bool
  default     = false
}

variable "eventbridge_rule_arn" {
  description = "ARN da regra EventBridge"
  type        = string
  default     = ""
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

variable "error_alarm_threshold" {
  description = "Threshold de erros"
  type        = number
  default     = 1
}

variable "throttle_alarm_threshold" {
  description = "Threshold de throttles"
  type        = number
  default     = 1
}

variable "duration_alarm_threshold" {
  description = "Threshold de duração (ms)"
  type        = number
  default     = 10000
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}