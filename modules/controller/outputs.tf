output "dns_name" {
  description = "The public DNS name of the load balancer"
  value       = module.alb.this_lb_dns_name
}

output "kms_key_id" {
  description = "The unique identifier for the worker-auth key"
  value       = aws_kms_key.auth.key_id
}
