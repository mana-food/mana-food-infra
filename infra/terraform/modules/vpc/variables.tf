variable "name_prefix" {
  description = "Prefixo para nomear recursos"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block da VPC"
  type        = string
}

variable "availability_zones" {
  description = "Lista de Availability Zones"
  type        = list(string)
}

variable "public_subnets" {
  description = "Lista de CIDR blocks para subnets públicas"
  type        = list(string)
}

variable "private_subnets" {
  description = "Lista de CIDR blocks para subnets privadas"
  type        = list(string)
}

variable "database_subnets" {
  description = "Lista de CIDR blocks para subnets de banco de dados"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Habilitar NAT Gateway"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Usar apenas um NAT Gateway para todas as AZs"
  type        = bool
  default     = false
}

variable "enable_dns_hostnames" {
  description = "Habilitar DNS hostnames na VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Habilitar DNS support na VPC"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags para aplicar aos recursos"
  type        = map(string)
  default     = {}
}