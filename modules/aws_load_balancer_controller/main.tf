##########################################
# AWS Load Balancer Controller IAM Role
##########################################
resource "aws_iam_policy" "aws_lb_controller" {
  name        = "${var.region}-aws-load-balancer-controller"
  description = "IAM Policy for AWS Load Balancer Controller"

  policy = templatefile("${path.module}/policy_document.json.tftpl", {
    region = var.region
    account_id = var.account_id
  })
}

resource "aws_iam_role" "aws_lb_controller" {
  name        = local.aws_lb_controller_iam_role_name
  description = "ServiceAccount Role for AWS Load Balancer Controller."

  assume_role_policy = templatefile(
    "${path.module}/policy_document.json.tftpl",
    {
      aws_lb_controller_sa_name = local.aws_lb_controller_sa_name
      oidc_provider_url         = var.oidc_provider_url
      oidc_provider_arn         = var.oidc_provider_arn
    }
  )

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "aws_lb_controller" {
  role       = aws_iam_role.aws_lb_controller.name
  policy_arn = aws_iam_policy.aws_lb_controller.arn
}


##########################################
# AWS Load Balancer Controller
##########################################
resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = local.aws_lb_controller_chart_version
  namespace  = "kube-system"

  values = [
    templatefile("${path.module}/aws_lb_controller.values.yaml.tftpl", {
      cluster_name         = var.env
      region               = var.region
      account_id           = var.account_id
      aws_lb_controller__iam_role_name = local.aws_lb_controller_iam_role_name
      enable_ha              = var.enable_ha
      common_tags             = var.common_tags
    })
  ]

  depends_on = [
    aws_iam_role_policy_attachment.aws_lb_controller
  ]
}