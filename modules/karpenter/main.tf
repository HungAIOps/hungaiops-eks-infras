##########################################
# IAM Role and Policy for Karpenter
##########################################
resource "aws_iam_role" "karpenter" {
  name = "${var.region}-karpenter"

  assume_role_policy = templatefile(
    "${path.module}/karpenter_assume_role_policy.json",
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
    "${path.module}/karpenter_policy.json",
    {
      account_id                  = var.account_id
      region                      = var.region
      cluster_name                = var.env
      karpenter_node_iam_role_name = local.karpenter_iam_role_name
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
    templatefile("${path.module}/karpenter.values.yaml.tftpl", {
      cluster_name = var.env
      region       = var.region
    })
  ]

  depends_on = [
    aws_iam_role_policy_attachment.karpenter
  ]
}