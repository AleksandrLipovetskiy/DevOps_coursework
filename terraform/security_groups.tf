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

  # K8s API только с bastion (для людей через tunnel)
  ingress {
    protocol          = "TCP"
    description       = "K8s API from bastion"
    security_group_id = yandex_vpc_security_group.bastion.id
    port              = 443
  }

  # K8s API для GitHub Actions (публичные IP runners)
  ingress {
    protocol       = "TCP"
    description    = "K8s API from GitHub Actions"
    v4_cidr_blocks = var.github_actions_cidrs
    port           = 443
  }

  # Внутрикластерный трафик
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

  ingress {
    protocol          = "TCP"
    description       = "Kubelet from master"
    security_group_id = yandex_vpc_security_group.k8s_master.id
    from_port         = 10250
    to_port           = 10250
  }

  ingress {
    protocol          = "ANY"
    description       = "Intra-node traffic"
    predefined_target = "self_security_group"
  }

  # NodePort только из внутренней сети
  ingress {
    protocol       = "TCP"
    description    = "NodePort range internal"
    v4_cidr_blocks = ["192.168.0.0/16"]
    from_port      = 30000
    to_port        = 32767
  }

  # HTTP/HTTPS для LoadBalancer
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