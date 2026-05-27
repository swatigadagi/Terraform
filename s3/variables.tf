variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "cloudfront_distribution_arn" {
  description = "CloudFront Distribution ARN (optional)"
  type        = string
  default     = null
}