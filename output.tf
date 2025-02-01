output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = module.alb.dns_name
}
output "rds_endpoints" {
  description = "RDS database endpoints"
  value = { for k, db in module.rds : k => db.db_instance_endpoint}
}