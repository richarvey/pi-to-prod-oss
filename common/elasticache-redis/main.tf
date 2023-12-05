provider aws {
    region = var.region
}

data "terraform_remote_state" vpc {
	backend = "s3"
	config = {
		region         = "eu-west-1"
		bucket         = "sqcows-terraform-bucket"
		key            = "vpc-sqcows-state.tfstate"
	}
}

