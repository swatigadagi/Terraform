data "aws_region" "current" {}

# Interface endpoint services
data "aws_vpc_endpoint_service" "interface" {
  for_each = toset(var.interface_endpoints)
  service  = each.value
}

# S3 Gateway Endpoint (for all private RTs)

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = concat(
    aws_route_table.private_app[*].id,
    aws_route_table.private_worker[*].id
  )

  tags = {
    Name        = "${var.project}-${var.environment}-s3-endpoint"
    Environment = var.environment
    Project     = var.project
  }
}
locals {
  all_private_subnets = concat(
    aws_subnet.private_app,
    aws_subnet.private_worker
  )
  unique_subnets_per_az = {
    for subnet in local.all_private_subnets :
    subnet.availability_zone => subnet.id...
  }
  endpoint_subnets = [
    for subnet_list in values(local.unique_subnets_per_az) :
    subnet_list[0]
  ]
}

resource "aws_vpc_endpoint" "interface" {
  for_each = data.aws_vpc_endpoint_service.interface

  vpc_id            = aws_vpc.this.id
  service_name      = each.value.service_name
  vpc_endpoint_type = "Interface"
  subnet_ids = local.endpoint_subnets
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true
  tags = {
    Name        = "${var.project}-${var.environment}-${each.key}-endpoint"
    Environment = var.environment
    Project     = var.project
  }
}
