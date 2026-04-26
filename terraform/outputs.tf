output "cluster_id" {
  value = yandex_kubernetes_cluster.cluster.id
}

output "cluster_endpoint" {
  value = yandex_kubernetes_cluster.cluster.master[0].external_v4_address
}

output "registry_repository" {
  value = "cr.yandex/${var.folder_id}/${var.registry_repo_name}"
}

output "cluster_service_account_id" {
  value = yandex_iam_service_account.cluster.id
}

output "node_service_account_id" {
  value = yandex_iam_service_account.node.id
}
