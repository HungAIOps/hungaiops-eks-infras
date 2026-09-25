variable "env" {
  description = "Deployment environment (dev, prod, etc.)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS Region to deploy resources"
  type        = string
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "node_role_name" {
  description = "IAM role name used by Karpenter-provisioned nodes"
  type        = string
}

variable "initital_num_nodes" {
  description = "Initial number of nodes to create in the cluster"
  type        = number
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs used by Karpenter nodes"
  type        = list(string)
}

variable "cluster_security_group_id" {
  description = "Security group ID for the EKS cluster"
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC provider URL for the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider for the EKS cluster"
  type        = string
}

variable "ami_type" {
  description = "AMI type for EKS worker nodes"
  type        = string
  default     = "AL2_x86_64"
}

variable "enable_ha" {
  description = "Enable High Availability"
  type        = bool
}

variable "capacity_type" {
  description = "Capacity type for EKS and Karpenter nodes"
  type        = string
  default     = "ON-DEMAND"
}

variable "common_tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}