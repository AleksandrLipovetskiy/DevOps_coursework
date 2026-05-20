# DevOps Coursework - Infrastructure as Code

Дипломный практикум по DevOps, Kubernetes и CI/CD в Yandex.Cloud

## Структура проекта


## Требуемые секреты GitHub Actions

Добавь в Settings → Secrets and variables → Actions:

```
YC_SERVICE_ACCOUNT_KEY    (JSON key file)
YC_ACCESS_KEY             (S3 Access Key)
YC_SECRET_KEY             (S3 Secret Key)
YC_CLOUD_ID               (Yandex Cloud ID)
YC_FOLDER_ID              (Folder ID)
SSH_PUBLIC_KEY            (публичный SSH-ключ)
```

## Быстрый старт

### 1. Подготовка переменных (локально или в GitHub secrets)

```bash
export YC_CLOUD_ID="your-cloud-id"
export YC_FOLDER_ID="your-folder-id"
export YC_ACCESS_KEY="your-s3-access-key"
export YC_SECRET_KEY="your-s3-secret-key"
export SSH_PUBLIC_KEY="ssh-rsa AAAAB3... your@host"
```

### 2. Развертывание инфраструктуры

**GitHub Actions**

```bash
# Коммит в ветку develop
git checkout develop
git add .
git commit -m "Update infrastructure"
git push origin develop

# Merge PR в main и нажми "Approve and Deploy"
# или используй workflow_dispatch в GitHub Actions для manual apply/destroy
```

### 3. Получение доступа к Kubernetes

После развертывания инфраструктуры настройте доступ к кластеру:

# Проверка
kubectl cluster-info
kubectl get nodes
kubectl get pods --all-namespaces
```

нужно сделать подробную инструкцию  

### 4. Развертывание мониторинга



## GitHub Actions Workflows

### terraform.yml

Запускается на:
- `push` в `main` → **terraform apply** (автоматически)
- `pull_request` в `main` → **terraform plan** + комментарий
- `workflow_dispatch` → выбери `plan`, `apply` или `destroy`


## Ссылки

- **Infrastructure**: https://github.com/AleksandrLipovetskiy/DevOps_coursework
- **Application**: https://github.com/AleksandrLipovetskiy/app-nspc

## Troubleshooting
