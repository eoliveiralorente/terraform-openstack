variable "name" {
  description = "Prefixo dos recursos de rede (<name>-net, <name>-subnet, <name>-router)."
  type        = string
}

variable "cidr" {
  description = "Faixa de IPs da subnet."
  type        = string
  default     = "10.10.0.0/24"
}

variable "dns_nameservers" {
  description = "Servidores DNS entregues às VMs."
  type        = list(string)
  default     = ["8.8.8.8", "1.1.1.1"]
}

variable "external_network_id" {
  description = "ID da rede externa (pública) do Nuvion, usada como gateway do roteador."
  type        = string
}
