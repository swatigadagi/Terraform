terraform {
  backend "s3" {
    bucket  = "backend-workers-node"
    key     = "Seaverse-terraform/terraform/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.region
}

################################################
# Locals
################################################

locals {
  project     = var.project
  environment = var.environment
  aws_region  = var.region
}

################################################
# 1️⃣ VPC
################################################

module "vpc" {
  source = "../../modules/vpc"

  region      = var.region
  project     = local.project
  environment = local.environment  

  vpc_cidr               = "10.0.0.0/16"
  azs                    = ["us-east-1a", "us-east-1b"]
  public_subnets         = ["10.0.1.0/24", "10.0.2.0/24"]
  private_app_subnets    = ["10.0.10.0/24", "10.0.11.0/24"]
  private_worker_subnets = ["10.0.20.0/24", "10.0.21.0/24"]
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

################################################
# 2️⃣ ECR
################################################

module "ecr_backend" {
  source = "../../modules/ecr"

  project     = "${local.project}-backend"
  environment = local.environment
}


################################################
# 3️⃣ S3 (Frontend bucket)
################################################

module "frontend_s3" {
  source = "../../modules/s3"

  project     = local.project
  environment = local.environment

}

# ✅ Bucket policy should come AFTER modules
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
################################################
# 4️⃣ CloudFront
################################################

module "cloudfront" {
  source = "../../modules/cloudfront"

  project     = local.project
  environment = local.environment

  bucket_name                 = module.frontend_s3.bucket_name
  bucket_regional_domain_name = module.frontend_s3.bucket_regional_domain_name
}

################################################
# 5️⃣ IAM
################################################

module "iam" {
  source = "../../modules/iam"

  project     = local.project
  environment = local.environment

  ecr_repository_arn = module.ecr_backend.repository_arn
}

################################################
# 6️⃣ ALB
################################################

module "alb" {
  source = "../../modules/alb"

  project     = local.project
  environment = local.environment

  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids

  certificate_arn = var.certificate_arn
  container_port  = var.container_port
}

################################################
# 7️⃣ ECS
################################################

module "ecs" {
  source = "../../modules/ecs"

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
################################################
# 8️⃣ EC2 Instance
################################################

module "ec2" {
  source = "../../modules/workers"

  project     = local.project
  environment = local.environment

  instance_type = "t3.micro"

  vpc_id = module.vpc.vpc_id

  # subnet from VPC output
  public_subnet_id = module.vpc.public_subnet_ids[0]

  # RDS SG from RDS output
  rds_security_group_id = module.rds.rds_security_group_id

  allowed_ssh_cidr = var.allowed_ssh_cidr
}

################################################
# 9️⃣ RDS — Aurora PostgreSQL Serverless v2
################################################

module "rds" {
  source = "../../modules/rds"

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
################################################
# 🔟 SQS (Email Queue)
################################################

module "sqs" {
  source = "../../modules/sqs"

  project     = local.project
  environment = local.environment

  visibility_timeout = var.visibility_timeout
  message_retention  = var.message_retention
  max_receive_count  = var.max_receive_count
}


################################################
# 1️⃣1️⃣ Route53 - Frontend (CloudFront)
################################################

module "route53_frontend" {
  source = "../../modules/route53"

  domain_name = var.domain_name
  subdomain   = var.frontend_subdomain

  alias_name    = module.cloudfront.cloudfront_domain
  alias_zone_id = "Z2FDTNDATAQYW2" # CloudFront fixed zone ID

  depends_on = [module.cloudfront]
}

################################################
# 1️⃣2️⃣ Route53 - Backend (ALB)
################################################

module "route53_backend" {
  source = "../../modules/route53"

  domain_name = var.domain_name
  subdomain   = var.backend_subdomain

  alias_name    = module.alb.alb_dns_name
  alias_zone_id = module.alb.alb_zone_id

  depends_on = [module.alb]
}

################################################
# 🔹 CodeBuild
################################################

module "codebuild" {
  source = "../../modules/codebuild"
  project     = local.project
  bucket_name = module.frontend_s3.bucket_name
  environment = local.environment
  
  deploy_type = "ecs"

  environment_name = "prod"

  ssm_path = "/seaverse/prod/"

  artifact_bucket =
    module.frontend_s3.bucket_name
}
################################################
# 🔐 Store SQS URLs in SSM
################################################

resource "aws_ssm_parameter" "sqs_queue_url" {
  name  = "/seaverse/prod/SQS_EMAIL_QUEUE_URL"
  type  = "SecureString"
  value = module.sqs.queue_url
}

resource "aws_ssm_parameter" "sqs_dlq_url" {
  name  = "/seaverse/prod/SQS_EMAIL_DLQ_URL"
  type  = "SecureString"
  value = module.sqs.dlq_url
}
resource "aws_ssm_parameter" "frontend_url" {
  name  = "/backend/FRONTEND_URL"
  type  = "SecureString"
  value = "${var.frontend_subdomain}.${var.domain_name}"
}

resource "aws_ssm_parameter" "backend_url" {
  name  = "/backend/BACKEND_URL"
  type  = "SecureString"
  value = "${var.backend_subdomain}.${var.domain_name}"
}

resource "aws_ssm_parameter" "distribution_id" {
  name  = "/Frontend/DISTRIBUTION_ID"
  type  = "SecureString"
  value = module.cloudfront.distribution_id

  overwrite = true
}
