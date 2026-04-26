# DevOps Coursework - Infrastructure as Code

Дипломный практикум по DevOps, Kubernetes и CI/CD в Yandex.Cloud

## Структура проекта

```
terraform/              # IaC конфигурация Yandex.Cloud (развернут в ветке main)
├── backend.tf          # S3 backend для state
├── providers.tf        # Yandex провайдер
├── main.tf             # VPC и подсети (3 зоны: a, b, c)
├── cluster.tf          # Kubernetes regional кластер и node group
├── registry.tf         # Yandex Container Registry
├── iam.tf              # Service accounts и роли
├── variables.tf        # Переменные с дефолтами
└── outputs.tf          # Выходные значения (endpoint, registry path)

helm/                   # Конфигурация мониторинга
├── kube-prometheus-stack-values.yaml    # Prometheus, Grafana, Alertmanager
└── deploy-monitoring.sh                 # Скрипт развертывания

docs/                   # Документация
└── KUBECONFIG-SETUP.md  # Настройка доступа к Kubernetes кластеру

scripts/                # Вспомогательные скрипты
└── deploy-infrastructure.sh             # Полный план развертывания

.github/workflows/
└── terraform.yml       # CI/CD pipeline для инфраструктуры
```

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

**Вариант A: Локально**

```bash
cd terraform

terraform init \
  -backend-config="access_key=$YC_ACCESS_KEY" \
  -backend-config="secret_key=$YC_SECRET_KEY"

terraform plan -out=tfplan
terraform apply tfplan

# Получи параметры
terraform output -json
```

**Вариант B: GitHub Actions (рекомендуется)**

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

```bash
# Получи kubeconfig
yc managed-kubernetes cluster get-credentials app-nspc-cluster \
  --region ru-central1 \
  --external

# Проверка
kubectl cluster-info
kubectl get nodes
kubectl get pods --all-namespaces
```

📖 **Подробная инструкция:** [docs/KUBECONFIG-SETUP.md](docs/KUBECONFIG-SETUP.md)

### 4. Развертывание мониторинга

```bash
cd helm
bash deploy-monitoring.sh

# Или вручную
kubectl create namespace monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -n monitoring -f kube-prometheus-stack-values.yaml

# Доступ к Grafana
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
# http://localhost:3000 (admin/admin)
```

## GitHub Actions Workflows

### terraform.yml

Запускается на:
- `push` в `main` → **terraform apply** (автоматически)
- `pull_request` в `main` → **terraform plan** + комментарий
- `workflow_dispatch` → выбери `plan`, `apply` или `destroy`

Всегда выполняет:
1. Checkout code
2. Setup Terraform
3. Terraform Init (с S3 backend секретами)
4. Terraform Validate
5. Terraform Plan/Apply/Destroy

## Команды для демонстрации

```bash
# Инфраструктура
terraform output -json
kubectl get cluster
kubectl get nodes -o wide

# Приложение (namespace app-nspc)
kubectl get pods -n app-nspc
kubectl get svc -n app-nspc
kubectl logs -n app-nspc deployment/app-nspc

# Мониторинг (namespace monitoring)
kubectl get pods -n monitoring
kubectl get svc -n monitoring

# Тест приложения
EXTERNAL_IP=$(kubectl get svc app-nspc -n app-nspc --template="{{.status.loadBalancer.ingress[0].ip}}")
curl http://$EXTERNAL_IP

# Grafana дашбоарды
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
# Откройте http://localhost:3000
```

## Ссылки

- **Infrastructure**: https://github.com/AleksandrLipovetskiy/DevOps_coursework
- **Application**: https://github.com/AleksandrLipovetskiy/app-nspc

## Troubleshooting

### Terraform state заблокирован

```bash
terraform force-unlock <LOCK_ID>
```

### Pod не запускается

```bash
kubectl describe pod -n app-nspc <pod-name>
kubectl logs -n app-nspc <pod-name>
```

### Kubeconfig не работает

```bash
yc managed-kubernetes cluster get-credentials app-nspc-cluster \
  --region ru-central1 --external
```

---

**Успеха в дипломе! 🚀**
