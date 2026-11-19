# Traefik: ingress controller com IP público (LoadBalancer)
resource "helm_release" "this" {
  count = var.enabled ? 1 : 0

  name             = "traefik"
  repository       = "https://traefik.github.io/charts"
  chart            = "traefik"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true
  wait             = true
  timeout          = 900 # o load balancer leva alguns minutos para receber IP

  # yamldecode + yamlencode: normaliza o values.yaml (remove comentários e ordena as chaves)
  values = [yamlencode(yamldecode(file("${path.module}/values.yaml")))]
}

data "kubernetes_service_v1" "this" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = "traefik"
    namespace = var.namespace
  }

  depends_on = [helm_release.this]
}
