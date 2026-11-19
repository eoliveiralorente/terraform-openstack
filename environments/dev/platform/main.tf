# Camada PLATFORM: componentes instalados sobre o cluster criado pela infra (pasta ..).
# Ordem: apply da infra, depois desta pasta. Destroy: primeiro esta pasta, depois a infra.
# Este arquivo é IGUAL em todos os ambientes. Os valores ficam no terraform.tfvars.
# Um módulo por componente: para acrescentar outro (ex.: cert-manager), crie
# modules/<componente> e adicione um bloco module aqui.

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }
  }
}

# Acesso ao cluster pelo kubeconfig gerado pela camada de infra
provider "kubernetes" {
  config_path = var.kubeconfig_path
}

provider "helm" {
  kubernetes = {
    config_path = var.kubeconfig_path
  }
}

# StorageClass: volumes persistentes no Cinder (base para Prometheus, Grafana, Loki e aplicações)
module "storage_class" {
  source = "../../../modules/storage-class"

  enabled     = var.storage_class_enabled
  volume_type = var.storage_volume_type
}

locals {
  # StorageClass dos componentes: a informada no tfvars ou a criada acima
  storage_class = var.storage_class != null ? var.storage_class : module.storage_class.name
}

# Traefik: entrada HTTP/HTTPS do cluster
module "traefik" {
  source = "../../../modules/traefik"

  enabled       = var.traefik_enabled
  chart_version = var.traefik_chart_version
}

# Argo CD: implantação de aplicações
module "argocd" {
  source = "../../../modules/argocd"

  enabled       = var.argocd_enabled
  chart_version = var.argocd_chart_version
  host          = var.argocd_host
  ingress_class = module.traefik.ingress_class

  depends_on = [module.traefik]
}

# Prometheus: métricas e alertas (kube-prometheus-stack)
module "prometheus" {
  source = "../../../modules/prometheus"

  enabled         = var.prometheus_enabled
  chart_version   = var.prometheus_chart_version
  storage_enabled = var.monitoring_storage_enabled
  storage_class   = local.storage_class
  storage_size    = var.prometheus_storage_size

  depends_on = [module.storage_class]
}

# Grafana: dashboards (carrega os do Prometheus automaticamente)
module "grafana" {
  source = "../../../modules/grafana"

  enabled         = var.grafana_enabled
  chart_version   = var.grafana_chart_version
  namespace       = module.prometheus.namespace
  host            = var.grafana_host
  ingress_class   = module.traefik.ingress_class
  storage_enabled = var.monitoring_storage_enabled
  storage_class   = local.storage_class
  storage_size    = var.grafana_storage_size

  depends_on = [module.traefik, module.prometheus, module.storage_class]
}

# Migração da estrutura anterior (módulo único "platform"): evita reinstalar.
# Pode ser removido depois que todos os ambientes rodarem um apply com esta versão.
moved {
  from = module.platform.helm_release.traefik
  to   = module.traefik.helm_release.this[0]
}

moved {
  from = module.platform.helm_release.argocd
  to   = module.argocd.helm_release.this[0]
}
