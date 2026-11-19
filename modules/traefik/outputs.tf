output "public_ip" {
  description = "IP público do Traefik. Aponte o DNS dos domínios para ele."
  value       = try(data.kubernetes_service_v1.this[0].status[0].load_balancer[0].ingress[0].ip, null)
}

output "ingress_class" {
  description = "IngressClass para usar nos Ingress das aplicações."
  value       = var.enabled ? "traefik" : null
}
