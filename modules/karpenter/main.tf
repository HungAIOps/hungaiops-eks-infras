##########################################
# IAM Role and Policy for Karpenter
##########################################
resource "aws_iam_role" "karpenter" {
  name = "${var.region}-karpenter"

  assume_role_policy = templatefile(
    "${path.module}/files/assume_role_policy.json.tftpl",
    {
      oidc_provider_arn = var.oidc_provider_arn
      oidc_provider_url = var.oidc_provider_url
      karpenter_sa_name = local.karpenter_sa_name
    }
  )
}

resource "aws_iam_policy" "karpenter" {
  name        = "${var.region}-karpenter"
  description = "IAM Policy for Karpenter"

  policy = templatefile(
    "${path.module}/files/policy_document.json.tftpl",
    {
      account_id                   = var.account_id
      region                       = var.region
      cluster_name                 = var.env
      karpenter_node_iam_role_name = var.node_role_name
    }
  )
}

resource "aws_iam_role_policy_attachment" "karpenter" {
  role       = aws_iam_role.karpenter.name
  policy_arn = aws_iam_policy.karpenter.arn
}

##########################################
# Karpenter Helm Release
##########################################
resource "helm_release" "karpenter" {
  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = local.karpenter_chart_version
  namespace  = "kube-system"

  values = [
    templatefile("${path.module}/files/karpenter.values.yaml.tftpl", {
      initital_num_nodes      = var.initital_num_nodes
      karpenter_app_version   = local.karpenter_app_version
      cluster_name            = var.env
      region                  = var.region
      karpenter_sa_name       = local.karpenter_sa_name
      account_id              = var.account_id
      karpenter_iam_role_name = aws_iam_role.karpenter.name
      enable_ha                = var.enable_ha
    })
  ]

  depends_on = [
    aws_iam_role_policy_attachment.karpenter
  ]
}

resource "helm_release" "karpenter_crd" {
  name       = "karpenter-crd"
  repository = "oci://ghcr.io/hungaiops"
  chart      = "karpenter-crd-chart"
  version    = local.karpenter_crd_chart_version
  namespace  = "kube-system"

  values = [
    templatefile("${path.module}/files/karpenter-crd.values.yaml.tftpl", {
      env                       = var.env
      region                    = var.region
      private_subnet_ids        = var.private_subnet_ids
      cluster_security_group_id = var.cluster_security_group_id
      ami_type                  = var.ami_type
      node_role_name            = var.node_role_name
      capacity_type             = var.capacity_type
      common_tags               = var.common_tags
    })
  ]

  depends_on = [
    aws_iam_role_policy_attachment.karpenter
  ]
}
