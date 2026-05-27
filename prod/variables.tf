################################################
# AWS
################################################

variable "region" {
  description = "AWS region"
  type        = string
  default     = ""
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "AWS_REGION" {
  description = "AWS region"
  type        = string
  default     = ""
}

################################################
# Project & Environment
################################################

variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}


######cloudfront###########
variable "cloudfront_distribution_arn" {
  description = "CloudFront Distribution ARN (optional)"
  type        = string
  default     = null
}
variable "certificate_arn" {
  description = "ACM certificate ARN for ALB HTTPS listener"
  type        = string
  default     = null
}

variable "artifact_bucket" {
  description = "S3 bucket used by CodePipeline for artifacts"
  type        = string
}

variable "frontend_build_name" {
  description = "CodeBuild project name for frontend"
  type        = string
}

variable "backend_build_name" {
  description = "CodeBuild project name for backend"
  type        = string
}

variable "worker_build_name" {
  description = "CodeBuild project name for worker"
  type        = string
}

variable "bitbucket_repo" {
  description = "Bitbucket repository name"
  type        = string
}

variable "bitbucket_branch" {
  description = "Bitbucket branch used by pipeline"
  type        = string
}

variable "sns_email" {
  description = "Email address for pipeline SNS notifications"
  type        = string
}

variable "container_port"{
  description = "Host Port"
  type        = number
}


variable "master_password" {
  type      = string
  sensitive = true
}

variable "name" {
  type    = string
  default = "seaverse"
}

variable "master_username" {
  type    = string
  default = "seaverse_admin"
}

variable "min_capacity" {
  type    = number
  }

variable "max_capacity" {
  type    = number
}


variable "visibility_timeout" {
  type = number
}

variable "message_retention" {
  type = number
}

variable "max_receive_count" {
  type = number
}


variable "domain_name" {}
variable "frontend_subdomain" {}
variable "backend_subdomain" {}



variable "allowed_ssh_cidr" {
  description = "CIDR blocks allowed to SSH into EC2"
  type        = list(string)

  default = ["0.0.0.0/0"]
}
