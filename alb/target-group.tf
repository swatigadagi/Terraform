resource "aws_lb_target_group" "backend" {
  name        = "${var.project}${var.environment}backend"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
  path                = "/api/v1/health"  # or your real endpoint
  protocol            = "HTTP"
  matcher             = "200"
  interval            = 30
  timeout             = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
}

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "worker" {
  name        = "${var.project}${var.environment}worker"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
  path                = "/health"   # or your real endpoint
  protocol            = "HTTP"
  matcher             = "200"
  interval            = 30
  timeout             = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
}

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}