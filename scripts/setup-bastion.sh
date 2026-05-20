#!/usr/bin/env bash
# Запускается на bastion после terraform apply
# Устанавливает kubectl и настраивает доступ к кластеру
set -euo pipefail

CLUSTER_NAME="${1:-app-nspc-cluster}"
YC_FOLDER_ID="${2:-}"

echo "==> Устанавливаем kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

echo "==> Устанавливаем Yandex Cloud CLI..."
curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash -s -- -i /usr/local/yandex-cloud -n
echo 'export PATH="$PATH:/usr/local/yandex-cloud/bin"' >> ~/.bashrc
export PATH="$PATH:/usr/local/yandex-cloud/bin"

echo "==> Получаем kubeconfig..."
yc managed-kubernetes cluster get-credentials "${CLUSTER_NAME}" \
  --internal \
  --force \
  ${YC_FOLDER_ID:+--folder-id "$YC_FOLDER_ID"}

echo "==> Проверяем доступ..."
kubectl get nodes

echo "✅ Bastion настроен. kubectl работает через внутреннюю сеть."