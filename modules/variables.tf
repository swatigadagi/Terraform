variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name (dev/staging/prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "azs" {
  description = "Availability Zones"
  type        = list(string)
}

variable "public_subnets" {
  description = "Public subnet CIDRs"
  type        = list(string)
}

variable "private_app_subnets" {
  description = "Private app subnet CIDRs"
  type        = list(string)
}

variable "private_worker_subnets" {
  description = "Private worker subnet CIDRs"
  type        = list(string)
}

variable "enable_nat_gateway" {
  type    = bool
  default = true
}

variable "interface_endpoints" {
  description = "List of AWS interface VPC endpoints to create"
  type        = list(string)
  default     = []
}

# ✅ New variable for region
variable "region" {
  description = "AWS Region for VPC endpoints"
  type        = string
}
variable "default_security_group_id" {
  description = "The default security group ID for the VPC"
  type        = string
  default     = null
}