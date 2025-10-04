variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
}

variable "cluster_version" {
  description = "Versão do Kubernetes"
  type        = string
  default     = "1.28"
}

variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "subnet_ids" {
  description = "IDs das subnets"
  type        = list(string)
}

variable "node_groups" {
  description = "Configuração dos node groups"
  type = map(object({
    desired_size   = number
    min_size       = number
    max_size       = number
    instance_types = list(string)
    capacity_type  = string
    labels         = map(string)
    tags           = map(string)
  }))
  default = {}
}

variable "cluster_log_retention_days" {
  description = "Dias de retenção dos logs"
  type        = number
  default     = 7
}

variable "vpc_cni_addon_version" {
  description = "Versão do addon VPC CNI"
  type        = string
  default     = ""
}

variable "coredns_addon_version" {
  description = "Versão do addon CoreDNS"
  type        = string
  default     = ""
}

variable "kube_proxy_addon_version" {
  description = "Versão do addon kube-proxy"
  type        = string
  default     = ""
}

variable "ebs_csi_addon_version" {
  description = "Versão do addon EBS CSI"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}