output "instances_public_ips" {
  value       = data.aws_instances.created.public_ips
  description = "The public IPs of the instances created."
}

output "instances_private_ips" {
  value       = data.aws_instances.created.private_ips
  description = "The public IPs of the instances created."
}
