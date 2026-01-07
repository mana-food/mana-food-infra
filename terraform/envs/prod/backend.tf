terraform {
  backend "s3" {
    bucket  = "manafood"
    key     = "mana-food-prod.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}