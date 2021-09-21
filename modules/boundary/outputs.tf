output "auto_scaling_group_name" {
  description = "The name of the controller Auto Scaling group"
  value       = module.autoscaling.autoscaling_group_name
}
