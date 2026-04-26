data "yandex_iam_service_account" "terraeditor" {
  name      = "terraeditor"
  folder_id = var.folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "terraeditor_editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${data.yandex_iam_service_account.terraeditor.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "terraeditor_registry_reader" {
  folder_id = var.folder_id
  role      = "cr.reader"
  member    = "serviceAccount:${data.yandex_iam_service_account.terraeditor.id}"
}
