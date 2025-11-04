resource "yandex_vpc_network" "k8s_network" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "k8s_subnet" {
  name           = "k8s_subnet"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.k8s_network.id
  v4_cidr_blocks = [var.subnet_cidr]
}

resource "yandex_vpc_gateway" "nat_gateway" {
  name = "k8s-nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "k8s_route_table" {
  name       = "k8s_route_table"
  network_id = yandex_vpc_network.k8s_network.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

resource "yandex_vpc_subnet_route_table" "k8s_subnet_route" {
  subnet_id      = yandex_vpc_subnet.k8s_subnet.id
  route_table_id = yandex_vpc_route_table.k8s_route_table.id
}