# ============================================
# Load Balancers for Yandex Managed Kubernetes
# ============================================

# Сетевой балансировщик нагрузки для веб-приложений в K8s
resource "yandex_lb_network_load_balancer" "k8s_web_lb" {
  name           = "k8s-web-lb"
  type           = "external"
  folder_id      = var.folder_id

  listener {
    name        = "web-listener"
    port        = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  listener {
    name        = "https-listener"
    port        = 443
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.k8s_web_targets.id

    healthcheck {
      name       = "http-healthcheck"
      interval   = "10s"
      timeout    = "5s"
      unhealthy_threshold = 3
      healthy_threshold   = 3
      http_options {
        port = 80
        path = "/healthz"
      }
    }
  }
}

# Группа целей для веб-приложений
resource "yandex_lb_target_group" "k8s_web_targets" {
  name        = "k8s-web-targets"
  folder_id   = var.folder_id
  region_id   = var.zones[0]
  target_type = "instance"
}
