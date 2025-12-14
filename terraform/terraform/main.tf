# ============================================
# Yandex Managed Kubernetes Cluster
# ============================================

# Кластер Kubernetes
resource "yandex_kubernetes_cluster" "k8s" {
  name            = "${var.cluster_name}-${var.environment}"
  network_id      = yandex_vpc_network.k8s_network.id
  folder_id       = var.folder_id
  cluster_ipv4_range = var.k8s_cluster_ipv4_range
  service_ipv4_range = var.k8s_service_ipv4_range
  
  master {
    version = var.k8s_version
    zonal {
      zone      = var.zones[0]
      subnet_id = yandex_vpc_subnet.k8s_subnet[0].id
    }
    
    maintenance_policy {
      auto_upgrade = true
      maintenance_window {
        type        = "ANYTIME"
      }
    }
  }

  service_account_id      = yandex_iam_service_account.k8s_sa.id
  node_service_account_id = yandex_iam_service_account.k8s_node_sa.id

  depends_on = [
    yandex_iam_service_account.k8s_sa,
    yandex_iam_service_account.k8s_node_sa,
    yandex_resourcemanager_folder_iam_binding.k8s_editor,
    yandex_resourcemanager_folder_iam_binding.k8s_node_editor
  ]
}

# Группа узлов Kubernetes
resource "yandex_kubernetes_node_group" "default" {
  cluster_id = yandex_kubernetes_cluster.k8s.id
  name       = "${var.cluster_name}-node-group"
  version    = var.k8s_version
  
  instance_template {
    platform_id = var.instance_settings.platform_id
    resources {
      cores         = var.instance_settings.core_count
      memory        = var.instance_settings.memory_count
      core_fraction = var.instance_settings.core_fraction
    }
    boot_disk {
      type = var.instance_settings.hdd_type
      size = var.instance_settings.hdd_size
    }
    scheduling_policy {
      preemptible = var.instance_settings.preemptible
    }
  }

  scale_policy {
    auto_scale {
      min     = var.k8s_min_nodes
      max     = var.k8s_max_nodes
      initial = var.k8s_initial_nodes
    }
  }

  allocation_policy {
    location {
      zone = var.zones[0]
      subnet_id = yandex_vpc_subnet.k8s_subnet[0].id
    }
  }
}

# Учетная запись для кластера
resource "yandex_iam_service_account" "k8s_sa" {
  name        = "${var.cluster_name}-sa"
  folder_id   = var.folder_id
}

# Учетная запись для узлов
resource "yandex_iam_service_account" "k8s_node_sa" {
  name        = "${var.cluster_name}-node-sa"
  folder_id   = var.folder_id
}

# Привязка роли editor к кластеру
resource "yandex_resourcemanager_folder_iam_binding" "k8s_editor" {
  folder_id = var.folder_id
  role      = "editor"
  members   = ["serviceAccount:${yandex_iam_service_account.k8s_sa.id}"]
}

# Привязка роли container-registry.images.puller к узлам
resource "yandex_resourcemanager_folder_iam_binding" "k8s_node_editor" {
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  members   = ["serviceAccount:${yandex_iam_service_account.k8s_node_sa.id}"]
}
