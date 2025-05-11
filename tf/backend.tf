# TERRAFORM STATE (S3 + DYNAMODB TABLE)
terraform {
  backend "s3" {
    bucket         = "terraform-state-jrr"
    key            = "eks/infrastructure.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-lock-jrr"
    encrypt        = true
  }
}
