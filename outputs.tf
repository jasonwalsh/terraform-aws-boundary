output "dns_name" {
  description = "The public DNS name of the controller load balancer"
  value       = module.controllers.dns_name
}
