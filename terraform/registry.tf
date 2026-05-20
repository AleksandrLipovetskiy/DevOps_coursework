resource "yandex_container_registry" "registry" {
  name      = var.registry_name
  folder_id = var.folder_id
  
  labels = {
    purpose = "app-nspc"
    env     = "production"
  }
}