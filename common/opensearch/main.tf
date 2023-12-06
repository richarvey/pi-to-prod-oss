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




################################################################################
# Supporting Resources
################################################################################

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.name}-${var.environment}-rds-mysql"
  description = "MySQL PostgreSQL example security group"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  # ingress
  # ingress
  ingress_ipv6_cidr_blocks = data.terraform_remote_state.vpc.outputs.private_subnets_ipv6_cidr_blocks
  ingress_with_ipv6_cidr_blocks = [
	{
    	from_port   = 3306
    	to_port     = 3306
    	protocol    = "tcp"
    	description = "MySQL access from within VPC"
	}
  ]
  ingress_cidr_blocks = data.terraform_remote_state.vpc.outputs.private_subnets_cidr_blocks
  ingress_with_cidr_blocks = [
	{
    	from_port   = 3306
    	to_port     = 3306
    	protocol    = "tcp"
    	description = "MySQL access from within VPC"
	}
  ]

  tags = local.default_tags
}