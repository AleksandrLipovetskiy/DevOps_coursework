output "zabbix_ip" {
  description = "Public IP of the Zabbix Server"
  value       = yandex_compute_instance.zabbix.network_interface[0].nat_ip_address
}

output "grafana_prometheus_ip" {
  description = "Public IP of the Grafana and Prometheus Server"
  value       = yandex_compute_instance.grafana_prometheus.network_interface[0].nat_ip_address
}

output "registry_endpoint" {
  description = "Yandex Container Registry Endpoint"
  value       = "cr.yandex/${yandex_container_registry.k8s_registry.id}"
}

output "web_lb_address" {
  description = "External IP of the Web Load Balancer"
  value       = try(yandex_lb_network_load_balancer.k8s_web_lb.listener[0].external_address_spec[0].address, "Pending...")
}

