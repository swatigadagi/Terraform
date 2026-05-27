variable "project" {
  type = string
}
variable "environment" {
  type = string
}
variable "ecr_repository_arn" {
  description = "ECR repository ARN for backend"
  type        = string
}
