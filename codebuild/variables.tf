# CodeBuild Config

variable "codebuild_role_name" {
  description = "IAM role name for CodeBuild"
  type        = string
  default     = "codebuild-service-role"
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

# Deployment Config

variable "deploy_type" {
  description = "Deployment type (ec2 or ecs)"
  type        = string
}

variable "ssm_path" {
  description = "SSM parameter path for environment"
  type        = string
}

variable "artifact_bucket" {
  description = "Bucket for build artifacts"
  type        = string
}
