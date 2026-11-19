# Chave SSH do cluster
resource "openstack_compute_keypair_v2" "this" {
  name       = "${var.cluster_name}-key"
  public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))
}

# Cluster Kubernetes
resource "openstack_containerinfra_cluster_v1" "this" {
  name                = var.cluster_name
  cluster_template_id = openstack_containerinfra_clustertemplate_v1.this.id
  keypair             = openstack_compute_keypair_v2.this.name

  master_count  = var.high_availability ? 3 : 1
  master_flavor = var.master_flavor

  node_count = var.worker_count
  flavor     = var.worker_flavor

  fixed_network = var.network_id
  fixed_subnet  = var.subnet_id

  # Opções do ambiente (autoscaling, monitoramento, extras), somadas às do template
  labels       = local.cluster_labels
  merge_labels = true

  timeouts {
    create = "70m"
  }
}

# Grupo de workers com autoscaling (liga/desliga sem recriar o cluster)
#   autoscaling_enabled = true  -> varia entre autoscaling_min e autoscaling_max
#   autoscaling_enabled = false -> congelado em autoscaling_min (min = max)
resource "openstack_containerinfra_nodegroup_v1" "autoscale" {
  name       = "autoscale"
  cluster_id = openstack_containerinfra_cluster_v1.this.id
  role       = "worker"
  image_id   = var.image
  flavor_id  = coalesce(var.autoscaling_flavor, var.worker_flavor)

  node_count     = var.autoscaling_min
  min_node_count = var.autoscaling_min
  max_node_count = var.autoscaling_enabled ? var.autoscaling_max : var.autoscaling_min

  lifecycle {
    # Quem ajusta a quantidade de nós é o autoscaler, não o Terraform.
    ignore_changes = [node_count]
  }
}

# Kubeconfig salvo na pasta do ambiente: ./kubeconfig/<cluster>.yaml
resource "local_sensitive_file" "kubeconfig" {
  filename        = "${path.root}/kubeconfig/${var.cluster_name}.yaml"
  content         = openstack_containerinfra_cluster_v1.this.kubeconfig["raw_config"]
  file_permission = "0600"
}
