variable "name" {}
variable "runtime" { default = "python3.9" }
variable "handler" { default = "index.handler" }
variable "filename" {}

variable "timeout" {
  type    = number
  default = 10
}

variable "memory_size" {
  type    = number
  default = 256
}
