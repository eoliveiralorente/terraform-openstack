variable "enabled" {
  description = "Instala o Traefik."
  type        = bool
  default     = true
}

variable "chart_version" {
  description = "Versão do chart Helm do Traefik."
  type        = string
  default     = "42.4.1"
}

variable "namespace" {
  type    = string
  default = "traefik"
}
