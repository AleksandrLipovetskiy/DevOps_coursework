# Настройка доступа к Kubernetes кластеру (kubeconfig)

## Обзор

После успешного развертывания инфраструктуры через Terraform необходимо настроить доступ к Kubernetes кластеру. Это делается путем получения файла kubeconfig, который содержит учетные данные и параметры подключения к кластеру.

## Предварительные требования

- [ ] Terraform apply выполнен успешно
- [ ] Yandex CLI (`yc`) установлен и настроен
- [ ] Сервисный аккаунт имеет права на кластер
- [ ] Кластер создан и находится в состоянии `RUNNING`

Проверить статус кластера:
```bash
yc managed-kubernetes cluster list
```

## Шаг 1: Получение kubeconfig

### Автоматический способ (рекомендуется)

Выполните команду для получения учетных данных кластера:

```bash
yc managed-kubernetes cluster get-credentials app-nspc-cluster \
  --region ru-central1 \
  --external
```

**Параметры команды:**
- `app-nspc-cluster` - имя кластера (из terraform output)
- `--region ru-central1` - регион кластера
- `--external` - использовать внешний endpoint (для доступа извне облака)

### Ручной способ (если автоматический не работает)

1. **Получить информацию о кластере:**
   ```bash
   yc managed-kubernetes cluster get app-nspc-cluster
   ```

2. **Сохранить kubeconfig вручную:**
   ```bash
   yc managed-kubernetes cluster get-credentials app-nspc-cluster \
     --region ru-central1 \
     --external \
     --kubeconfig ~/.kube/config
   ```

## Шаг 2: Проверка настройки

### Проверить подключение к кластеру

```bash
# Проверить статус кластера
kubectl cluster-info

# Вывод должен показать:
# Kubernetes control plane is running at https://...
# CoreDNS is running at https://...
```

### Проверить узлы кластера

```bash
kubectl get nodes

# Ожидаемый вывод:
# NAME                        STATUS   ROLES    AGE   VERSION
# cl1abcdef1234567890-abcd    Ready    <none>   5m    v1.30.0
# cl1abcdef1234567890-bcde    Ready    <none>   5m    v1.30.0
# cl1abcdef1234567890-cdef    Ready    <none>   5m    v1.30.0
```

### Проверить системные поды

```bash
kubectl get pods --all-namespaces

# Должны быть видны поды в namespace kube-system:
# kube-system   coredns-...    2/2     Running   0    5m
# kube-system   kube-proxy-... Running   0    5m
# kube-system   calico-...     Running   0    5m
```

## Шаг 3: Настройка для CI/CD

### Для GitHub Actions (app-nspc репозиторий)

1. **Получить kubeconfig в base64:**
   ```bash
   cat ~/.kube/config | base64 -w 0 > kubeconfig.b64
   ```

2. **Добавить в GitHub Secrets:**
   - Перейдите в репозиторий app-nspc
   - Settings → Secrets and variables → Actions
   - Создайте secret `KUBECONFIG` со значением из `kubeconfig.b64`

### Для локальной разработки

Kubeconfig уже сохранен в `~/.kube/config` и будет использоваться автоматически.

## Расположение файлов

- **Локальный kubeconfig**: `~/.kube/config` (Linux/Mac) или `%USERPROFILE%\.kube\config` (Windows)
- **Terraform outputs**: Содержат cluster_id и endpoint для проверки

## Troubleshooting

### Ошибка: "cluster not found"

```bash
# Проверить список кластеров
yc managed-kubernetes cluster list

# Проверить имя кластера в Terraform outputs
cd terraform
terraform output cluster_id
```

**Решение:** Убедитесь, что имя кластера совпадает (`app-nspc-cluster`)

### Ошибка: "access denied"

```bash
# Проверить права сервисного аккаунта
yc resource-manager folder list-access-bindings <folder-id>

# Проверить IAM токен
yc iam create-token
```

**Решение:** Проверьте роли сервисного аккаунта в Terraform (editor, containerregistry.reader)

### Ошибка: "connection refused"

```bash
# Проверить статус кластера
yc managed-kubernetes cluster get app-nspc-cluster

# Проверить endpoint
kubectl config current-context
kubectl config view --minify
```

**Решение:** Кластер может еще создаваться (ожидайте 10-15 минут)

### Ошибка: "certificate verify failed"

```bash
# Для тестового окружения отключить проверку сертификатов
kubectl config set-cluster <cluster-name> --insecure-skip-tls-verify=true
```

**Решение:** Используйте `--external` флаг при получении credentials

## Безопасность

- **Не коммитите kubeconfig** в Git (он в .gitignore)
- **Регулярно обновляйте токены** (IAM токены истекают)
- **Используйте отдельные kubeconfig** для разных сред (dev/prod)
- **Ограничивайте доступ** к кластеру через RBAC

## Следующие шаги

После настройки kubeconfig:

1. **Разверните мониторинг:**
   ```bash
   cd ../helm
   bash deploy-monitoring.sh
   ```

2. **Проверьте доступ к Grafana:**
   ```bash
   kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
   # http://localhost:3000 (admin/admin)
   ```

3. **Разверните приложение:**
   ```bash
   # В репозитории app-nspc
   git tag v1.0.0
   git push origin v1.0.0
   ```

## Полезные команды

```bash
# Переключение контекста
kubectl config get-contexts
kubectl config use-context <context-name>

# Просмотр текущей конфигурации
kubectl config view --minify

# Тестирование подключения
kubectl version --short
kubectl api-versions

# Очистка конфигурации (если нужно)
kubectl config delete-cluster <cluster-name>
kubectl config delete-context <context-name>
```

---

**Дата создания:** 2026-04-26
**Версия:** 1.0
**Автор:** DevOps Coursework Setup