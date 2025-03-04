output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = module.alb.dns_name
}

output "manufacturing_private_dns" {
  description = "Manufacturing server private DNS"
  value       = module.manufacturing.private_dns
}

output "rendezvous_private_dns" {
  description = "Rendezvous server private DNS"
  value       = module.rendezvous.private_dns
}

output "oob_private_dns" {
  description = "Owner Onboarding server private DNS"
  value       = module.owneronboarding.private_dns
}