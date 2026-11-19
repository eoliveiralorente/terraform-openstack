output "url" {
  value = var.enabled ? (var.host == null ? "https://localhost:8080 (após o port-forward)" : "https://${var.host}") : null
}

output "admin_password" {
  description = "Senha inicial do usuário admin."
  value       = try(data.kubernetes_secret_v1.admin[0].data["password"], null)
  sensitive   = true
}

output "port_forward_command" {
  value = var.enabled ? "kubectl -n ${var.namespace} port-forward svc/argocd-server 8080:443" : null
}
