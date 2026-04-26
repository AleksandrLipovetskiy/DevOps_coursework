resource "yandex_cr_registry" "registry" {
  name        = var.registry_name
  description = "Container Registry for app-nspc"
}

resource "yandex_cr_repository" "app_nspc" {
  name       = "${yandex_cr_registry.registry.name}/${var.registry_repo_name}"
  registry_id = yandex_cr_registry.registry.id
}
