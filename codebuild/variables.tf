# AWS

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

# CodeBuild Config

variable "codebuild_role_name" {
  description = "IAM role name for CodeBuild"
  type        = string
  default     = "codebuild-service-role"
}

variable "compute_type" {
  description = "CodeBuild compute type"
  type        = string
  default     = "BUILD_GENERAL1_MEDIUM"
}

variable "build_image" {
  description = "Docker image used for CodeBuild"
  type        = string
  default     = "aws/codebuild/standard:7.0"
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

variable "bucket_name" {
  description = "Artifact bucket name"
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
