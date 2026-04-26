#!/bin/bash

# Quick Setup Guide for DevOps Coursework

set -e

echo "=========================================="
echo "DevOps Coursework - Quick Setup"
echo "=========================================="
echo ""

# Check prerequisites
echo "1. Checking prerequisites..."
command -v terraform >/dev/null 2>&1 || { echo "   ✗ Terraform not installed"; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "   ✗ Kubectl not installed"; exit 1; }
command -v yc >/dev/null 2>&1 || { echo "   ✗ Yandex CLI not installed"; exit 1; }
command -v helm >/dev/null 2>&1 || { echo "   ✗ Helm not installed"; exit 1; }
echo "   ✓ All prerequisites installed"
echo ""

# Check environment variables
echo "2. Checking environment variables..."
required_vars=("YC_CLOUD_ID" "YC_FOLDER_ID" "YC_ACCESS_KEY" "YC_SECRET_KEY" "SSH_PUBLIC_KEY")
for var in "${required_vars[@]}"; do
  if [ -z "${!var}" ]; then
    echo "   ✗ Missing: $var"
    exit 1
  fi
done
echo "   ✓ All required environment variables set"
echo ""

# Initialize Terraform
echo "3. Initializing Terraform..."
cd terraform
terraform init \
  -backend-config="access_key=$YC_ACCESS_KEY" \
  -backend-config="secret_key=$YC_SECRET_KEY" >/dev/null 2>&1
echo "   ✓ Terraform initialized"
echo ""

# Validate Terraform
echo "4. Validating Terraform configuration..."
terraform validate >/dev/null 2>&1
echo "   ✓ Terraform configuration is valid"
echo ""

# Show Terraform plan
echo "5. Terraform plan (no apply yet):"
echo "   Run: terraform plan"
terraform plan -out=tfplan.tmp >/dev/null 2>&1
terraform show tfplan.tmp | tail -20
rm -f tfplan.tmp
echo ""

# Instructions
echo "=========================================="
echo "Next steps:"
echo "=========================================="
echo ""
echo "1. Review Terraform plan:"
echo "   cd terraform && terraform plan"
echo ""
echo "2. Apply infrastructure:"
echo "   terraform apply"
echo ""
echo "3. Get kubeconfig after infrastructure:"
echo "   yc managed-kubernetes cluster get-credentials app-nspc-cluster \\"
echo "     --region ru-central1 --external"
echo ""
echo "4. Verify Kubernetes cluster:"
echo "   kubectl get nodes"
echo "   kubectl get pods --all-namespaces"
echo ""
echo "5. Deploy monitoring:"
echo "   cd ../helm && bash deploy-monitoring.sh"
echo ""
echo "6. Access Grafana:"
echo "   kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80"
echo "   URL: http://localhost:3000"
echo "   User: admin"
echo ""
echo "7. Deploy application from app-nspc repo:"
echo "   git tag v1.0.0 && git push origin v1.0.0"
echo ""
echo "=========================================="
echo "✓ Setup complete!"
echo "=========================================="
