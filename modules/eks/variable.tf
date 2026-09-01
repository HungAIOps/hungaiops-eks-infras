variable "env" {
  description = "Deployment environment (dev, prod, etc.)"
  type        = string
}

variable "region" {
  description = "AWS Region to deploy resources"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version used for the EKS cluster"
  type        = string
  default     = "1.35"
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs used for EKS nodes"
  type        = list(string)
}

variable "instance_types" {
  description = "List of EC2 instance types used for worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "disk_size" {
  description = "Disk size (GB) for worker nodes"
  type        = number
  default     = 20
}

variable "capacity" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "common_tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}