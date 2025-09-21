#!/bin/bash
set -euo pipefail

INFRA_DIR=".infrastructure"

echo "=== Creating Namespaces ==="
kubectl apply -f "${INFRA_DIR}/mysql/ns.yml"
kubectl apply -f "${INFRA_DIR}/app/ns.yml"

echo "=== Labeling and Tainting Nodes ==="
# Заміни <mysql-node> та <todo-node> на імена нод у кластері
kubectl label node <mysql-node> app=mysql --overwrite
kubectl taint node <mysql-node> app=mysql:NoSchedule
kubectl label node <todo-node> app=todoapp --overwrite

echo "=== Deploying MySQL ==="
kubectl apply -f "${INFRA_DIR}/mysql/configMap.yml"
kubectl apply -f "${INFRA_DIR}/mysql/secret.yml"
kubectl apply -f "${INFRA_DIR}/mysql/service.yml"
kubectl apply -f "${INFRA_DIR}/mysql/statefulSet.yml"

echo "=== Deploying ToDo App ==="
kubectl apply -f "${INFRA_DIR}/app/pv.yml"
kubectl apply -f "${INFRA_DIR}/app/pvc.yml"

# Wait for PVC bound to avoid race condition
kubectl wait --for=condition=Bound pvc --all -n todo-app --timeout=60s

kubectl apply -f "${INFRA_DIR}/app/secret.yml"
kubectl apply -f "${INFRA_DIR}/app/configMap.yml"
kubectl apply -f "${INFRA_DIR}/app/clusterIp.yml"
kubectl apply -f "${INFRA_DIR}/app/nodeport.yml"
kubectl apply -f "${INFRA_DIR}/app/hpa.yml"
kubectl apply -f "${INFRA_DIR}/app/deployment.yml"

echo "=== Installing Ingress Controller ==="
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo "=== Waiting for ingress-nginx controller to be ready ==="
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

echo "=== Applying Ingress ==="
kubectl apply -f "${INFRA_DIR}/ingress/ingress.yml"

echo "=== Deployment finished! ==="
echo "Check resources with:"
echo "kubectl get nodes --show-labels"
echo "kubectl describe node <mysql-node>"
echo "kubectl get pods -o wide -n mysql"
echo "kubectl get pods -o wide -n todo-app"
echo "kubectl get ingress -n todo-app"
echo
echo "Access your app at: http://localhost"
