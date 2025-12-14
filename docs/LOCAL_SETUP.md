# Локальная настройка и запуск Terraform

## Шаг 1: Клонирование репозитория

```bash
git clone https://github.com/AleksandrLipovetskiy/DevOps_coursework.git
cd DevOps_coursework/terraform
```

## Шаг 2: Настройка Yandex Cloud авторизации

```bash
# Export service account credentials
export YC_SERVICE_ACCOUNT_KEY_FILE=~/key.json

# Initialize Terraform
terraform init
terraform plan -var-file=terraform.tfvars
```

## Шаг 3: Подготовка terraform.tfvars

1. Скопируйте terraform.tfvars.example

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars and set your Yandex Cloud values
```

2. Инициализируйте Terraform

```bash
terraform init
```

3. Проверьте план развертывания

```bash
terraform plan
```

4. Примените конфигурацию (если план выглядит корректно)

```bash
terraform apply
```

## Предварительные требования

- Yandex Cloud аккаунт с активной подпиской
- Yandex Cloud CLI (`yc`) установлен и настроен
- Terraform >= 1.0
- Git

## Получение API ключа

1. Перейдите на [https://console.cloud.yandex.com](https://console.cloud.yandex.com)
2. В меню слева выберите "Service Accounts" (Сервисные аккаунты)
3. Создайте новый сервисный аккаунт для Terraform
4. Добавьте роль "editor" к аккаунту
5. Создайте API ключ (JSON файл)
6. Экспортируйте переменную окружения:

```bash
export YC_SERVICE_ACCOUNT_KEY_FILE=~/key.json
```

## Переменные terraform.tfvars

Основные переменные которые нужно настроить:

```hcl
cloud_id  = "your_cloud_id"
folder_id = "your_folder_id"
token     = "your_oauth_token_or_service_account_key"
```
