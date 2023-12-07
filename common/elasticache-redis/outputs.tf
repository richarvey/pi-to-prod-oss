output "configuration_endpoint_address" {
  value = "${aws_elasticache_replication_group.redis_cache.configuration_endpoint_address}"
}