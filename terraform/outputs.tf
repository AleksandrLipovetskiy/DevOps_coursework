output "cluster_id" {
  value = yandex_kubernetes_cluster.cluster.id
}

output "cluster_endpoint" {
  value = yandex_kubernetes_cluster.cluster.master[0].external_v4_address
}

output "registry_repository" {
  value = "cr.yandex/${var.folder_id}/${var.registry_repo_name}"
}

output "bastion_public_ip" {
  value       = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
  description = "Публичный IP bastion хоста"
}