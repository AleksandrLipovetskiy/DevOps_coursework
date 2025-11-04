resource "yandex_vpc_network" "k8s_network" {
  name = "k8s-network"
}

resource "yandex_vpc_subnet" "k8s_subnet" {
  count          = 3
  name           = "k8s-subnet-${var.zones[count.index]}"
  zone           = var.zones[count.index]
  network_id     = yandex_vpc_network.k8s_network.id
  v4_cidr_blocks = [var.subnet_cidrs[count.index]]
}

resource "yandex_vpc_gateway" "nat_gateway" {
  name = "k8s-nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "k8s_route_table" {
  name       = "k8s-route-table"
  network_id = yandex_vpc_network.k8s_network.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}
