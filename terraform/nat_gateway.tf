# NAT Gateway для исходящего трафика нод (ноды без публичных IP)
resource "yandex_vpc_gateway" "nat_gw" {
  name = "nat-gateway"
  shared_egress_gateway {}
}

# Единая route table для всех трёх приватных подсетей
resource "yandex_vpc_route_table" "private_rt" {
  name       = "private-route-table"
  network_id = yandex_vpc_network.network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gw.id
  }
}