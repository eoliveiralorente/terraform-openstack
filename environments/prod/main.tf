# Este arquivo é IGUAL em todos os ambientes. Os valores ficam no terraform.tfvars.

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 3.4"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

# Cada ambiente aponta para o projeto certo pela entrada do clouds.yaml
provider "openstack" {
  cloud = var.os_cloud
}

# Rede externa (pública) descoberta automaticamente
data "openstack_networking_network_v2" "external" {
  name     = var.external_network_name
  external = true
}

# 1. Rede: rede + subnet + roteador
module "network" {
  source = "../../modules/network"

  name                = var.cluster_name
  cidr                = var.network_cidr
  dns_nameservers     = var.dns_nameservers
  external_network_id = data.openstack_networking_network_v2.external.id
}

# 2. Kubernetes: template + chave + cluster + kubeconfig
module "k8s" {
  source = "../../modules/k8s-cluster"

  cluster_name = var.cluster_name

  network_id          = module.network.network_id
  subnet_id           = module.network.subnet_id
  external_network_id = data.openstack_networking_network_v2.external.id
  dns_nameserver      = var.dns_nameservers[0]

  image        = var.image
  kube_version = var.kube_version

  high_availability = var.high_availability
  master_flavor     = var.master_flavor
  worker_flavor     = var.worker_flavor
  worker_count      = var.worker_count

  boot_volume_size      = var.boot_volume_size
  container_volume_size = var.container_volume_size

  autoscaling_enabled = var.autoscaling_enabled
  autoscaling_min     = var.autoscaling_min
  autoscaling_max     = var.autoscaling_max
  autoscaling_flavor  = var.autoscaling_flavor
  monitoring_enabled  = var.monitoring_enabled

  ssh_public_key_path = var.ssh_public_key_path
}
