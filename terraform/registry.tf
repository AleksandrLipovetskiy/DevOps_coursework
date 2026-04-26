resource "yandex_container_registry" "registry" {
  name        = var.registry_name
  description = "Container Registry for app-nspc"
}

resource "yandex_container_repository" "app_nspc" {
  name = "${yandex_container_registry.registry.id}/${var.registry_repo_name}"
}