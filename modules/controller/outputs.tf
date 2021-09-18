output "bastion_security_group" {
  description = "The ID of the bastion security group"
  value       = one(aws_security_group.bastion[*].id)
}

output "dns_name" {
  description = "The public DNS name of the load balancer"
  value       = module.alb.lb_dns_name
}

output "ip_addresses" {
  description = "One or more private IPv4 addresses associated with the controllers"
  value       = data.aws_instances.controllers.private_ips
}

output "kms_key_id" {
  description = "The unique identifier for the worker-auth key"
  value       = aws_kms_key.auth.key_id
}

output "security_group_id" {
  description = "The ID of the controller security group"
  value       = aws_security_group.controller.id
}
