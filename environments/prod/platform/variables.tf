# Este arquivo é IGUAL em todos os ambientes.

variable "kubeconfig_path" {
  description = "Kubeconfig gerado pela camada de infra."
  type        = string
}

# ---------- StorageClass ----------
variable "storage_class_enabled" {
  description = "Cria a StorageClass padrão do Cinder."
  type        = bool
  default     = true
}

variable "storage_volume_type" {
  description = "Tipo de volume do Cinder (nome ou ID). Padrão = SSD Standard."
  type        = string
  default     = "f7b5f05d-130f-4546-8f4a-ea3ceda7df8d"
}

# ---------- Traefik ----------
variable "traefik_enabled" {
  type    = bool
  default = true
}

variable "traefik_chart_version" {
  type    = string
  default = "42.4.1"
}

# ---------- Argo CD ----------
variable "argocd_enabled" {
  type    = bool
  default = true
}

variable "argocd_chart_version" {
  type    = string
  default = "10.18.0"
}

variable "argocd_host" {
  description = "Domínio do Argo CD. null = acesso por kubectl port-forward."
  type        = string
  default     = null
}

# ---------- Monitoramento ----------
variable "prometheus_enabled" {
  type    = bool
  default = true
}

variable "prometheus_chart_version" {
  type    = string
  default = "93.4.0"
}

variable "grafana_enabled" {
  type    = bool
  default = true
}

variable "grafana_chart_version" {
  type    = string
  default = "14.5.0"
}

variable "grafana_host" {
  description = "Domínio do Grafana. null = acesso por kubectl port-forward."
  type        = string
  default     = null
}

variable "monitoring_storage_enabled" {
  description = "Disco persistente para Prometheus e Grafana."
  type        = bool
  default     = false
}

variable "storage_class" {
  description = "StorageClass dos discos. null = a criada pelo módulo storage_class."
  type        = string
  default     = null
}

variable "prometheus_storage_size" {
  type    = string
  default = "20Gi"
}

variable "grafana_storage_size" {
  type    = string
  default = "5Gi"
}
