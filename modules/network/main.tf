# Rede privada do cluster (equivalente a uma VPC)
resource "openstack_networking_network_v2" "this" {
  name           = "${var.name}-net"
  admin_state_up = true
}

# Subnet com DNS (o painel exige DNS válido para a rede sair pelo roteador)
resource "openstack_networking_subnet_v2" "this" {
  name            = "${var.name}-subnet"
  network_id      = openstack_networking_network_v2.this.id
  cidr            = var.cidr
  ip_version      = 4
  dns_nameservers = var.dns_nameservers
}

# Roteador com gateway na rede externa (saída para a internet)
resource "openstack_networking_router_v2" "this" {
  name                = "${var.name}-router"
  admin_state_up      = true
  external_network_id = var.external_network_id
}

# Liga a subnet ao roteador
resource "openstack_networking_router_interface_v2" "this" {
  router_id = openstack_networking_router_v2.this.id
  subnet_id = openstack_networking_subnet_v2.this.id
}
