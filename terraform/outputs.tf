output "master_ip" {
  description = "Public IP of the Kubernetes Master node"
  value       = yandex_compute_instance.k8s_master.network_interface.0.nat_ip_address
}

output "worker_ips" {
  description = "Public IPs of the Kubernetes Worker nodes"
  value       = [for instance in yandex_compute_instance.k8s_worker : instance.network_interface.0.nat_ip_address]
}

output "zabbix_ip" {
  description = "Public IP of the Zabbix Server"
  value       = yandex_compute_instance.zabbix_server.network_interface.0.nat_ip_address
}

output "grafana_prometheus_ip" {
  description = "Public IP of the Grafana and Prometheus Server"
  value       = yandex_compute_instance.grafana_prometheus.network_interface.0.nat_ip_address
}

output "registry_endpoint" {
  description = "Yandex Container Registry Endpoint"
  value       = "cr.yandex/${yandex_container_registry.k8s_registry.id}"
}