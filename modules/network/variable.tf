# Environment
variable "env" {
  type    = string
  default = "dev"
}

# VPC CIDR
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

# AWS Region
variable "region" {
  type    = string
  default = "us-east-1"
}

# Availability Zones
variable "availability_zones" {
  type = list(string)
}

variable "enable_ha" {
  description = "Enable High Availability"
  type        = bool
}

# Tags
variable "common_tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}