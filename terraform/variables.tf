###cloud vars
variable "token" {
  type        = string
  sensitive   = true
}

variable "cloud_id" {
  type        = string
}

variable "folder_id" {
  type        = string
}

variable "service_account_id" {
  type        = string
  sensitive   = true
}

variable "pgp_key" {
  type        = string
  sensitive   = true
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "vpc_name" {
  type        = string
  default     = "prod"
  description = "VPC network&subnet name"
}

variable "subnet_cidrs" {
  type = map(string)
  default = {
    public  = "192.168.10.0/24",
    private1 = "192.168.20.0/24"
    private2 = "192.168.30.0/24"
    private3 = "192.168.40.0/24"
  }
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2404-lts"
}

variable "instance_settings" {
  type = object({
    platform_id   = string,
    core_count    = number,
    core_fraction = number,
    memory_count  = number,
    hdd_size      = number,
    hdd_type      = string,
    preemptible   = bool,
    nat           = bool
  })
  default = {
    platform_id   = "standard-v3",
    core_count    = 4,
    core_fraction = 100,
    memory_count  = 4,
    hdd_size      = 20,
    hdd_type      = "network-hdd",
    preemptible   = true,
    nat           = true
  }
}
