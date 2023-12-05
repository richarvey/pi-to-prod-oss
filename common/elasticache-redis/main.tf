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

resource "aws_elasticache_replication_group" "example" {
  replication_group_id = "${var.name}-${var.environment}-redis"
  description = "Redis cluster for projects"
  engine               = "redis"
  node_type            = "cache.t4g.micro"
  num_node_groups     = 2
  replicas_per_node_group = 1
  automatic_failover_enabled = true
  parameter_group_name = "default.redis7.cluster.on"
  engine_version       = "7.1"
  subnet_group_name    = data.terraform_remote_state.vpc.outputs.elasticache_subnet_group_name
  security_group_ids = [module.security_group.security_group_id]
  apply_immediately          = true
  auto_minor_version_upgrade = true
  maintenance_window         = "tue:06:30-tue:07:30"
  snapshot_window            = "01:00-02:00"
  port                 = 6379
}

################################################################################
# Supporting Resources
################################################################################

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.name}-${var.environment}-redis"
  description = "Redis example security group"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 6379
      to_port     = 6379
      protocol    = "tcp"
      description = "Redis access from within VPC"
      cidr_blocks = data.terraform_remote_state.vpc.outputs.vpc_cidr_block
    },
  ]

  tags = local.default_tags
}