variable "aws_region" {
  default = "us-east-1"
}

variable "db_username" {}
variable "db_password" {
  sensitive = true
}

variable "subnets" {
  type = list(string)
}

variable "eks_cluster_role_arn" {}
variable "eks_node_role_arn" {}
