# Argo CD
resource "helm_release" "this" {
  count = var.enabled ? 1 : 0

  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true
  wait             = true
  timeout          = 900

  # values.yaml sempre; values-ingress só com domínio. O Helm mescla os dois.
  values = concat(
    [yamlencode(yamldecode(file("${path.module}/values.yaml")))],
    var.host == null ? [] : [yamlencode(yamldecode(templatefile("${path.module}/values-ingress.yaml.tftpl", {
      host          = var.host
      ingress_class = var.ingress_class
    })))],
  )
}

data "kubernetes_secret_v1" "admin" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = var.namespace
  }

  depends_on = [helm_release.this]
}
