variable "enabled" {
  description = "Instala o Argo CD."
  type        = bool
  default     = true
}

variable "chart_version" {
  description = "Versão do chart Helm do Argo CD (argo-cd)."
  type        = string
  default     = "10.18.0"
}

variable "namespace" {
  type    = string
  default = "argocd"
}

variable "host" {
  description = "Domínio do Argo CD (ex.: argocd.cliente.com.br). null = acesso por kubectl port-forward."
  type        = string
  default     = null
}

variable "ingress_class" {
  description = "IngressClass usada quando host é preenchido."
  type        = string
  default     = "traefik"
}
