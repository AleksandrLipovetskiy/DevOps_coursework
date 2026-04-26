#!/bin/bash

echo "======================================================================"
echo "Шаг 1: Инициализация Terraform backend"
echo "======================================================================"

cd terraform

export YC_ACCESS_KEY=$YC_ACCESS_KEY
export YC_SECRET_KEY=$YC_SECRET_KEY

terraform init \
  -backend-config="access_key=$YC_ACCESS_KEY" \
  -backend-config="secret_key=$YC_SECRET_KEY"

echo "✓ Terraform инициализирован"
echo ""

echo "======================================================================"
echo "Шаг 2: Проверка плана Terraform"
echo "======================================================================"

terraform plan -out=tfplan

echo ""
echo "✓ Plan готов. Проверь изменения выше."
echo "  Если всё выглядит правильно, запусти: terraform apply tfplan"
echo ""

echo "======================================================================"
echo "Шаг 3: Применение Terraform"
echo "======================================================================"

terraform apply tfplan

echo ""
echo "✓ Инфраструктура развернута!"
echo ""

echo "======================================================================"
echo "Получение вывода Terraform"
echo "======================================================================"

terraform output -json

echo ""
echo "✓ Сохрани файл kubeconfig для доступа к кластеру:"
echo "  yc managed-kubernetes cluster get-credentials <cluster-name>"
echo ""
