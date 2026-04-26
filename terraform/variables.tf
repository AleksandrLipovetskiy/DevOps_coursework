###cloud vars
variable "ssh_public_key" {
  type        = string
  description = "Публичный SSH‑ключ для доступа к инстансу, для подключения ssh -i ~/.ssh/github-actions-key ubuntu@<IP-инстанса>"
}

variable "backend_access_key" {
  type        = string
  description = "Access key для Object Storage (из статического ключа сервисного аккаунта)"
}

variable "backend_secret_key" {
  type        = string
  description = "Secret key для Object Storage"
}

variable "service_account_key_file" {
  type        = string
  description = "path file"
}

variable "cloud_id" {
  type        = string
}

variable "folder_id" {
  type        = string
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandexcloud.ru/docs/overview/concepts/geo-scope"
}

variable "vpc_name" {
  type        = string
  default     = "vpc-network-prod"
  description = "VPC network&subnet name"
}

variable "subnet_cidrs" {
  type = map(string)
  default = {
    public  = "192.168.10.0/24",
    private1 = "192.168.20.0/24",
    private2 = "192.168.30.0/24",
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

variable "region_id" {
  type        = string
  default     = "ru-central1"
  description = "Регион для ресурсов Yandex.Cloud"
}

variable "cluster_name" {
  type        = string
  default     = "app-nspc-cluster"
  description = "Имя Kubernetes кластера"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.30"
  description = "Версия Kubernetes"
}

variable "node_group_name" {
  type        = string
  default     = "app-nspc-nodes"
  description = "Имя node group для Kubernetes"
}

variable "node_count" {
  type        = number
  default     = 2
  description = "Число нод в node group"
}

variable "node_platform_id" {
  type        = string
  default     = "standard-v2"
  description = "Платформа для узлов Kubernetes"
}

variable "node_memory" {
  type        = number
  default     = 4
  description = "Память узла Kubernetes в ГБ"
}

variable "node_cores" {
  type        = number
  default     = 2
  description = "Количество ядер на узел Kubernetes"
}

variable "node_disk_size" {
  type        = number
  default     = 64
  description = "Размер диска узла Kubernetes в ГБ"
}

variable "node_disk_type" {
  type        = string
  default     = "network-hdd"
  description = "Тип диска узла Kubernetes"
}

variable "registry_name" {
  type        = string
  default     = "app-nspc-registry"
  description = "Имя Yandex Container Registry"
}

variable "registry_repo_name" {
  type        = string
  default     = "app-nspc"
  description = "Имя репозитория в Yandex Container Registry"
}
