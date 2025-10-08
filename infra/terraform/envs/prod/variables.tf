variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "mana-food"
}

variable "bucket_state_name" {
  description = "S3 bucket for Terraform state"
  type        = string
  sensitive   = true
}