# Проект Diplom DevOps Netology - Отчёт о выполнении

## Обзор проекта

Этот проект реализует полный DevOps pipeline для развёртывания контейнеризированного приложения nginx на инфраструктуре Kubernetes в Yandex Cloud, как часть программы диплома DevOps инженера Netology.

## Структура репозиториев

Проект организован в трёх отдельных репозиториях:

### 1. **netology-devops-infrastructure** (DevOps_coursework)
**URL**: https://github.com/AleksandrLipovetskiy/DevOps_coursework

Этот репозиторий содержит Infrastructure as Code (IaC) с использованием Terraform для создания:
- **Сеть**: VPC с 3 подсетями в разных зонах доступности (ru-central1-a, ru-central1-b, ru-central1-d)
- **Кластер Kubernetes**: Управляемый Kubernetes v1.28 с региональным master узлом
- **Группа узлов**: Прерываемые VM-экземпляры (2vCPU, 4GB RAM, 30GB HDD)
- **Load Balancer**: Сетевой балансировщик нагрузки для входящего трафика
- **Container Registry**: Реестр контейнеров Yandex для хранения Docker образов
- **Мониторинг**: Конфигурация мониторинга и хранения логов
- **S3 Backend**: Управление состоянием Terraform через Yandex S3

**Ключевые файлы**:
- `terraform.yml`: GitHub Actions workflow для автоматизации apply/destroy Terraform
- `terraform/`: Модули конфигурации Terraform (сеть, K8s, реестр, мониторинг и т.д.)
- `terraform.tfvars.example`: Шаблон переменных для конфигурации облака
- `diag.puml`: Диаграмма архитектуры в формате PlantUML
- `README.md`: Детальные инструкции по настройке и использованию

### 2. **netology-app**
**URL**: https://github.com/AleksandrLipovetskiy/netology-app

Этот репозиторий содержит Docker приложение:
- **Dockerfile**: Multi-stage nginx на основе Alpine Linux
- **nginx.conf**: Конфигурация nginx с эндпоинтами проверки здоровья
- **index.html**: Статическое веб-содержимое с отображением версии приложения
- **.github/workflows/docker-build.yml**: CI/CD pipeline для сборки и отправки Docker образов

**Особенности приложения**:
- Nginx сервер на порту 80
- `/health` эндпоинт: возвращает 200 OK для проверок здоровья
- `/status` эндпоинт: возвращает 200 OK для мониторинга статуса
- Статическая HTML страница с информацией о версии
- Health check probe сконфигурирован в Docker

### 3. **netology-k8s-config**
**URL**: https://github.com/AleksandrLipovetskiy/netology-k8s-config

Этот репозиторий содержит Kubernetes манифесты:
- **manifests/deployment.yaml**: Комплексное развёртывание K8s включающее:
  - Создание Namespace
  - Deployment с 3 репликами
  - Rolling update стратегия
  - Liveness и readiness probes
  - Запросы и лимиты ресурсов
  - Pod anti-affinity для распределения
  - Service (ClusterIP)
  - Ingress (nginx-ingress)

## CI/CD Pipeline

### GitHub Actions Workflows

1. **terraform.yml** (Инфраструктура)
   - Триггеры: Push в main/develop, PR в main
   - Jobs:
     - `terraform-check`: Проверка синтаксиса
     - `terraform-plan`: Создание плана выполнения (отображается в комментариях PR)
     - `terraform-apply`: Применение изменений (только ветка main)
     - `terraform-destroy`: Удаление инфраструктуры (ручной запуск)

2. **docker-build.yml** (Приложение)
   - Триггеры: Push в main/develop, PR в main
   - Jobs:
     - Checkout кода
     - Настройка Docker Buildx
     - Аутентификация в Yandex Container Registry
     - Сборка и отправка Docker образа
     - Тегирование по версии, SHA и latest
     - Использование кэширования GitHub Actions для оптимизации сборки

## Развёртывание на Kubernetes

### Конфигурация Deployment
- **Образ**: `cr.yandex/<REGISTRY_ID>/netology-app:latest`
- **Реплики**: 3 (для высокой доступности)
- **Ресурсы**:
  - Requests: 100m CPU, 64Mi Memory
  - Limits: 500m CPU, 256Mi Memory
- **Probes**:
  - Liveness: Проверяет `/health` каждые 30 секунд
  - Readiness: Проверяет `/status` каждые 10 секунд
- **Service**: ClusterIP на порту 80
- **Ingress**: nginx-ingress с маршрутизацией по хостнейму

