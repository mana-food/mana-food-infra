provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "prod"
      Project     = "mana-food"
      ManagedBy   = "Terraform"
    }
  }
}