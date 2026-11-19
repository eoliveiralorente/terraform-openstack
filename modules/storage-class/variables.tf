variable "enabled" {
  description = "Cria a StorageClass."
  type        = bool
  default     = true
}

variable "name" {
  description = "Nome da StorageClass."
  type        = string
  default     = "csi-cinder-ssd"
}

variable "volume_type" {
  description = "Tipo de volume do Cinder (nome ou ID). Padrão = SSD Standard, o mesmo do painel."
  type        = string
  default     = "f7b5f05d-130f-4546-8f4a-ea3ceda7df8d"
}

variable "is_default" {
  description = "Marca como StorageClass padrão do cluster (usada quando o volume não pede outra)."
  type        = bool
  default     = true
}

variable "reclaim_policy" {
  description = "Delete = apaga o volume do Cinder junto com o PVC. Retain = mantém o volume."
  type        = string
  default     = "Delete"
}
