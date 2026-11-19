# PROD -> projeto 862-Producao
os_cloud     = "saveincloud-prod"
cluster_name = "k8s-prod"

external_network_name = "public" # há duas redes externas (public e cross_service)

network_cidr = "10.10.0.0/24"
image        = "1a8b2fc8-47ae-4ab7-92b4-2869b63ceefb" # Fedora CoreOS (confira: openstack image list)
kube_version = "v1.35.3"

high_availability = true      # 3 mestres
master_flavor     = "PRI-2-8" # 2 vCPU / 8 GB
worker_flavor     = "PRI-4-8" # 4 vCPU / 8 GB
worker_count      = 1         # grupo padrão, fixo

boot_volume_size      = 30
container_volume_size = 50

# Dimensionamento automático: grupo "autoscale" (liga/desliga SEM recriar o cluster)
#   true  -> varia entre autoscaling_min e autoscaling_max
#   false -> fica fixo em autoscaling_min
autoscaling_enabled = true
autoscaling_min     = 1
autoscaling_max     = 3
# Workers no total: 1 fixo + 1 a 3 do autoscale = 2 a 4.
# Pior caso: 3x8 GB (mestres) + 4x8 GB = 56 GB e 22 vCPU (cota: 64 GB / 24 vCPU)
