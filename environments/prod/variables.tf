# Este arquivo é IGUAL em todos os ambientes.

variable "os_cloud" {
  description = "Entrada do clouds.yaml (cada projeto do painel tem a sua)."
  type        = string
}

variable "cluster_name" {
  type = string
}

# ---------- Rede ----------
variable "external_network_name" {
  description = "Nome da rede pública. null = a única rede externa do projeto."
  type        = string
  default     = null
}

variable "network_cidr" {
  type    = string
  default = "10.10.0.0/24"
}

variable "dns_nameservers" {
  type    = list(string)
  default = ["8.8.8.8", "1.1.1.1"]
}

# ---------- Kubernetes ----------
variable "image" {
  description = "Imagem Fedora CoreOS (nome ou ID)."
  type        = string
}

variable "kube_version" {
  type    = string
  default = "v1.35.3"
}

variable "high_availability" {
  type    = bool
  default = false
}

variable "master_flavor" {
  type = string
}

variable "worker_flavor" {
  type = string
}

variable "worker_count" {
  type    = number
  default = 1
}

variable "boot_volume_size" {
  type    = number
  default = 20
}

variable "container_volume_size" {
  type    = number
  default = 20
}

variable "autoscaling_enabled" {
  type    = bool
  default = false
}

variable "autoscaling_min" {
  type    = number
  default = 1
}

variable "autoscaling_max" {
  type    = number
  default = 3
}

variable "autoscaling_flavor" {
  type    = string
  default = null
}

variable "monitoring_enabled" {
  type    = bool
  default = false
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_ed25519.pub"
}
