terraform {
  required_version = ">= 1.1.4"
  backend "s3" {
    region         = "eu-west-1"
    bucket         = "sqcows-terraform-bucket"
    key            = "rds-postgres-state.tfstate"
    dynamodb_table = "sqcows-rds-postgres-state"
    encrypt        = true
  }
}