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

# Aurora PostgreSQL

resource "aws_rds_cluster" "this" {
  cluster_identifier = "${lower(replace("${var.project}-${var.environment}-aurora-pg", "/[^a-z0-9-]/", "-"))}"
  engine                    = "aurora-postgresql"
  engine_mode               = "provisioned"
  engine_version            = "17.7"
  database_name             = var.name
  master_username           = var.master_username
  master_password           = var.master_password
  db_subnet_group_name      = aws_db_subnet_group.this.name
  vpc_security_group_ids    = [aws_security_group.rds.id]
  backup_retention_period   = var.backup_retention_days
  preferred_backup_window   = "02:00-03:00"
  preferred_maintenance_window = "sun:04:00-sun:05:00"
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = "${var.project}-${var.environment}-final-snapshot"
  storage_encrypted         = true
  serverlessv2_scaling_configuration {
    min_capacity = var.min_capacity
    max_capacity = var.max_capacity
  }

  tags = {
    Name        = "${var.project}-${var.environment}-aurora-pg"
    Project     = var.project
    Environment = var.environment
  }
}

# Aurora Serverless writer

resource "aws_rds_cluster_instance" "writer" {
  identifier = replace(lower("${var.project}-${var.environment}-aurora-pg-writer"), "_", "-")
  cluster_identifier  = aws_rds_cluster.this.id
  instance_class      = "db.serverless"
  engine              = aws_rds_cluster.this.engine
  engine_version      = aws_rds_cluster.this.engine_version

  db_subnet_group_name = aws_db_subnet_group.this.name

  performance_insights_enabled = true

  tags = {
    Name        = "${var.project}-${var.environment}-aurora-pg-writer"
    Project     = var.project
    Environment = var.environment
  }
}

# Aurora Serverless v2 reader

resource "aws_rds_cluster_instance" "reader" {
  identifier         = "${var.project}-${var.environment}-aurora-pg-reader"
  cluster_identifier = aws_rds_cluster.this.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.this.engine
  engine_version     = aws_rds_cluster.this.engine_version
  db_subnet_group_name = aws_db_subnet_group.this.name

  tags = {
    Name        = "${var.project}-${var.environment}-aurora-pg-reader"
    Project     = var.project
    Environment = var.environment
  }
}
