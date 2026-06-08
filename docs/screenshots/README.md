# Скриншоты / Доказательства результата

В этой папке размещаются скриншоты, подтверждающие работоспособность проекта.

## Необходимые скриншоты

| Файл | Что показывает | Как получить |
|------|---------------|--------------|
| `terraform-apply.png` | Успешное завершение Terraform pipeline | GitHub Actions → Terraform Pipeline → последний successful run |
| `terraform-output.png` | Вывод `terraform output -json` | Локально или Job Summary в Actions |
| `kubectl-nodes.png` | `kubectl get nodes -o wide` | После настройки kubeconfig |
| `kubectl-pods-all.png` | `kubectl get pods --all-namespaces` | После деплоя всех компонентов |
| `kubectl-svc-app.png` | `kubectl get svc -n app-nspc` | Показывает External IP приложения |
| `github-actions-terraform.png` | Terraform pipeline — успешный apply | GitHub Actions → Terraform Pipeline |
| `github-actions-ci.png` | CI — сборка и push образа | GitHub Actions → CI - Build and Push Docker Image |
| `github-actions-cd.png` | CD — деплой в Kubernetes | GitHub Actions → CD - Deploy to Kubernetes on Release Tag |
| `app-browser.png` | Приложение открыто в браузере | `http://<LoadBalancer-IP>` |
| `grafana-dashboard.png` | Grafana — дашборд кластера | `http://<Grafana-IP>` → Dashboards → Kubernetes/Compute Resources |
| `prometheus-targets.png` | Prometheus — все targets UP | `http://localhost:9090/targets` (после port-forward) |

## Команды для получения данных

```bash
# Nodes
kubectl get nodes -o wide

# All pods
kubectl get pods --all-namespaces

# App service (External IP)
kubectl get svc -n app-nspc

# Terraform output
cd terraform && terraform output -json

# Port-forward для скриншотов мониторинга
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090
```
