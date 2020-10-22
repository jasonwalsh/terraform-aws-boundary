output "iam_instance_profile" {
  description = <<EOF
The name or the Amazon Resource Name (ARN) of the instance profile
associated with the IAM role for the instance. The instance profile
contains the IAM role.
EOF

  value = aws_iam_instance_profile.boundary.name
}

output "load_balancer_address" {
  description = "The public DNS name of the load balancer"
  value       = module.alb.this_lb_dns_name
}
