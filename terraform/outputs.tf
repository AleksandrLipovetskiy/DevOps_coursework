output "master_ips" {
  description = "Public IPs of the Kubernetes Master nodes"
  value       = [for instance in yandex_compute_instance.master : instance.network_interface[0].nat_ip_address]
}

output "worker_ips" {
  description = "Public IPs of the Kubernetes Worker nodes"
  value       = [for instance in yandex_compute_instance.worker : instance.network_interface[0].nat_ip_address]
}

output "zabbix_ip" {
  description = "Public IP of the Zabbix Server"
  value       = yandex_compute_instance.zabbix.network_interface.0.nat_ip_address
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
  value       = yandex_alb_load_balancer.k8s_web_lb.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
}

output "api_lb_address" {
  description = "External IP of the API Load Balancer"
  value       = yandex_lb_network_load_balancer.k8s_api_lb.listener[0].external_address_spec[0].address
}