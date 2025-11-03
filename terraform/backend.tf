
terraform {
  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    bucket            = "tf-state-diplom"
    key               = "prod/terraform.tfstate"
    region            = "ru-central1"
    skip_region_validation  = true
    skip_credentials_validation = true
    skip_requesting_account_id = true
  }
}