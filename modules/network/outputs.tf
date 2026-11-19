# O depends_on garante que as VMs só sejam criadas depois que a subnet
# e a ligação com o roteador existirem.
output "network_name" {
  value      = openstack_networking_network_v2.this.name
  depends_on = [openstack_networking_router_interface_v2.this]
}

output "network_id" {
  value      = openstack_networking_network_v2.this.id
  depends_on = [openstack_networking_router_interface_v2.this]
}

output "subnet_id" {
  value = openstack_networking_subnet_v2.this.id
}

output "router_id" {
  value = openstack_networking_router_v2.this.id
}
