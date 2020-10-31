output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "The VPC ID of the VPC created."
}

output "public_subnet_id" {
  value       = aws_subnet.public_subnet.id
  description = "The Public Subnet ID."
}