## Предварительные требования

1. **Аккаунт Yandex Cloud**: С необходимыми правами доступа
2. **Аккаунт GitHub**: Для репозиториев и Actions
3. **Необходимые Secrets** (GitHub Actions):
   - `YANDEX_REGISTRY_PASSWORD`: Ключ сервисного аккаунта для Container Registry
   - `YANDEX_REGISTRY_ID`: ID Container Registry

## Инструкции по развёртыванию

### Шаг 1: Настройка инфраструктуры
1. Клонируйте репозиторий DevOps_coursework
2. Создайте `terraform/terraform.tfvars` из шаблона
3. Сконфигурируйте учётные данные провайдера Yandex Cloud
4. Push в main ветку для запуска Terraform apply

### Шаг 2: Container Registry
1. Реестр создаётся автоматически через Terraform
2. GitHub Actions использует сохранённые учётные данные для отправки образов

### Шаг 3: Развёртывание приложения
1. Клонируйте репозиторий netology-app
2. Установите GitHub secrets для Yandex Container Registry
3. Push кода в main ветку
4. Docker образ автоматически собирается и отправляется в реестр

### Шаг 4: Приложение в K8s
1. Клонируйте репозиторий netology-k8s-config
2. Обновите ID реестра в manifests/deployment.yaml
3. Примените манифесты: `kubectl apply -f manifests/deployment.yaml`
4. Проверьте развёртывание: `kubectl get deployments -n netology`

## Диаграмма архитектуры

См. `diag.puml` в DevOps_coursework для визуальной архитектуры в формате PlantUML.

## Мониторинг и логирование

- **Prometheus**: Сконфигурирован для сбора метрик
- **Health Checks**: Эндпоинты приложения для K8s probes
- **Ingress Monitoring**: Метрики nginx-ingress доступны
- **Container Registry**: Логи доступны в консоли Yandex Cloud

## Соображения безопасности

1. **RBAC**: Реализовать политики Kubernetes RBAC
2. **Network Policies**: Ограничить связь между подами
3. **Container Registry**: Использовать приватный реестр с аутентификацией
4. **Secrets Management**: Использовать Kubernetes Secrets для чувствительных данных
5. **Resource Quotas**: Ограничить потребление ресурсов в namespace

## Масштабирование и высокая доступность

1. **Горизонтальное масштабирование**: Измените количество реплик в Deployment
2. **Вертикальное масштабирование**: Измените лимиты ресурсов
3. **Автомасштабирование узлов**: Сконфигурировано через Terraform
4. **Multi-AZ**: Развёртывание охватывает 3 зоны доступности
5. **Распределение подов**: Правила anti-affinity предотвращают концентрацию на одном узле

## Устранение неполадок

### Типичные проблемы:

1. **Ошибки при загрузке образа**:
   - Проверьте учётные данные Container Registry
   - Проверьте успех загрузки образа в GitHub Actions
   - Убедитесь, что в K8s сконфигурирован pull secret

2. **Под не запускается**:
   - Проверьте доступность ресурсов: `kubectl describe pod <pod-name> -n netology`
   - Проверьте liveness probe: `kubectl logs <pod-name> -n netology`

3. **Ingress не работает**:
   - Проверьте установку nginx-ingress: `kubectl get ingress -n netology`
   - Проверьте эндпоинты сервиса: `kubectl describe svc netology-app -n netology`

## Будущие улучшения

1. **Стек мониторинга**: Добавить Prometheus + Grafana + Loki
2. **GitOps**: Реализовать ArgoCD для развёртывания на K8s
3. **Helm Charts**: Упаковать K8s манифесты как Helm charts
4. **Тестирование**: Добавить автоматизированное тестирование в CI/CD pipeline
5. **Disaster Recovery**: Реализовать автоматические резервные копии и политики RTO/RPO
6. **Service Mesh**: Оценить Istio для продвинутого управления трафиком

## Ссылки на репозитории

- DevOps Infrastructure: https://github.com/AleksandrLipovetskiy/DevOps_coursework
- Application Container: https://github.com/AleksandrLipovetskiy/netology-app
- K8s Configuration: https://github.com/AleksandrLipovetskiy/netology-k8s-config

## Контакты и поддержка

Вопросы или проблемы - обратитесь к README файлам в каждом репозитории.

---

**Статус проекта**: Завершён согласно требованиям Diplom DevOps Netology
**Последнее обновление**: 2024
**Версия**: 1.0.0