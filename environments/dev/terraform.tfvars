# DEV -> projeto 862-Default
os_cloud     = "saveincloud"
cluster_name = "k8s-dev"

external_network_name = "public" # há duas redes externas (public e cross_service)

network_cidr = "10.20.0.0/24"
image        = "1a8b2fc8-47ae-4ab7-92b4-2869b63ceefb" # Fedora CoreOS (confira: openstack image list)
kube_version = "v1.35.3"

high_availability = false     # 1 mestre
master_flavor     = "PRI-2-8" # 2 vCPU / 8 GB
worker_flavor     = "PRI-2-8"
worker_count      = 1

boot_volume_size      = 20
container_volume_size = 20

# Dimensionamento automático: grupo "autoscale" (liga/desliga SEM recriar o cluster)
autoscaling_enabled = false
autoscaling_min     = 1
autoscaling_max     = 2
