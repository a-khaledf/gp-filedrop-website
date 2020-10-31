output "autoscaling_group_name" {
  value       = aws_autoscaling_group.autoscaling_group.name
  description = "The Name of the autoscaling group."
}
