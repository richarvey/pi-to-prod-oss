terraform {
  required_version = ">= 1.1.4"
  backend "s3" {
    region         = "eu-west-1"
    bucket         = "sqcows-terraform-bucket"
    key            = "ecs-state.tfstate"
    dynamodb_table = "sqcows-ecs-state"
    encrypt        = true
  }
}