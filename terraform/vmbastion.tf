resource "yandex_compute_instance" "bastion" {
  count = 2

  name        = "bastion-${count.index + 1}"
  platform_id = var.instance_settings.platform_id
  zone        = var.default_zone

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
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = var.instance_settings.nat
    #security_group_ids = [yandex_vpc_security_group.example.id]
  }

  scheduling_policy {
    preemptible = var.instance_settings.preemptible
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}