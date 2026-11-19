variable "enabled" {
  description = "Instala o kube-prometheus-stack."
  type        = bool
  default     = true
}

variable "chart_version" {
  description = "Versão do chart Helm kube-prometheus-stack."
  type        = string
  default     = "93.4.0"
}

variable "namespace" {
  type    = string
  default = "monitoring"
}

variable "storage_enabled" {
  description = "Guarda as métricas em disco persistente. false = métricas se perdem se o pod reiniciar."
  type        = bool
  default     = false
}

variable "storage_class" {
  description = "StorageClass do disco. null = a padrão do cluster (kubectl get storageclass)."
  type        = string
  default     = null
}

variable "storage_size" {
  description = "Tamanho do disco do Prometheus."
  type        = string
  default     = "20Gi"
}
