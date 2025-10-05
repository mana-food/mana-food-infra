terraform {
  backend "s3" {
    bucket         = "manafood-bucket-terraform-tfstate"     # nome do bucket que você criou
    key            = "manafood-bucket-terraform.tfstate"     # caminho do arquivo no bucket
    region         = "us-east-1"                      # região do bucket
    encrypt        = true                             # criptografa o estado no S3
  }
}