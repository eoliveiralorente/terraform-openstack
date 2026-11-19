# Grafana: dashboards sobre as métricas do Prometheus
resource "helm_release" "this" {
  count = var.enabled ? 1 : 0

  name             = "grafana"
  repository       = "https://grafana-community.github.io/helm-charts"
  chart            = "grafana"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true
  wait             = true
  timeout          = 600

  values = concat(
    [yamlencode(yamldecode(file("${path.module}/values.yaml")))],
    var.host == null ? [] : [yamlencode(yamldecode(templatefile("${path.module}/values-ingress.yaml.tftpl", {
      host          = var.host
      ingress_class = var.ingress_class
    })))],
    var.storage_enabled ? [yamlencode(yamldecode(templatefile("${path.module}/values-storage.yaml.tftpl", {
      storage_class = var.storage_class == null ? "" : var.storage_class
      storage_size  = var.storage_size
    })))] : [],
  )
}

# Senha do admin gerada pelo chart
data "kubernetes_secret_v1" "admin" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = "grafana"
    namespace = var.namespace
  }

  depends_on = [helm_release.this]
}
