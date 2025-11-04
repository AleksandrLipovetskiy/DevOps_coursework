# Создание Container Registry для хранения Docker-образов
resource "yandex_container_registry" "k8s_registry" {
  name       = "k8s-registry"
  folder_id  = var.folder_id
}

# Создание репозитория в Registry
resource "yandex_container_repository" "app_repo" {
  name = "${yandex_container_registry.k8s_registry.id}/app-repo"
}