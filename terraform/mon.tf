# Создание ВМ для Zabbix
resource "yandex_compute_instance" "zabbix" {
  name        = "zabbix"
  platform_id = var.instance_settings.platform_id
  zone        = var.zones[0]
  #hostname    = "zabbix"

  resources {
    cores         = var.instance_settings.core_count
    memory        = var.instance_settings.memory_count
    core_fraction = var.instance_settings.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = var.instance_settings.hdd_size
      type     = var.instance_settings.hdd_type
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.k8s_subnet[0].id
    nat = var.instance_settings.nat
    security_group_ids = [yandex_vpc_security_group.k8s_sg.id]
  }

  scheduling_policy {
    preemptible = var.instance_settings.preemptible
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}

# Создание ВМ для Grafana и Prometheus
resource "yandex_compute_instance" "grafana_prometheus" {
  name        = "grafana-prometheus"
  platform_id = var.instance_settings.platform_id
  zone        = var.zones[0]
  #hostname    = "grafana_prometheus"

  resources {
    cores         = var.instance_settings.core_count
    memory        = var.instance_settings.memory_count
    core_fraction = var.instance_settings.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = var.instance_settings.hdd_size
      type     = var.instance_settings.hdd_type
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.k8s_subnet[0].id
    nat = var.instance_settings.nat
    security_group_ids = [yandex_vpc_security_group.k8s_sg.id]
  }

  scheduling_policy {
    preemptible = var.instance_settings.preemptible
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}