# DevOps_coursework

**Инфраструктура для Diplom DevOps Netology**

Этот репозиторий содержит Infrastructure as Code (IaC) для развёртывания Kubernetes кластера в Yandex Cloud с использованием Terraform и GitHub Actions.

## 📋 Содержание

- [Описание](#описание)
- [Архитектура](#архитектура)
- [Требования](#требования)
- [Быстрый старт](#быстрый-старт)
- [Структура проекта](#структура-проекта)
- [CI/CD](#cicd)
- [Основные компоненты](#основные-компоненты)
- [Настройка](#настройка)
- [Развёртывание](#развёртывание)
- [Мониторинг](#мониторинг)
- [Устранение неполадок](#устранение-неполадок)
- [Автор](#автор)

## 📝 Описание

Это полный DevOps pipeline для:
- **Инфраструктуры**: Управляемый Kubernetes в Yandex Cloud
- **Контейнеризации**: Docker образы в Yandex Container Registry
- **Оркестрации**: Развёртывание приложений на K8s
- **Автоматизации**: GitHub Actions workflows для CI/CD

## 🏗️ Архитектура

```
Yandex Cloud
├── VPC (3 зоны доступности)
│   ├── Subnet ru-central1-a
│   ├── Subnet ru-central1-b
│   └── Subnet ru-central1-d
├── Kubernetes Cluster (v1.28)
│   ├── Master (региональный)
│   ├── Node Group (преемптивные VM)
│   └── Ingress Controller (nginx)
├── Container Registry
├── Load Balancer
└── S3 Backend (Terraform state)
```

См. `diag.puml` для подробной архитектурной диаграммы.

## 📦 Требования

### Для локальной разработки:
- **Terraform** >= 1.0
- **Yandex Cloud CLI** (`yc`)
- **kubectl** >= 1.28
- **Docker** (опционально)

### Для облака:
- Аккаунт Yandex Cloud
- Service account с правами:
  - `compute.admin`
  - `container-registry.admin`
  - `editor` для создания ресурсов

### Для CI/CD:
- GitHub репозиторий
- GitHub Secrets:
  - `YANDEX_REGISTRY_PASSWORD`
  - `YANDEX_REGISTRY_ID`

## 🚀 Быстрый старт

### 1. Клонирование
```bash
git clone https://github.com/AleksandrLipovetskiy/DevOps_coursework.git
cd DevOps_coursework
```

### 2. Конфигурация
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Отредактируйте terraform.tfvars с вашими значениями
```

### 3. Инициализация Terraform
```bash
terraform init
```

### 4. План и применение
```bash
terraform plan
terraform apply
```

### 5. Получение доступа к K8s
```bash
yc managed-kubernetes cluster get-credentials <cluster-name> --zone ru-central1-a
kubectl get nodes
```

## 📁 Структура проекта

```
DevOps_coursework/
├── .github/
│   └── workflows/
│       └── terraform.yml          # GitHub Actions workflow
├── terraform/
│   ├── backend.tf                 # S3 backend конфигурация
│   ├── providers.tf               # Провайдеры Terraform
│   ├── variables.tf               # Входные переменные
│   ├── outputs.tf                 # Выходные значения
│   ├── network.tf                 # VPC, подсети, NAT
│   ├── master.tf                  # Kubernetes master
│   ├── worker.tf                  # Worker node groups
│   ├── docker_registry.tf         # Container Registry
│   ├── balancer.tf                # Load Balancer
│   ├── mon.tf                     # Мониторинг
│   ├── security.tf                # Security groups
│   └── terraform.tfvars.example   # Шаблон переменных
├── diag.puml                      # Архитектурная диаграмма
├── README.md                      # Этот файл
├── SUBMISSION.md                  # Полный отчёт проекта
└── .gitignore                     # Git игнор файлы
```

## 🔄 CI/CD

### GitHub Actions Workflow (terraform.yml)

**Триггеры:**
- Push в ветки `main`, `develop`
- Pull Request в ветку `main`
- Manual dispatch

**Jobs:**
1. **terraform-check** - Проверка синтаксиса
2. **terraform-plan** - Создание плана выполнения (показывается в PR)
3. **terraform-apply** - Применение изменений (только на main)
4. **terraform-destroy** - Удаление инфраструктуры (ручной запуск)

### Docker Build Workflow (netology-app)

- Автоматическая сборка Docker образов
- Отправка в Yandex Container Registry
- Тегирование по версиям и SHA

## 🔧 Основные компоненты

### Сетевая инфраструктура
- **VPC**: Выделенная виртуальная сеть
- **Subnets**: 3 подсети в разных зонах доступности
- **NAT Gateway**: Для исходящего трафика
- **Security Groups**: Правила брандмауэра

### Kubernetes
- **Версия**: v1.28
- **Master**: Региональный (высокая доступность)
- **Nodes**: Преемптивные VM (2vCPU, 4GB RAM, 30GB HDD)
- **Ingress**: nginx-ingress controller

### Container Registry
- **Хранилище**: Docker образов
- **Интеграция**: GitHub Actions
- **Аутентификация**: Service account

### Мониторинг
- **Prometheus**: Сбор метрик
- **Grafana**: Визуализация (опционально)
- **Logging**: Хранение логов

## ⚙️ Настройка

### Yandex Cloud

1. Создайте аккаунт на yandex.cloud
2. Установите Yandex Cloud CLI:
```bash
curl https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
```

3. Аутентификация:
```bash
yc init
```

4. Создайте Service Account:
```bash
yc iam service-account create --name terraform
yc resource-manager folder add-access-binding <folder-id> \
  --role editor \
  --subject serviceAccount:terraform
```

5. Создайте API ключ:
```bash
yc iam key create --service-account-name terraform --output key.json
```

### Terraform Variables

Отредактируйте `terraform/terraform.tfvars`:

```hcl
cloud_id   = "your-cloud-id"
folder_id  = "your-folder-id"
region     = "ru-central1"
token      = "your-api-token"

# Kubernetes
k8s_version = "1.28"
cluster_name = "devops-cluster"

# Node Group
node_cpu    = 2
node_memory = 4
node_disk   = 30
node_count  = 3
```

### GitHub Secrets

Добавьте в GitHub репозиторий:

1. `YANDEX_REGISTRY_PASSWORD` - API ключ для Container Registry
2. `YANDEX_REGISTRY_ID` - ID вашего Container Registry
3. `YANDEX_CLOUD_TOKEN` - API токен Yandex Cloud

## 🌐 Развёртывание

### Первое развёртывание

```bash
# Инициализация
cd terraform
terraform init

# Проверка плана
terraform plan

# Применение
terraform apply
```

### Обновление

```bash
# Модификация переменных
vim terraform.tfvars

# Применение изменений
terraform apply
```

### Удаление инфраструктуры

```bash
terraform destroy
```

## 📊 Мониторинг

### Проверка кластера

```bash
# Получение credentials
yc managed-kubernetes cluster get-credentials <cluster-name> --zone ru-central1-a

# Проверка узлов
kubectl get nodes
kubectl get pods --all-namespaces

# Мониторинг
kubectl get deployments -n netology
kubectl describe pod <pod-name> -n netology
```

### Логи

```bash
# Логи приложения
kubectl logs <pod-name> -n netology

# Логи в реальном времени
kubectl logs -f <pod-name> -n netology
```

## 🆘 Устранение неполадок

### Ошибка аутентификации
```bash
# Проверьте учётные данные
echo $YANDEX_CLOUD_TOKEN
yc auth list
```

### Pod не запускается
```bash
# Описание события
kubectl describe pod <pod-name> -n netology

# Логи
kubectl logs <pod-name> -n netology
```

### Проблемы с Terraform
```bash
# Обновление state
terraform refresh

# Детальный лог
TF_LOG=DEBUG terraform apply
```

## 📚 Дополнительные ресурсы

- [Yandex Cloud Documentation](https://cloud.yandex.com/docs)
- [Terraform Documentation](https://www.terraform.io/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs)
- [SUBMISSION.md](./SUBMISSION.md) - Полный отчёт проекта

## ✍️ Автор

**Александр Липовецкий**
- GitHub: [@AleksandrLipovetskiy](https://github.com/AleksandrLipovetskiy)
- Netology DevOps Diploma Project

## 📄 Лицензия

М MIT License - см. LICENSE файл

## 🤝 Вклад

Приветствуются pull requests! Для крупных изменений сначала откройте issue для обсуждения.

---

**Последнее обновление**: декабрь 2024
**Версия**: 1.0.0