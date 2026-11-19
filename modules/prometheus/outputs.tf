output "namespace" {
  value = var.namespace
}

output "port_forward_command" {
  description = "Acesso à interface do Prometheus."
  value       = var.enabled ? "kubectl -n ${var.namespace} port-forward svc/kube-prometheus-stack-prometheus 9090:9090" : null
}
