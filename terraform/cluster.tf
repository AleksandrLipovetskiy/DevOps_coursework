resource "yandex_kubernetes_cluster" "cluster" {
  name        = var.cluster_name
  description = "Managed Kubernetes cluster for app-nspc"
  network_id  = yandex_vpc_network.network.id

  service_account_id      = data.yandex_iam_service_account.terraeditor.id
  node_service_account_id = data.yandex_iam_service_account.terraeditor.id

  release_channel         = "STABLE"
  network_policy_provider = "CALICO"
  cluster_ipv4_range      = "10.2.0.0/16"
  service_ipv4_range      = "10.3.0.0/16"

  master {
    version   = var.kubernetes_version
    public_ip = true

    regional {
      region = var.region_id

      location {
        zone      = yandex_vpc_subnet.public.zone
        subnet_id = yandex_vpc_subnet.public.id
      }

      location {
        zone      = yandex_vpc_subnet.private1.zone
        subnet_id = yandex_vpc_subnet.private1.id
      }

      location {
        zone      = yandex_vpc_subnet.private2.zone
        subnet_id = yandex_vpc_subnet.private2.id
      }
    }

    maintenance_policy {
      auto_upgrade = true

      maintenance_window {
        day        = "monday"
        start_time = "02:00"
        duration   = "3h"
      }
    }
  }
}

resource "yandex_kubernetes_node_group" "app_nodes" {
  cluster_id = yandex_kubernetes_cluster.cluster.id
  name       = var.node_group_name
  version    = var.kubernetes_version

  instance_template {
    platform_id = var.node_platform_id

    resources {
      cores  = var.node_cores
      memory = var.node_memory
    }

    boot_disk {
      type = var.node_disk_type
      size = var.node_disk_size
    }

    container_runtime {
      type = "containerd"
    }

    network_interface {
      nat = true
      subnet_ids = [
        yandex_vpc_subnet.public.id,
        yandex_vpc_subnet.private1.id,
        yandex_vpc_subnet.private2.id
      ]
    }
  }

  allocation_policy {
    location {
      zone = yandex_vpc_subnet.public.zone
    }

    location {
      zone = yandex_vpc_subnet.private1.zone
    }

    location {
      zone = yandex_vpc_subnet.private2.zone
    }
  }

  scale_policy {
    fixed_scale {
      size = var.node_count
    }
  }

  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true

    maintenance_window {
      day        = "saturday"
      start_time = "03:00"
      duration   = "3h"
    }
  }
}