terraform {
  backend "s3" {
    bucket  = "backend-workers-node"
    key     = "terraform/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.region
}

# Locals

locals {
  project     = var.project
  environment = var.environment
  aws_region  = var.region
}

# VPC
module "vpc" {
  source = "../../vpc"

  region      = var.region
  project     = local.project
  environment = local.environment  
  vpc_cidr               = "10.0.0.0/16"
  azs                    = ["us-east-1a", "us-east-1b"]
  public_subnets         = ["10.0.1.0/24", "10.0.2.0/24"]
  private_app_subnets    = ["10.0.10.0/24", "10.0.11.0/24"]
  enable_nat_gateway = true
  interface_endpoints = [
    "ecr.api",
    "ecr.dkr",
    "ssm",
    "ec2messages",
    "ssmmessages",
    "logs"
  ]
}

# ECR

module "ecr_backend" {
  source = "../../ecr"

  project     = "${local.project}-backend"
  environment = local.environment
}

# S3

module "frontend_s3" {
  source = "../../s3"

  project     = local.project
  environment = local.environment

}
resource "aws_s3_bucket_policy" "frontend_cloudfront_access" {
  bucket = module.frontend_s3.bucket_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontAccess"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${module.frontend_s3.bucket_arn}/*"
        Condition = {
          StringEquals = {
            "aws:SourceArn" = module.cloudfront.distribution_arn
          }
        }
      }
    ]
  })
}

# IAM

module "iam" {
  source = "../../iam"

  project     = local.project
  environment = local.environment
  ecr_repository_arn = module.ecr_backend.repository_arn
}

# ALB

module "alb" {
  source = "../../alb"

  project     = local.project
  environment = local.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  certificate_arn = var.certificate_arn
  container_port  = var.container_port
}

# ECS

module "ecs" {
  source = "../../ecs"

  project     = local.project
  environment = local.environment
  aws_region  = local.aws_region
  listener_arn = module.alb.listener_https_arn
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_app_subnet_ids
  container_port  = var.container_port 
  container_image = module.ecr_backend.repository_url
  cpu           = "8192"
  memory        = "16384"
  desired_count = 1
  alb_security_group_id = module.alb.alb_security_group_id
  alb_target_group_arn = module.alb.target_group_arn
  execution_role_arn = module.iam.ecs_full_role_arn
  task_role_arn      = module.iam.ecs_full_role_arn
}

# EC2 Instance


module "ec2" {
  source = "../../ec2"

#  project     = local.project
#  environment = local.environment
#  instance_type = "t3.micro"
#  vpc_id = module.vpc.vpc_id
#  public_subnet_id = module.vpc.public_subnet_ids[0]
#  rds_security_group_id = module.rds.rds_security_group_id
#  allowed_ssh_cidr = var.allowed_ssh_cidr
}

# RDS — Aurora PostgreSQL Serverless

module "rds" {
  source = "../../rds"

  project     = local.project
  environment = local.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_app_subnet_ids
  ecs_security_group_id = module.ecs.ecs_security_group_id
  name         = var.name
  master_username = var.master_username
  master_password = var.master_password
  min_capacity = tonumber(var.min_capacity)
  max_capacity = tonumber(var.max_capacity)
  backup_retention_days = 7
  deletion_protection   = true
  skip_final_snapshot   = false
}

# CodeBuild

module "codebuild" {
  source = "../../codebuild"
  project     = local.project
  environment = local.environment
  bucket_name = module.frontend_s3.bucket_name
  environment = local.environment
  deploy_type = "ecs"
  ssm_path = "/seaverse/prod/"
  artifact_bucket =module.frontend_s3.bucket_name
}
