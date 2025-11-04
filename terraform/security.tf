# Создание группы безопасности для Kubernetes
resource "yandex_vpc_security_group" "k8s_sg" {
  name        = "k8s-security-group"
  network_id  = yandex_vpc_network.k8s_network.id

  # Разрешение SSH для доступа к нодам
  ingress {
    protocol       = "TCP"
    description    = "SSH"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  # Разрешение трафика для Kubernetes API
  ingress {
    protocol       = "TCP"
    description    = "Kubernetes API"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 6443
  }

  # Разрешение внутреннего трафика между нодами
  ingress {
    protocol       = "ANY"
    description    = "Internal traffic"
    v4_cidr_blocks = [var.vpc_cidr]
    from_port      = 0
    to_port        = 65535
  }

  # Разрешение HTTP/HTTPS для веб-приложения
  ingress {
    protocol       = "TCP"
    description    = "HTTP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "HTTPS"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  # Разрешение Zabbix портов
  ingress {
    protocol       = "TCP"
    description    = "Zabbix Server"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 10051
  }

  ingress {
    protocol       = "TCP"
    description    = "Zabbix Web"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 8080
  }

  # Разрешение Grafana портов
  ingress {
    protocol       = "TCP"
    description    = "Grafana Web"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 3000
  }

  # Разрешение Prometheus портов
  ingress {
    protocol       = "TCP"
    description    = "Prometheus"
    v4_cidr_blocks = [var.vpc_cidr]
    port           = 9090
  }

  # Разрешение исходящего трафика
  egress {
    protocol       = "ANY"
    description    = "Allow all outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}