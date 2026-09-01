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

variable "initital_num_nodes" {
  description = "Initial number of nodes to create in the cluster"
  type        = number
}

variable "oidc_provider_url" {
  description = "OIDC provider URL for the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider for the EKS cluster"
  type        = string
}

variable "common_tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}