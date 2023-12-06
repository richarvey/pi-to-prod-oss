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

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${var.name}-${var.environment}-postgres"

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = "16"
  family               = "postgres16" # DB parameter group
  major_engine_version = "16"         # DB option group
  instance_class       = "db.t4g.large"

  allocated_storage     = 20
  max_allocated_storage = 100

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  db_name  = "completePostgresql"
  username = "complete_postgresql"
  port     = 5432

  multi_az               = false
  db_subnet_group_name   = data.terraform_remote_state.vpc.outputs.database_subnet_group_name
  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  create_cloudwatch_log_group     = true

  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false

  performance_insights_enabled          = false
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60
  monitoring_role_name                  = "sqcows-rds-monitoring-role"
  monitoring_role_use_name_prefix       = true
  monitoring_role_description           = "RDS monitoring role created by sqcows terraform"

  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]

  tags = local.default_tags
  db_option_group_tags = {
    "Sensitive" = "low"
  }
  db_parameter_group_tags = {
    "Sensitive" = "low"
  }
}


################################################################################
# Supporting Resources
################################################################################

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.name}-${var.environment}-rds-postgres"
  description = "Complete PostgreSQL example security group"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  # ingress
  ingress_ipv6_cidr_blocks = data.terraform_remote_state.vpc.outputs.private_subnets_ipv6_cidr_blocks
  ingress_with_ipv6_cidr_blocks = [
	{
    	from_port   = 5432
    	to_port     = 5432
    	protocol    = "tcp"
    	description = "Postgres access from within VPC"
	}
  ]
  ingress_cidr_blocks = data.terraform_remote_state.vpc.outputs.private_subnets_cidr_blocks
  ingress_with_cidr_blocks = [
	{
    	from_port   = 5432
    	to_port     = 5432
    	protocol    = "tcp"
    	description = "Postgres access from within VPC"
	}
  ]

  tags = local.default_tags
}