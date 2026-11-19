output "name" {
  description = "Nome da StorageClass criada (null se desligada)."
  value       = try(kubernetes_storage_class_v1.this[0].metadata[0].name, null)
}
