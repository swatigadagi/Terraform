variable "alb_security_group_id" {
  description = "Security group of the ALB allowed to access ECS"
  type        = string
}
variable "listener_arn" {
  type = string
}
variable "project" { type = string }
variable "aws_region" { type = string }
variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }

variable "container_image" { type = string }
variable "container_port" { type = number }

variable "cpu" { type = string }
variable "memory" { type = string }

variable "desired_count" { type = number }

variable "alb_target_group_arn" { type = string }

variable "execution_role_arn" { type = string }
variable "task_role_arn" { type = string }


