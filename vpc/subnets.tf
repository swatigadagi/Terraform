resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project}-${var.environment}-public-${count.index}"
    Tier        = "public"
    Environment = var.environment
  }
}

resource "aws_subnet" "private_app" {
  count             = length(var.private_app_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_app_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name        = "${var.project}-${var.environment}-app-${count.index}"
    Tier        = "app"
    Environment = var.environment
  }
}
resource "aws_subnet" "private_worker" {
  count             = length(var.private_worker_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_worker_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name        = "${var.project}-${var.environment}-worker-${count.index}"
    Tier        = "worker"
    Environment = var.environment
  }
}