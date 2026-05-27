variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}


variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "allowed_ssh_cidr" {
  type        = list(string)
  description = "Your IP for SSH access"
}

variable "rds_security_group_id" {
  type        = string
  description = "RDS security group ID to allow EC2 access"
}
variable "public_subnet_id" {
  description = "Public subnet ID for EC2"
  type        = string
}