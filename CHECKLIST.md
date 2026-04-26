# CHECKLIST - Дипломный практикум DevOps

## Подготовка к старту

- [ ] Клонировал/обновил оба репозитория:
  - [ ] `https://github.com/AleksandrLipovetskiy/DevOps_coursework`
  - [ ] `https://github.com/AleksandrLipovetskiy/app-nspc`

- [ ] Установил необходимые инструменты:
  - [ ] Terraform ≥ 1.8.4
  - [ ] kubectl
  - [ ] Yandex CLI (`yc`)
  - [ ] Helm
  - [ ] Docker (для локального тестирования)

- [ ] Подготовил Yandex.Cloud:
  - [ ] Сервисный аккаунт создан
  - [ ] JSON key скачан
  - [ ] Object Storage bucket создан (`tf-state-diplom`)
  - [ ] S3 Access/Secret keys созданы
  - [ ] Cloud ID и Folder ID известны
  - [ ] SSH публичный ключ готов
  - [ ] IAM токен получен (opsy для тестирования)

## GitHub Secrets (DevOps_coursework)

- [ ] `YC_SERVICE_ACCOUNT_KEY` (JSON key в виде строки)
- [ ] `YC_ACCESS_KEY` (S3 Access Key)
- [ ] `YC_SECRET_KEY` (S3 Secret Key)
- [ ] `YC_CLOUD_ID`
- [ ] `YC_FOLDER_ID`
- [ ] `SSH_PUBLIC_KEY` (ssh-rsa AAAA...)

## GitHub Secrets (app-nspc)

- [ ] `YC_FOLDER_ID`
- [ ] `YC_REGISTRY_PASSWORD` (base64 json_key)
- [ ] `KUBECONFIG` (base64 ~/.kube/config)

## Stage 1: Инфраструктура

### Локально

```bash
cd DevOps_coursework
export YC_CLOUD_ID="..."
export YC_FOLDER_ID="..."
export YC_ACCESS_KEY="..."
export YC_SECRET_KEY="..."
export SSH_PUBLIC_KEY="ssh-rsa ..."

cd terraform
terraform init -backend-config="access_key=$YC_ACCESS_KEY" ...
terraform validate
terraform plan
terraform apply
```

### Через GitHub Actions

- [ ] Коммит в develop
- [ ] Pull Request в main → workflow `plan`
- [ ] Merge PR → workflow `apply`

**Проверка:**
```bash
kubectl cluster-info
kubectl get nodes
kubectl get pods --all-namespaces
```

**Сохрани для демонстрации:**
- [ ] Screenshot успешного `terraform apply`
- [ ] Вывод `terraform output -json`
- [ ] Вывод `kubectl get nodes`

## Stage 2: Настройка доступа к кластеру

- [ ] Получи kubeconfig: `yc managed-kubernetes cluster get-credentials app-nspc-cluster --region ru-central1 --external`
- [ ] Проверь доступ: `kubectl get nodes`
- [ ] Проверь системные поды: `kubectl get pods --all-namespaces`

📖 **Подробная инструкция:** [docs/KUBECONFIG-SETUP.md](docs/KUBECONFIG-SETUP.md)

## Stage 2: Приложение

- [ ] Dockerfile обновлен (готов)
- [ ] CI workflow в `.github/workflows/ci.yml` (готов)
- [ ] CD workflow в `.github/workflows/cd.yml` (готов)
- [ ] Kubernetes манифесты в `k8s/` (готов)

### Локально тестируем

```bash
cd app-nspc
docker build -t app-nspc:test .
docker run -p 8080:80 app-nspc:test
# Проверь http://localhost:8080
```

### Через GitHub Actions

```bash
cd app-nspc
git tag v1.0.0
git push origin v1.0.0
# Ждем CI build + CD deploy
```

**Проверка:**
```bash
kubectl get pods -n app-nspc
kubectl get svc -n app-nspc
# Узнай LoadBalancer IP и проверь curl/браузер
```

**Сохрани для демонстрации:**
- [ ] Screenshot GitHub Actions successful runs (CI + CD)
- [ ] Вывод `kubectl get pods -n app-nspc`
- [ ] URL приложения (LoadBalancer IP)
- [ ] Screenshot приложения в браузере

## Stage 3: Мониторинг

```bash
cd DevOps_coursework/helm
bash deploy-monitoring.sh

# или вручную
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace -f kube-prometheus-stack-values.yaml
```

**Проверка:**
```bash
kubectl get pods -n monitoring
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
# http://localhost:3000 (admin/admin)
```

**Сохрани для демонстрации:**
- [ ] Screenshot Grafana дашбоарда
- [ ] Список метрик в Prometheus
- [ ] Screenshot алерта (если настроишь)

## Финальная демонстрация

Команды для демонстрации экзаменатору:

```bash
# 1. Инфраструктура
terraform output -json
kubectl get nodes -o wide
kubectl get pods --all-namespaces

# 2. Приложение
kubectl get deployment -n app-nspc
kubectl get svc -n app-nspc
curl http://<EXTERNAL-IP>

# 3. Docker image
docker images | grep app-nspc
# или
yc container repository list --registry-name app-nspc-registry

# 4. Мониторинг
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
# http://localhost:3000

# 5. Logs
kubectl logs -n app-nspc deployment/app-nspc
kubectl logs -n monitoring -l app.kubernetes.io/name=prometheus
```

## Артефакты для диплома

Сохрани для предоставления на экзамен:

1. **Terraform файлы:**
   - [ ] terraform/
   - [ ] Вывод `terraform output -json`

2. **GitHub Actions:**
   - [ ] Screenshot успешного terraform apply run
   - [ ] Screenshot успешного docker build + push
   - [ ] Screenshot успешного kubernetes deployment
   - [ ] Pull Request с комментарием от CI pipeline

3. **Приложение:**
   - [ ] Docker image в реестре (cr.yandex/...)
   - [ ] URL приложения (LoadBalancer IP)
   - [ ] Screenshot приложения в браузере
   - [ ] Dockerfile и k8s манифесты

4. **Мониторинг:**
   - [ ] Grafana дашбоард с метриками приложения
   - [ ] Grafana дашбоард node_exporter
   - [ ] список метрик в Prometheus

5. **Документация:**
   - [ ] README в DevOps_coursework (готов)
   - [ ] README в app-nspc (готов)
   - [ ] Этот checklist с галочками

## Troubleshooting

| Проблема | Решение |
|----------|---------|
| `backend: s3 config: access denied` | Проверь `YC_ACCESS_KEY`, `YC_SECRET_KEY` |
| `Pod not running` | `kubectl describe pod`, `kubectl logs` |
| `LoadBalancer pending` | Подожди 2-3 минуты, проверь `kubectl get svc` |
| `docker login failed` | Проверь `YC_REGISTRY_PASSWORD` (base64 json_key) |
| `terraform plan fails` | `terraform validate`, проверь state в S3 |

---

**Статус:** [ ] В процессе [ ] Готово к демонстрации

Дата обновления: `date`
