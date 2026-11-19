# Labels que o painel da SaveInCloud usa ao criar um cluster Kubernetes.
# Copiadas do cluster k8s-auto (openstack coe cluster show k8s-auto -c labels).
locals {
  panel_labels = {
    # Boot dos nós em volume (os flavors do Nuvion têm disco 0 GB)
    boot_volume_size   = tostring(var.boot_volume_size)
    boot_volume_type   = var.volume_type_id
    docker_volume_type = var.volume_type_id
    availability_zone  = "nova"

    # Kubernetes
    kube_tag               = var.kube_version
    kube_version           = var.kube_version
    hyperkube_image        = "docker.io/virtuozzo/hci-binary-hyperkube"
    container_runtime      = "containerd"
    cgroup_driver          = "systemd"
    use_podman             = "true"
    cluster_upgrade_method = "replace"
    coredns_tag            = "1.13.1"
    etcd_tag               = "v3.6.6"
    etcd_lb_disabled       = "true"

    # Rede (Cilium)
    network_driver      = "cilium"
    cilium_tag          = "v1.19.2"
    cilium_routing_mode = "native"
    flannel_tag         = "v0.11.0-amd64"

    # Integração com o OpenStack
    cloud_provider_enabled   = "true"
    cloud_provider_tag       = "v1.35.0"
    cinder_csi_enabled       = "true"
    cinder_csi_plugin_tag    = "v1.35.0"
    csi_attacher_tag         = "v4.6.1"
    csi_snapshotter_tag      = "v8.0.1"
    k8s_keystone_auth_tag    = "v1.35.0"
    heat_container_agent_tag = "5.3.11"
    octavia_api_lb_flavor    = ""
    octavia_default_flavor   = ""

    # Valores fixos no template. As opções do formulário (autoscaling e
    # monitoramento) são aplicadas no cluster: ver local.cluster_labels.
    auto_scaling_enabled = "False"
    autoscaler_tag       = "1.35.0"
    monitoring_enabled   = "False"
  }

  # Labels aplicadas no CLUSTER (sobrescrevem as do template), igual ao painel:
  # o painel liga o autoscaler SEM enviar min_node_count/max_node_count.
  # Quem liga/desliga o autoscaling é o min/max do nodegroup "autoscale"
  # (main.tf), que muda sem recriar o cluster.
  cluster_labels = merge(
    {
      auto_scaling_enabled = "True"
      monitoring_enabled   = var.monitoring_enabled ? "True" : "False"
    },
    var.labels,
  )
}
