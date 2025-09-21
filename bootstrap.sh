#!/bin/bash
set -euo pipefail

echo "=== Deploying Namespaces ==="
kubectl apply -f .infrastructure/mysql/ns.yml
kubectl apply -f .infrastructure/app/ns.yml

echo "=== Label and taint nodes ==="
MYSQL_NODE=$(kubectl get nodes -l app=mysql -o jsonpath='{.items[0].metadata.name}')
TODO_NODE=$(kubectl get nodes -l app=todoapp -o jsonpath='{.items[0].metadata.name}')

kubectl label node $MYSQL_NODE app=mysql --overwrite
kubectl taint node $MYSQL_NODE app=mysql:NoSchedule --overwrite
kubectl label node $TODO_NODE app=todoapp --overwrite

# Далі стандартний порядок застосування ресурсів
kubectl apply -f .infrastructure/mysql/configMap.yml
kubectl apply -f .infrastructure/mysql/secret.yml
kubectl apply -f .infrastructure/mysql/service.yml
kubectl apply -f .infrastructure/mysql/statefulSet.yml

kubectl apply -f .infrastructure/app/pv.yml
kubectl apply -f .infrastructure/app/pvc.yml
kubectl wait --for=condition=Bound pvc --all -n todo-app --timeout=60s
kubectl apply -f .infrastructure/app/secret.yml
kubectl apply -f .infrastructure/app/configMap.yml
kubectl apply -f .infrastructure/app/clusterIp.yml
kubectl apply -f .infrastructure/app/nodeport.yml
kubectl apply -f .infrastructure/app/hpa.yml
kubectl apply -f .infrastructure/app/deployment.yml

# Install Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s
kubectl apply -f .infrastructure/ingress/ingress.yml

echo "=== Deployment finished! ==="
echo "Check resources with:"
echo "kubectl get pods -n mysql"
echo "kubectl get pods -n todo-app"
echo "kubectl get ingress -n todo-app"
echo
echo "Access your app at: http://localhost"
