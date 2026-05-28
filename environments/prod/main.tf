terraform {
  backend "s3" {
    bucket  = "backend-workers-node"
    key     = "terraform/terraform.tfstate"
    region  = "ap-southeast-2"
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
  azs                    = ["ap-southeast-2a", "ap-southeast-2b"]
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
  container_port  = var.container_port
  certificate_arn = var.certificate_arn
  domain_name = var.domain_name
 }

# ECS

module "ecs" {
  source = "../../ecs"

  project     = local.project
  environment = local.environment
  aws_region  = local.aws_region
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_app_subnet_ids
  container_port  = var.container_port 
  container_image = module.ecr_backend.repository_url
  cpu           = "8192"
  memory        = "16384"
  desired_count = 1
  alb_security_group_id = module.alb.alb_security_group_id
  alb_target_group_arn = module.alb.target_group_arn
  listener_arn = module.alb.listener_arn
  execution_role_arn = module.iam.ecs_full_role_arn
  task_role_arn      = module.iam.ecs_full_role_arn
}

# EC2 Instance


module "ec2" {
  source = "../../ec2"

  project     = local.project
  environment = local.environment
  vpc_id = module.vpc.vpc_id
  allowed_ssh_cidr = var.allowed_ssh_cidr
  instance_type = "t3.micro"
  public_subnet_id = module.vpc.public_subnet_ids[0]
  rds_security_group_id = module.rds.rds_security_group_id
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
  backup_retention_days = 1
  deletion_protection   = true
  skip_final_snapshot   = false
}

# CodeBuild

module "codebuild" {
  source = "../../codebuild"
  project     = local.project
  environment = local.environment
  bucket_name = module.frontend_s3.bucket_name
 # environment = local.environment
  deploy_type = "ecs"
  ssm_path = "/seaverse/prod/"
  artifact_bucket =module.frontend_s3.bucket_name
}
