resource "yandex_iam_service_account" "cluster" {
  name        = "app-nspc-cluster-sa"
  description = "Service account for Kubernetes cluster provisioning"
}

resource "yandex_iam_service_account" "node" {
  name        = "app-nspc-node-sa"
  description = "Service account for Kubernetes worker nodes"
}

resource "yandex_resourcemanager_folder_iam_member" "cluster_sa_editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.cluster.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "node_sa_registry_reader" {
  folder_id = var.folder_id
  role      = "cr.reader"
  member    = "serviceAccount:${yandex_iam_service_account.node.id}"
}
