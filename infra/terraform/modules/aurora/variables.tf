variable "cluster_identifier" {}
variable "db_username" {}
variable "db_password" {
  sensitive = true
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "instance_count" {
  type    = number
  default = 1
}

variable "instance_class" {
  type    = string
  default = "db.t3.medium"
}

variable "publicly_accessible" {
  type    = bool
  default = false
}
