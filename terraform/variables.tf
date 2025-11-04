###cloud vars
variable "ssh_public_key" {
  type        = string
  description = "Публичный SSH‑ключ для доступа к инстансу, для подключения ssh -i ~/.ssh/github-actions-key ubuntu@<IP-инстанса>"
}

variable "yc_token" {
  type        = string
  sensitive   = true
  }

variable "cloud_id" {
  type        = string
}

variable "folder_id" {
  type        = string
}

variable "zones" {
  type        = list(string)
  default     = ["ru-central1-a", "ru-central1-b", "ru-central1-d"]
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  description = "CIDR block for subnet"
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
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
    nat           = false
  }
}
