variable "enabled" {
  description = "Instala o Grafana."
  type        = bool
  default     = true
}

variable "chart_version" {
  description = "Versão do chart Helm do Grafana (repositório grafana-community)."
  type        = string
  default     = "14.5.0"
}

variable "namespace" {
  description = "Mesmo namespace do módulo prometheus, para o Grafana achar os dashboards."
  type        = string
  default     = "monitoring"
}

variable "host" {
  description = "Domínio do Grafana (ex.: grafana.cliente.com.br). null = acesso por kubectl port-forward."
  type        = string
  default     = null
}

variable "ingress_class" {
  description = "IngressClass usada quando host é preenchido."
  type        = string
  default     = "traefik"
}

variable "storage_enabled" {
  description = "Guarda os dados do Grafana em disco persistente."
  type        = bool
  default     = false
}

variable "storage_class" {
  description = "StorageClass do disco. null = a padrão do cluster."
  type        = string
  default     = null
}

variable "storage_size" {
  type    = string
  default = "5Gi"
}
