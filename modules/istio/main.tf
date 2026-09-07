##########################################
# Istio Base
##########################################
resource "helm_release" "istio_base" {
  name             = "istio-base"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base"
  version          = local.istio_chart_version
  namespace        = local.istio_namespace
  create_namespace = true

  wait    = true
  timeout = 300
  atomic  = true
}

##########################################
# Istiod (control plane)
##########################################
resource "helm_release" "istiod" {
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  version    = local.istio_chart_version
  namespace  = local.istio_namespace

  values = [
    templatefile("${path.module}/files/istio.values.yaml.tftpl", {
      istio_image_version     = local.istio_image_version
      istio_autoscale_enabled = var.istio_autoscale_enabled
      enable_ha               = var.enable_ha
    })
  ]

  wait    = true
  timeout = 300
  atomic  = true

  depends_on = [helm_release.istio_base]
}

##########################################
# Istio Gateway (conditional)
##########################################
resource "helm_release" "istio_gateway" {
  name       = "istio-gateway"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  version    = local.istio_chart_version
  namespace  = local.istio_namespace

  values = [
    templatefile("${path.module}/files/gateway.values.yaml.tftpl", {
      istio_image_version     = local.istio_image_version
      enable_ha               = var.enable_ha
      istio_autoscale_enabled = var.istio_autoscale_enabled
    })
  ]

  wait    = true
  timeout = 300
  atomic  = true

  depends_on = [helm_release.istiod]
}