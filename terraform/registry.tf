resource "yandex_container_registry" "registry" {
  name      = var.registry_name
  folder_id = var.folder_id  # если нужно явно указать
  
  labels = {
    purpose = "app-nspc"
    env     = "production"
  }
}

resource "yandex_container_repository" "app_nspc" {
  registry_id = yandex_container_registry.registry.id
  name        = var.registry_repo_name
}