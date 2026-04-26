#!/bin/bash

# Развертывание kube-prometheus-stack через Helm

set -e

NAMESPACE="monitoring"
RELEASE_NAME="kube-prometheus-stack"
VALUES_FILE="./helm/kube-prometheus-stack-values.yaml"

echo "Creating monitoring namespace..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

echo "Adding Prometheus Helm repository..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

echo "Installing $RELEASE_NAME..."
helm upgrade --install $RELEASE_NAME prometheus-community/kube-prometheus-stack \
  --namespace $NAMESPACE \
  --values $VALUES_FILE \
  --wait

echo ""
echo "✓ kube-prometheus-stack deployed successfully!"
echo ""
echo "Access Grafana:"
echo "  kubectl port-forward -n $NAMESPACE svc/$RELEASE_NAME-grafana 3000:80"
echo "  URL: http://localhost:3000"
echo "  User: admin"
echo "  Password: check helm values or kubectl get secret"
echo ""
echo "Access Prometheus:"
echo "  kubectl port-forward -n $NAMESPACE svc/$RELEASE_NAME-prometheus 9090:9090"
echo "  URL: http://localhost:9090"
