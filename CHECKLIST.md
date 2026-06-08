# CHECKLIST — Дипломный практикум DevOps (ВЫПОЛНЕНО)

Все этапы дипломного практикума завершены. Ниже — финальный список с отметками.

---

## Этап 1 — Инфраструктура (Terraform)

- [x] Сервисный аккаунт создан, JSON-ключ получен
- [x] Object Storage bucket `tf-state-diplom` создан
- [x] S3 Access/Secret ключи настроены
- [x] Terraform backend инициализирован (S3 в Yandex Object Storage)
- [x] VPC `vpc-network-prod` создана
- [x] Публичная подсеть `192.168.10.0/24` (ru-central1-a)
- [x] Приватные подсети `192.168.20.0/24`, `192.168.30.0/24`, `192.168.40.0/24`
- [x] NAT Gateway и таблица маршрутизации для приватных подсетей
- [x] Bastion host в публичной подсети (Ubuntu 24.04, preemptible)
- [x] Security Groups: `bastion-sg`, `k8s-master-sg`, `k8s-nodes-sg`
- [x] Container Registry `app-nspc-registry` создан

## Этап 2 — Kubernetes-кластер

- [x] Regional Kubernetes-кластер `app-nspc-cluster` (K8s 1.32, STABLE)
- [x] Мастер с публичным IP (3 зоны: ru-central1-a/b/d)
- [x] Node Group `app-nspc-nodes`: 2 ноды, standard-v2, без публичных IP
- [x] Network Policy Provider: Calico
- [x] Pod CIDR: `10.2.0.0/16`, Service CIDR: `10.3.0.0/16`
- [x] Auto-upgrade и auto-repair нод включены
- [x] Доступ через bastion + SSH-туннель настроен

## Этап 3 — Тестовое приложение

- [x] Репозиторий `app-nspc` создан
- [x] Dockerfile написан (nginx:alpine, non-root, multi-stage)
- [x] Docker-образ собран и опубликован в Yandex Container Registry
- [x] Kubernetes-манифесты написаны: namespace, deployment, service, networkpolicy, rbac, serviceaccount
- [x] Приложение задеплоено в кластер, доступно через LoadBalancer IP
- [x] Non-root container (uid 101), read-only FS, dropped ALL capabilities
- [x] NetworkPolicy: default deny, allow HTTP + DNS
- [x] RBAC: минимальные права, automount token отключён

## Этап 4 — Мониторинг

- [x] Helm-чарт `kube-prometheus-stack` задеплоен в namespace `monitoring`
- [x] Prometheus запущен (retention 24h, 512Mi–1Gi RAM)
- [x] Grafana запущена (LoadBalancer, 5Gi PVC)
- [x] Alertmanager запущен (5Gi PVC)
- [x] Node Exporter запущен (метрики хоста)
- [x] kube-state-metrics запущен (метрики K8s-объектов)
- [x] Встроенные дашборды доступны (Kubernetes, Node Exporter)

## Этап 5 — CI/CD для инфраструктуры

- [x] GitHub Actions workflow `terraform.yml` создан
- [x] При push в `main` (изменения в `terraform/**`) → `terraform apply`
- [x] При PR → `terraform plan` (проверка без применения)
- [x] Ручной запуск: plan / apply / destroy через `workflow_dispatch`
- [x] После apply: автоматический деплой мониторинга и приложения
- [x] Destroy: очистка Container Registry перед уничтожением инфраструктуры
- [x] GitHub Secrets настроены: YC_SERVICE_ACCOUNT_KEY, YC_CLOUD_ID, YC_FOLDER_ID, YC_ACCESS_KEY, YC_SECRET_KEY, SSH_PUBLIC_KEY, REGISTRY_ID

## Этап 6 — CI/CD для приложения

- [x] CI workflow `ci.yml`: сборка + push образа при push в main/develop/tags
- [x] CD workflow `cd.yml`: деплой в K8s при наличии тега `vX.Y.Z`
- [x] Тег запускает полный цикл: build → push → deploy → rollout status → LoadBalancer IP
- [x] Образ тегируется: `:latest`, `:<short-sha>`, `:vX.Y.Z`
- [x] Подстановка registry ID и тега через `sed` при деплое
- [x] GitHub Secrets настроены: YC_SERVICE_ACCOUNT_KEY, YC_CLOUD_ID, YC_FOLDER_ID, REGISTRY_ID

---

## Финальные артефакты

### Terraform

- [x] `terraform/` — все конфигурационные файлы
- [x] `terraform output -json` — см. скриншот [`docs/screenshots/terraform-output.png`](docs/screenshots/terraform-output.png)
- [x] `terraform apply` — см. скриншот [`docs/screenshots/terraform-apply.png`](docs/screenshots/terraform-apply.png)

### Kubernetes

- [x] `kubectl get nodes -o wide` — см. скриншот [`docs/screenshots/kubectl-nodes.png`](docs/screenshots/kubectl-nodes.png)
- [x] `kubectl get pods --all-namespaces` — см. скриншот [`docs/screenshots/kubectl-pods-all.png`](docs/screenshots/kubectl-pods-all.png)
- [x] `kubectl get svc -n app-nspc` — см. скриншот [`docs/screenshots/kubectl-svc-app.png`](docs/screenshots/kubectl-svc-app.png)

### GitHub Actions

- [x] Terraform pipeline (apply) — см. скриншот [`docs/screenshots/github-actions-terraform.png`](docs/screenshots/github-actions-terraform.png)
- [x] CI (docker build + push) — см. скриншот [`docs/screenshots/github-actions-ci.png`](docs/screenshots/github-actions-ci.png)
- [x] CD (kubernetes deploy) — см. скриншот [`docs/screenshots/github-actions-cd.png`](docs/screenshots/github-actions-cd.png)

### Приложение

- [x] Docker-образ в реестре: `cr.yandex/<REGISTRY_ID>/app-nspc`
- [x] Приложение доступно по LoadBalancer IP — см. скриншот [`docs/screenshots/app-browser.png`](docs/screenshots/app-browser.png)
- [x] Dockerfile и k8s-манифесты: [app-nspc репозиторий](https://github.com/AleksandrLipovetskiy/app-nspc)

### Мониторинг

- [x] Grafana дашборд — см. скриншот [`docs/screenshots/grafana-dashboard.png`](docs/screenshots/grafana-dashboard.png)
- [x] Prometheus targets — см. скриншот [`docs/screenshots/prometheus-targets.png`](docs/screenshots/prometheus-targets.png)

---

## Команды для демонстрации

```bash
# Инфраструктура
terraform output -json
kubectl get nodes -o wide
kubectl get pods --all-namespaces

# Приложение
kubectl get deployment -n app-nspc
kubectl get svc -n app-nspc
curl http://<EXTERNAL-IP>

# Образы в реестре
yc container repository list --registry-name app-nspc-registry
yc container image list --repository-name app-nspc

# Мониторинг (port-forward)
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
# http://localhost:3000  (admin / admin)
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090
# http://localhost:9090/targets

# Логи
kubectl logs -n app-nspc deployment/app-nspc --tail=100
kubectl logs -n monitoring -l app.kubernetes.io/name=prometheus
```
