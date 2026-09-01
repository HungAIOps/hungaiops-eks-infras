output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [for subnet in aws_subnet.public_subnets : subnet.id]
}

output "private_app_subnet_ids" {
  description = "List of private application subnet IDs"
  value       = [for subnet in aws_subnet.private_app_subnets : subnet.id]
}
