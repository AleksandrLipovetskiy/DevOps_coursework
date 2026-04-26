resource "yandex_container_registry_registry" "registry" {
  name        = var.registry_name
  description = "Container Registry for app-nspc"
}

resource "yandex_container_registry_repository" "app_nspc" {
  name        = var.registry_repo_name
  registry_id = yandex_container_registry_registry.registry.id
}
