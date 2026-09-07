terraform {
  required_version = "1.16.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.62.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.35.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
  token                  = data.aws_eks_cluster_auth.this.token
}

locals {
  common_tags = {
    Project = "HungAIOps"
    Env     = var.env
  }
}

##########################################
# Network
##########################################
module "network" {
  source = "./modules/network"

  env                = var.env
  region             = var.region
  availability_zones = var.availability_zones
  enable_ha          = var.enable_ha

  common_tags = local.common_tags
}

##########################################
# EKS
##########################################
module "eks" {
  source = "./modules/eks"

  env                = var.env
  region             = var.region
  capacity           = var.initital_num_nodes
  ami_type           = var.ami_type
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_app_subnet_ids

  common_tags = local.common_tags
}

##########################################
# EKS Addons
##########################################
module "eks_addons" {
  source = "./modules/eks_addons"

  env               = var.env
  region            = var.region
  cluster_name      = module.eks.cluster_name
  oidc_provider_url = module.eks.oidc_provider_url
  oidc_provider_arn = module.eks.oidc_provider_arn

  common_tags = local.common_tags
}

##########################################
# Helm Provider
##########################################
data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

##########################################
# AWS Load Balancer Controller
##########################################
module "aws_load_balancer_controller" {
  source = "./modules/aws_load_balancer_controller"

  env               = var.env
  region            = var.region
  oidc_provider_url = module.eks.oidc_provider_url
  oidc_provider_arn = module.eks.oidc_provider_arn
  account_id        = var.account_id
  enable_ha         = var.enable_ha

  common_tags = local.common_tags
}

##########################################
# Karpenter
##########################################
module "karpenter" {
  source = "./modules/karpenter"

  env                       = var.env
  region                    = var.region
  oidc_provider_url         = module.eks.oidc_provider_url
  oidc_provider_arn         = module.eks.oidc_provider_arn
  account_id                = var.account_id
  initital_num_nodes        = var.initital_num_nodes
  node_role_name            = module.eks.node_role_name
  private_subnet_ids        = module.network.private_app_subnet_ids
  cluster_security_group_id = module.eks.cluster_security_group_id
  ami_type                  = var.ami_type

  common_tags = local.common_tags
}

##########################################
# Istio
##########################################
module "istio" {
  source = "./modules/istio"

  enable_ha = var.enable_ha
}

