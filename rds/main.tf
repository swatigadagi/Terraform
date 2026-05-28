# DB Subnet Group

resource "aws_db_subnet_group" "this" {
  name = "${var.project}-${var.environment}-aurora-pg"
  subnet_ids  = var.private_subnet_ids

  tags = {
    Name        = "${var.project}-${var.environment}-rds-subnet-group"
    Project     = var.project
    Environment = var.environment
  }
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name        = "${var.project}-${var.environment}-rds-sg"
  description = "Allow PostgreSQL access from ECS and Worker SG"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL from ECS + Worker SG"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"

    security_groups = [
      var.ecs_security_group_id,
    ]
  }
  ingress {
    description = "SSH access (not applicable for RDS)"
    from_port   = 22
    to_port     = 22
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
    Name        = "${var.project}-${var.environment}-rds-sg"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_db_instance" "this" {
  identifier = "${var.project}-${var.environment}-postgres"
  engine         = "postgres"
  engine_version = "15"
  instance_class = "db.t3.micro"   # FREE TIER eligible
  allocated_storage = 20
  storage_type      = "gp2"
  db_name  = var.name
  username = var.master_username
  password = var.master_password
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.this.name
  backup_retention_period = 0   # IMPORTANT for free tier
  skip_final_snapshot     = true
  publicly_accessible = false
  tags = {
    Name        = "${var.project}-${var.environment}-postgres"
    Project     = var.project
    Environment = var.environment
  }
}
