# Курсовая работа "Дипломный практикум в Yandex.Cloud" - Липовецкий Александр Владимирович

[Репозиторий с конфигурационными файлами Terraform](https://github.com/AleksandrLipovetskiy/DevOps_coursework)  


[Репозиторий с Dockerfile тестового приложения](https://github.com/AleksandrLipovetskiy/app-nspc)

[Репозиторий с конфигурацией Kubernetes кластера](https://github.com/AleksandrLipovetskiy/app-nspc/tree/main/k8s)

[Ссылка на тестовое приложение ]

[Ссылка на веб интерфейс Grafana]




# Безопасный доступ к кластеру

## Архитектура

- **Люди** → SSH bastion → kubectl туннель → K8s API
- **GitHub Actions** → напрямую к публичному IP мастера (разрешено через Security Group по CIDR)
- **Ноды** → без публичных IP, исходящий трафик через NAT Gateway

## Первоначальная настройка (после terraform apply)

### 1. Получить IP bastion

```bash
cd terraform
terraform output bastion_public_ip
terraform output cluster_endpoint
```

### 2. Настроить bastion

```bash
# Скопировать и запустить скрипт установки
scp scripts/setup-bastion.sh ubuntu@<BASTION_IP>:~/
ssh ubuntu@<BASTION_IP> "bash setup-bastion.sh app-nspc-cluster <YC_FOLDER_ID>"
```

### 3. Настроить локальный SSH config

Заполнить `~/.ssh/config` согласно шаблону выше, подставив реальные IP.

### 4. Подключиться через туннель

```bash
ssh -fN k8s-tunnel-nspc
export KUBECONFIG=/tmp/kube-via-bastion.yaml
kubectl get nodes
```

## Проверка политик безопасности

```bash
# Проверить NetworkPolicy
kubectl get networkpolicy -n app-nspc

# Убедиться что под запускается non-root
kubectl get pod -n app-nspc -o jsonpath='{.items.spec.securityContext}'

# Проверить RBAC
kubectl auth can-i create deployments --as=system:serviceaccount:app-nspc:app-nspc-sa -n app-nspc

# Проверить что SA не монтирует лишние токены
kubectl get pod -n app-nspc -o yaml | grep automountServiceAccountToken
```

## GitHub Actions Secrets (обязательные)

| Secret | Описание |
|--------|----------|
| `YC_SERVICE_ACCOUNT_KEY` | JSON ключ сервисного аккаунта |
| `YC_CLOUD_ID` | ID облака |
| `YC_FOLDER_ID` | ID каталога |
| `REGISTRY_ID` | ID Container Registry |

## Обновление IP-диапазонов GitHub Actions

GitHub периодически меняет IP runners. Актуальный список:
```bash
curl -s https://api.github.com/meta | jq '.actions'
```
Обновить в `terraform/variables.tf` → `github_actions_cidrs` и применить `terraform apply`.