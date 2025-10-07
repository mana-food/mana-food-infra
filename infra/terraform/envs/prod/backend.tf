terraform {
  backend "s3" {
    bucket  = "manafood-bucket-terraform-tfstate"
    key     = "mana-food-prod.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}