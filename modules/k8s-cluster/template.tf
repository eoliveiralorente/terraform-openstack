# Template do cluster: o que o painel cria automaticamente ao escolher a versão.
# Criado pelo Terraform para o projeto não depender de nada feito à mão.
resource "openstack_containerinfra_clustertemplate_v1" "this" {
  name  = "${var.cluster_name}-template"
  coe   = "kubernetes"
  image = var.image

  external_network_id = var.external_network_id
  fixed_network       = var.network_id
  fixed_subnet        = var.subnet_id
  dns_nameserver      = var.dns_nameserver

  network_driver        = "cilium"
  volume_driver         = "cinder"
  docker_storage_driver = "overlay2"
  docker_volume_size    = var.container_volume_size
  server_type           = "vm"

  master_lb_enabled   = true
  floating_ip_enabled = true
  tls_disabled        = false
  public              = false

  # Labels do painel (labels.tf): boot em volume, versão do K8s, Cilium, CSI.
  labels = local.panel_labels
}
