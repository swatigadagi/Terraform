data "aws_ssm_parameter" "backend_port" {
  name = "/terraform/PORT"
}

resource "aws_ecs_cluster" "this" {
  name = "${var.project}-${var.environment}-cluster"

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}


resource "aws_security_group" "ecs" {
  name   = "${var.project}-${var.environment}-ecs-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = tonumber(data.aws_ssm_parameter.backend_port.value)
    to_port     = tonumber(data.aws_ssm_parameter.backend_port.value)
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}
