variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "region" {
  description = "AWS Region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "env" {
  description = "Deployment Environment (dev, prod, staging)"
  type        = string
  default     = "dev1"
}

variable "initital_num_nodes" {
  description = "Initial number of nodes to create in the cluster"
  type        = number
  default     = 2
}

variable "availability_zones" {
  type = list(string)
}

variable "enable_ha" {
  description = "Enable High Availability"
  type        = bool
  default     = true
}

variable "ami_type" {
  description = "AMI type for EKS worker nodes"
  type        = string
  default     = "AL2_x86_64"
}