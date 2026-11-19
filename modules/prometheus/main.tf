# Prometheus (kube-prometheus-stack): métricas e alertas do cluster
resource "helm_release" "this" {
  count = var.enabled ? 1 : 0

  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true
  wait             = true
  timeout          = 900

  # values.yaml sempre; values-storage só com disco persistente. O Helm mescla os dois.
  values = concat(
    [yamlencode(yamldecode(file("${path.module}/values.yaml")))],
    var.storage_enabled ? [yamlencode(yamldecode(templatefile("${path.module}/values-storage.yaml.tftpl", {
      storage_class = var.storage_class == null ? "" : var.storage_class
      storage_size  = var.storage_size
    })))] : [],
  )
}
