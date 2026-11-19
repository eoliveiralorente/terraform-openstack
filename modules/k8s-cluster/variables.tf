variable "cluster_name" {
  description = "Nome do cluster. Também nomeia o template, a chave e o kubeconfig."
  type        = string
}

# ---------- Rede (vem do módulo network) ----------
variable "network_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "external_network_id" {
  type = string
}

variable "dns_nameserver" {
  type    = string
  default = "8.8.8.8"
}

# ---------- Template ----------
variable "image" {
  description = "Imagem Fedora CoreOS do Magnum (nome ou ID)."
  type        = string
}

variable "kube_version" {
  description = "Versão do Kubernetes (ex.: v1.35.3)."
  type        = string
  default     = "v1.35.3"
}

# ---------- Nós ----------
variable "high_availability" {
  description = "true = 3 mestres, false = 1 mestre."
  type        = bool
  default     = false
}

variable "master_flavor" {
  description = "Flavor dos mestres (mínimo 2 vCPU)."
  type        = string
}

variable "worker_flavor" {
  type = string
}

variable "worker_count" {
  description = "Única alteração que não recria o cluster."
  type        = number
  default     = 1
}

# ---------- Discos ----------
variable "boot_volume_size" {
  description = "Disco de sistema de cada nó, em GB (mínimo 10)."
  type        = number
  default     = 20

  validation {
    condition     = var.boot_volume_size >= 10
    error_message = "A imagem Fedora CoreOS exige pelo menos 10 GB."
  }
}

variable "container_volume_size" {
  description = "Disco de contêiner de cada nó, em GB."
  type        = number
  default     = 20
}

variable "volume_type_id" {
  description = "UUID do tipo de volume (Política de armazenamento)."
  type        = string
  default     = "f7b5f05d-130f-4546-8f4a-ea3ceda7df8d"
}

# ---------- Opções ----------
variable "autoscaling_enabled" {
  description = "Liga/desliga o autoscaling do grupo 'autoscale'. Muda sem recriar o cluster."
  type        = bool
  default     = false
}

variable "autoscaling_min" {
  description = "Nós do grupo 'autoscale' (mínimo). Com autoscaling desligado, é o tamanho fixo do grupo."
  type        = number
  default     = 1

  validation {
    condition     = var.autoscaling_min >= 1
    error_message = "autoscaling_min deve ser pelo menos 1."
  }
}

variable "autoscaling_max" {
  description = "Máximo de nós do grupo 'autoscale' (confira a cota de RAM e vCPU)."
  type        = number
  default     = 3
}

variable "autoscaling_flavor" {
  description = "Flavor do grupo 'autoscale'. null = o mesmo dos workers."
  type        = string
  default     = null
}

variable "monitoring_enabled" {
  type    = bool
  default = false
}

variable "labels" {
  description = "Labels extras no cluster (somadas às do template)."
  type        = map(string)
  default     = {}
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_ed25519.pub"
}
