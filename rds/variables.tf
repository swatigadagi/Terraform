variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment (dev/staging/prod)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID from vpc module"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private app subnet IDs for the DB subnet group"
}

variable "ecs_security_group_id" {
  description = "Security Group ID of ECS tasks"
  type        = string
}

variable "name" {
  type        = string
  description = "Initial database name"
  default     = "seaverse"
}

variable "master_username" {
  type        = string
  description = "Master DB username"
  default     = "seaverse_admin"
}

variable "master_password" {
  type        = string
  description = "Master DB password (from SSM Parameter Store)"
  sensitive   = true
}

variable "min_capacity" {
  type        = number
  description = "Aurora Serverless v2 min ACUs"
}

variable "max_capacity" {
  type        = number
  description = "Aurora Serverless v2 max ACUs"
}

variable "backup_retention_days" {
  type        = number
  description = "Days to retain automated backups"
  default     = 7
}

variable "deletion_protection" {
  type        = bool
  description = "Enable deletion protection"
  default     = false
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Skip final snapshot on destroy"
  default     = false
}
