variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "allowed_ssh_cidr" {
  type = list(string)
}

variable "instance_type" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "rds_security_group_id" {
  type = string
}
