locals {
  default_tags = merge(
    var.additional_tags,
    {
      Maintainer  = "sqcows"
      Owner       = var.owner
      Environment = var.environment
      ManagedBy   = "terraform"
  })
}