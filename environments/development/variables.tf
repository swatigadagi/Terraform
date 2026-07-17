variable "region" {
  description = "aws region"
  type        = string
}

variable "project" {
  description = "project name"
  type        = string
}

variable "environment" {
  description = "env name"
  type        = string
}

variable "certificate_arn" {
  description = "acm cert arn"
  type        = string
}

variable "container_port" {
  description = "container port"
  type        = number
}

variable "allowed_ssh_cidr" {
  description = "ssh access cidr"
  type        = list(string)

  default = ["0.0.0.0/0"]
}

variable "name" {
  description = "db name"
  type        = string
  default     = "seaverse"
}

variable "master_username" {
  description = "db master username"
  type        = string
  default     = "seaverse_admin"
}

variable "master_password" {
  description = "db password"
  type        = string
  sensitive   = true
}

variable "min_capacity" {
  description = "aurora min capacity"
  type        = number
}

variable "max_capacity" {
  description = "aurora max capacity"
  type        = number
}
