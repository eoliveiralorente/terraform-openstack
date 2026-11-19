output "traefik_ip" {
  description = "IP público do Traefik. Aponte o DNS dos domínios para ele."
  value       = module.traefik.public_ip
}

output "argocd_url" {
  value = module.argocd.url
}

output "argocd_admin_password" {
  description = "terraform output -raw argocd_admin_password"
  value       = module.argocd.admin_password
  sensitive   = true
}

output "argocd_port_forward" {
  description = "Comando para acessar o Argo CD sem domínio."
  value       = module.argocd.port_forward_command
}

output "grafana_url" {
  value = module.grafana.url
}

output "grafana_admin_password" {
  description = "terraform output -raw grafana_admin_password (usuário: admin)"
  value       = module.grafana.admin_password
  sensitive   = true
}

output "grafana_port_forward" {
  value = module.grafana.port_forward_command
}

output "prometheus_port_forward" {
  value = module.prometheus.port_forward_command
}

output "storage_class" {
  value = module.storage_class.name
}
