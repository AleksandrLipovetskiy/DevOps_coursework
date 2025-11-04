# Создание группы целей для балансировщика нагрузки (воркер-ноды)
resource "yandex_lb_target_group" "k8s_web_targets" {
  name      = "k8s-web-targets"
  region_id = "ru-central1"

  target {
    subnet_id = yandex_vpc_subnet.k8s_subnet[0].id
    address   = yandex_compute_instance.worker[0].network_interface.0.ip_address
  }
  target {
    subnet_id = yandex_vpc_subnet.k8s_subnet[1].id
    address   = yandex_compute_instance.worker[1].network_interface.0.ip_address
  }
  target {
    subnet_id = yandex_vpc_subnet.k8s_subnet[2].id
    address   = yandex_compute_instance.worker[2].network_interface.0.ip_address
  }
}

# Создание сетевого балансировщика нагрузки для Kubernetes API (мастер-ноды)
resource "yandex_lb_network_load_balancer" "k8s_api_lb" {
  name = "k8s-api-lb"
  type = "external"
  listener {
    name        = "api-listener"
    port        = 6443
    target_port = 6443
    protocol    = "tcp"
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.k8s_api_targets.id
    healthcheck {
      name                = "api-healthcheck"
      interval            = 10
      timeout             = 5
      unhealthy_threshold = 3
      healthy_threshold   = 3
      tcp_options {
        port = 6443
      }
    }
  }
}

# Создание группы целей для API балансировщика (мастер-ноды)
resource "yandex_lb_target_group" "k8s_api_targets" {
  name      = "k8s-api-targets"
  region_id = "ru-central1"

  target {
    subnet_id = yandex_vpc_subnet.k8s_subnet[0].id
    address   = yandex_compute_instance.master[0].network_interface.0.ip_address
  }
  target {
    subnet_id = yandex_vpc_subnet.k8s_subnet[1].id
    address   = yandex_compute_instance.master[1].network_interface.0.ip_address
  }
  target {
    subnet_id = yandex_vpc_subnet.k8s_subnet[2].id
    address   = yandex_compute_instance.master[2].network_interface.0.ip_address
  }
}

# Создание Application Load Balancer для веб-приложения
resource "yandex_alb_load_balancer" "k8s_web_lb" {
  name        = "k8s-web-lb"
  network_id  = yandex_vpc_network.k8s_network.id
  region_id   = "ru-central1"

  allocation_policy {
    location {
      zone_id   = var.zones[0]
      subnet_id = yandex_vpc_subnet.k8s_subnet[0].id
    }
    location {
      zone_id   = var.zones[1]
      subnet_id = yandex_vpc_subnet.k8s_subnet[1].id
    }
    location {
      zone_id   = var.zones[2]
      subnet_id = yandex_vpc_subnet.k8s_subnet[2].id
    }
  }

  listener {
    name = "web-listener"
    endpoint {
      address {
        external_ipv4_address {
          address = "auto"
        }
      }
      ports = [80, 443]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.k8s_web_router.id
      }
    }
  }
}

resource "yandex_alb_http_router" "k8s_web_router" {
  name = "k8s-web-router"
}

resource "yandex_alb_virtual_host" "k8s_web_host" {
  name            = "k8s-web-host"
  http_router_id  = yandex_alb_http_router.k8s_web_router.id

  route {
    name = "default-route"
    http_route {
      http_match {
        path {
          prefix = "/"
        }
      }
      http_route_action {
        backend_group_id = yandex_alb_backend_group.k8s_web_backend_group.id
      }
    }
  }
}

resource "yandex_alb_backend_group" "k8s_web_backend_group" {
  name = "k8s-web-backend-group"
  http_backend {
    name             = "web-backend"
    target_group_ids = [yandex_lb_target_group.k8s_web_targets.id]
    port             = 80
    healthcheck {
      timeout  = "5s"
      interval = "10s"
      http_healthcheck {
        path = "/health"
      }
    }
  }
}