resource "aws_lb" "this" {
  name               = "${var.project}${var.environment}alb"
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [aws_security_group.alb.id]
  tags = {
    Project     = var.project
    Environment = var.environment
  }
}
