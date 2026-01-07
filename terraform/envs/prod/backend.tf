terraform {
  backend "s3" {
    bucket         = "fiap-tf-state-mana-food"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    # dynamodb_table = "terraform-state-lock"
  }
}