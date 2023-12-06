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

  identifier = "${var.name}-${var.environment}-rds-mysql"

  # All available versions: http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MySQL.html#MySQL.Concepts.VersionMgmt
  engine               = "mysql"
  engine_version       = "8.0"
  family               = "mysql8.0" # DB parameter group
  major_engine_version = "8.0"      # DB option group
  instance_class       = "db.t4g.large"

  allocated_storage     = 20
  max_allocated_storage = 100

  db_name  = "completeMysql"
  username = "complete_mysql"
  port     = 3306

  multi_az               = false
  db_subnet_group_name   = data.terraform_remote_state.vpc.outputs.database_subnet_group_name
  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  backup_retention_period         = 0
  enabled_cloudwatch_logs_exports = ["general"]
  create_cloudwatch_log_group     = true

  skip_final_snapshot = true
  deletion_protection = false

  performance_insights_enabled          = false
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  tags = local.default_tags
  db_instance_tags = {
    "Sensitive" = "low"
  }
  db_option_group_tags = {
    "Sensitive" = "low"
  }
  db_parameter_group_tags = {
    "Sensitive" = "low"
  }
  db_subnet_group_tags = {
    "Sensitive" = "low"
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