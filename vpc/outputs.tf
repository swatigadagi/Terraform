output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_app_subnet_ids" {
  value = aws_subnet.private_app[*].id
}
output "endpoint_security_group_ids" {
  value = aws_security_group.endpoints[*].id
}
output "default_security_group_id" {
  value       = aws_security_group.endpoints.id
  description = "The security group ID for the VPC endpoints"
}
