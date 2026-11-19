output "network_id" {
  value = module.network.network_id
}

output "cluster_id" {
  value = module.k8s.cluster_id
}

output "api_address" {
  value = module.k8s.api_address
}

output "kubernetes_version" {
  value = module.k8s.kubernetes_version
}

output "kubeconfig_path" {
  description = "export KUBECONFIG=$(terraform output -raw kubeconfig_path)"
  value       = module.k8s.kubeconfig_path
}
