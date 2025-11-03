terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=1.8.4"
}

provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.default_zone
}

# Валидация существования файла
validation "service_account_key_file" {
  condition     = fileexists(var.service_account_key_file)
  error_message = "Файл ключа ${var.service_account_key_file} не найден."
}