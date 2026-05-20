resource "yandex_vpc_network" "network" {
  name = var.vpc_name
}

# Публичная подсеть — без route table (bastion выходит напрямую через NAT на интерфейсе)
resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = [var.subnet_cidrs["public"]]
}

# Приватные подсети нод — трафик через NAT Gateway
resource "yandex_vpc_subnet" "private1" {
  name           = "private1"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = [var.subnet_cidrs["private1"]]
  route_table_id = yandex_vpc_route_table.private_rt.id
}

resource "yandex_vpc_subnet" "private2" {
  name           = "private2"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = [var.subnet_cidrs["private2"]]
  route_table_id = yandex_vpc_route_table.private_rt.id
}

resource "yandex_vpc_subnet" "private3" {
  name           = "private3"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = [var.subnet_cidrs["private3"]]
  route_table_id = yandex_vpc_route_table.private_rt.id
}