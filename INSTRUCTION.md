# ToDo App & MySQL Deployment Validation

1. **Check node labels**
```bash
kubectl get nodes --show-labels
Переконайся, що нода для MySQL має label app=mysql

Нода для ToDo має label app=todoapp

Check node taints

bash
Копіювати код
kubectl describe node <mysql-node>
Перевірити наявність app=mysql:NoSchedule

Check Pods scheduling

bash
Копіювати код
kubectl get pods -o wide -n mysql
kubectl get pods -o wide -n todo-app
Переконайся, що StatefulSet MySQL запускається на mysql-node

Переконайся, що Deployment ToDo App запускається на todoapp-node

Verify Pod Anti-Affinity

Переконайся, що MySQL поди не на одній ноді

Переконайся, що ToDo App поди не на одній ноді

Verify app functionality

MySQL працює та готовий (kubectl logs <mysql-pod> -n mysql)

ToDo App працює (kubectl logs <todoapp-pod> -n todo-app)

Перевірити доступ через Ingress: http://localhost

Check volume mounts

bash
Копіювати код
kubectl exec -it <todoapp-pod> -n todo-app -- ls -la /app/data
kubectl exec -it <todoapp-pod> -n todo-app -- ls -la /app/secrets
kubectl exec -it <todoapp-pod> -n todo-app -- ls -la /app/configs