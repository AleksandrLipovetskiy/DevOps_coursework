terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=1.8.4"
}

provider "yandex" {
  access_key = var.backend_access_key
  secret_key = var.backend_secret_key
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.default_zone
}
