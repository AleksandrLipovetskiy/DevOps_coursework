data "yandex_iam_service_account" "terraeditor" {
  name      = "terraeditor"
  folder_id = var.folder_id
}
