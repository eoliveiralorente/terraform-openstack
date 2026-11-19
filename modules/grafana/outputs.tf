output "url" {
  value = var.enabled ? (var.host == null ? "http://localhost:3000 (após o port-forward)" : "https://${var.host}") : null
}

output "admin_password" {
  description = "Senha do usuário admin."
  value       = try(data.kubernetes_secret_v1.admin[0].data["admin-password"], null)
  sensitive   = true
}

output "port_forward_command" {
  value = var.enabled ? "kubectl -n ${var.namespace} port-forward svc/grafana 3000:80" : null
}
