output "cluster_id" {
  value = openstack_containerinfra_cluster_v1.this.id
}

output "api_address" {
  value = openstack_containerinfra_cluster_v1.this.api_address
}

output "kubernetes_version" {
  value = openstack_containerinfra_cluster_v1.this.coe_version
}

output "kubeconfig_path" {
  value = abspath(local_sensitive_file.kubeconfig.filename)
}
