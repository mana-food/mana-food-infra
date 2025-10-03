variable "cluster_name" {}
variable "cluster_role_arn" {}
variable "node_role_arn" {}
variable "subnet_ids" {
  type = list(string)
}
variable "desired_capacity" { default = 2 }
variable "max_size" { default = 3 }
variable "min_size" { default = 1 }
