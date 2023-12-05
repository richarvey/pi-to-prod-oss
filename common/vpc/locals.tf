locals {
  vpc_cidr = "20.10.0.0/16" # 10.0.0.0/8 is reserved for EC2-Classic
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
  default_tags = merge(
    var.additional_tags,
    {
      Maintainer  = "sqcows"
      Owner       = var.owner
      Environment = var.environment
      ManagedBy   = "terraform"
  })
}