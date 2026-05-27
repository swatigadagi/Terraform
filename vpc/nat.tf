resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? length(var.azs) : 0
  domain = "vpc"
  tags = {
    Name        = "${var.project}-${var.environment}-nat-eip-${count.index}"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_nat_gateway" "this" {
  count         = var.enable_nat_gateway ? length(var.azs) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags = {
    Name        = "${var.project}-${var.environment}-nat-${count.index}"
    Environment = var.environment
    Project     = var.project
  }
  depends_on = [aws_internet_gateway.this]
}
