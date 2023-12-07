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

data "aws_caller_identity" "current" {}

resource "aws_opensearch_domain" "sqcows-opensearch" {
  domain_name    = var.domain_name
  engine_version = "OpenSearch_2.11"

  cluster_config {
    instance_type          = "m6g.large.search"
    zone_awareness_enabled = true
  }
  advanced_security_options {
    enabled                        = true
    anonymous_auth_enabled         = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = "root"
      master_user_password = "ChangeMe1!"
    }
  }
  encrypt_at_rest {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }
  node_to_node_encryption {
    enabled = true
  }
  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }
  vpc_options {
    subnet_ids = [
      data.terraform_remote_state.vpc.outputs.private_subnets_cidr_blocks[0],
      data.terraform_remote_state.vpc.outputs.private_subnets_cidr_blocks[1],
	  data.terraform_remote_state.vpc.outputs.private_subnets_cidr_blocks[2],
    ]

    security_group_ids = [module.security_group.security_group_id]
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  access_policies = data.aws_iam_policy_document.sqcows-opensearch.json

  tags = {
    Domain = "${var.domain_name}"
  }

  depends_on = [aws_iam_service_linked_role.sqcows-opensearch]
}

################################################################################
# Supporting Resources
################################################################################

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.name}-${var.environment}-opensearch"
  description = "OpenSearchexample security group"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  # ingress
  # ingress
  ingress_ipv6_cidr_blocks = data.terraform_remote_state.vpc.outputs.private_subnets_ipv6_cidr_blocks
  ingress_with_ipv6_cidr_blocks = [
	{
    	from_port   = 443
    	to_port     = 443
    	protocol    = "tcp"
    	description = "OpenSearch access from within VPC"
	}
  ]
  ingress_cidr_blocks = data.terraform_remote_state.vpc.outputs.private_subnets_cidr_blocks
  ingress_with_cidr_blocks = [
	{
    	from_port   = 443
    	to_port     = 443
    	protocol    = "tcp"
    	description = "OpenSearch access from within VPC"
	}
  ]

  tags = local.default_tags
}
resource "aws_iam_service_linked_role" "sqcows-opensearch" {
  aws_service_name = "opensearchservice.amazonaws.com"
}

data "aws_iam_policy_document" "sqcows-opensearch" {
  statement {
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["es:*"]
    resources = ["arn:aws:es:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.domain_name}/*"]
  }
}