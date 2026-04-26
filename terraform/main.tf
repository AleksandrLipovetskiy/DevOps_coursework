resource "yandex_vpc_network" "network" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = [var.subnet_cidrs["public"]]
}

resource "yandex_vpc_subnet" "private1" {
  name           = "private1"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = [var.subnet_cidrs["private1"]]
}

resource "yandex_vpc_subnet" "private2" {
  name           = "private2"
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = [var.subnet_cidrs["private2"]]
}

resource "yandex_vpc_subnet" "private3" {
  name           = "private3"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = [var.subnet_cidrs["private3"]]
}
