resource "yandex_vpc_security_group" "bastion" {
  name       = "bastion-sg"
  network_id = yandex_vpc_network.network.id

  ingress {
    protocol       = "TCP"
    description    = "SSH from allowed IPs"
    v4_cidr_blocks = var.allowed_ssh_cidrs
    port           = 22
  }

  ingress {
    protocol       = "ICMP"
    description    = "ICMP from internal"
    v4_cidr_blocks = ["192.168.0.0/16"]
  }

  egress {
    protocol       = "ANY"
    description    = "All outbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "k8s_master" {
  name       = "k8s-master-sg"
  network_id = yandex_vpc_network.network.id

  # K8s API открыт публично — защита на уровне K8s (TLS, RBAC, client certs)
  ingress {
    protocol       = "TCP"
    description    = "K8s API from anywhere"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  # Health check Yandex NLB — обязателен, иначе NLB помечает мастер как unhealthy и дропает трафик
  ingress {
    protocol          = "TCP"
    description       = "Yandex NLB health checks for master"
    predefined_target = "loadbalancer_healthchecks"
    from_port         = 0
    to_port           = 65535
  }

  # Внутрикластерный трафик (между мастерами в региональном кластере)
  ingress {
    protocol          = "ANY"
    description       = "Internal cluster traffic"
    predefined_target = "self_security_group"
  }

  egress {
    protocol       = "ANY"
    description    = "All outbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "k8s_nodes" {
  name       = "k8s-nodes-sg"
  network_id = yandex_vpc_network.network.id

  # Kubelet API — мастер обращается к ноде (exec, logs, metrics)
  ingress {
    protocol          = "TCP"
    description       = "Kubelet from master"
    security_group_id = yandex_vpc_security_group.k8s_master.id
    from_port         = 10250
    to_port           = 10250
  }

  # Весь трафик между нодами одной группы (Calico VXLAN, pod-to-pod, kube-proxy)
  ingress {
    protocol          = "ANY"
    description       = "Intra-node traffic"
    predefined_target = "self_security_group"
  }

  # Health-check Yandex Cloud внутренних балансировщиков
  # Требуется для нормального создания кластера и работы LoadBalancer-сервисов
  ingress {
    protocol       = "TCP"
    description    = "Yandex LB health checks"
    v4_cidr_blocks = ["198.18.235.0/24", "198.18.248.0/24"]
    from_port      = 0
    to_port        = 65535
  }

  # NodePort для внешнего доступа к сервисам (LoadBalancer → NodePort)
  ingress {
    protocol       = "TCP"
    description    = "NodePort range"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 30000
    to_port        = 32767
  }

  # HTTP/HTTPS для LoadBalancer-сервисов
  ingress {
    protocol       = "TCP"
    description    = "HTTP inbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }
  ingress {
    protocol       = "TCP"
    description    = "HTTPS inbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  egress {
    protocol       = "ANY"
    description    = "All outbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}