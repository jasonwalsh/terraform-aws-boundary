output "auto_scaling_group_name" {
  description = "The name of the controller Auto Scaling group"
  value       = module.autoscaling.this_autoscaling_group_name
}
