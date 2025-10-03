variable "name" {}
variable "cidr_block" {}
variable "public_subnets" {
  type = list(string)
}
variable "availability_zones" {
  type = list(string)
}
