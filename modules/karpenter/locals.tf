locals {
    karpenter_chart_version = "0.17.0"
    karpenter_app_version = "0.17.0"
    karpenter_iam_role_name = "${var.env}-karpenter"
    karpenter_sa_name = "karpenter"
}