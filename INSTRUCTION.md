
# ToDo App Kubernetes Deployment Instructions

This document describes how to validate the ToDo application and MySQL StatefulSet deployment in your Kubernetes cluster.

## 1. Verify Nodes

Check the labels on nodes:

```bash
kubectl get nodes --show-labels
```

Check node taints:

```bash
kubectl describe node <node_name>
```

Nodes should have:

* `app=mysql` label for the MySQL node
* `app=todoapp` label for the ToDo app node
* Taint `app=mysql:NoSchedule` applied to the MySQL node

## 2. Verify Namespaces

Check that the namespaces exist:

```bash
kubectl get ns
```

Expected namespaces:

* `mysql`
* `todo-app`

## 3. Check Persistent Volumes and Claims

Ensure PVs and PVCs are created and bound:

```bash
kubectl get pv,pvc -n todo-app
```

* The ToDo app PVC should be `Bound`.
* Storage capacity and access modes should match specifications.

## 4. Verify StatefulSet and Deployment

Check pods for MySQL and ToDo app:

```bash
kubectl get pods -o wide -n mysql
kubectl get pods -o wide -n todo-app
```

* Ensure MySQL pod is running on a node labeled `app=mysql`.
* Ensure ToDo app pod is running on a node labeled `app=todoapp`.
* MySQL and ToDo app pods should not be on the same node (PodAntiAffinity).

## 5. Verify ConfigMap and Secret Mounts

Check that ConfigMap is mounted properly:

```bash
kubectl exec -n todo-app <todoapp_pod_name> -- ls -1 /app/configs
```

Check that Secret is mounted with correct permissions:

```bash
kubectl exec -n todo-app <todoapp_pod_name> -- ls -la /app/secrets
```

* Secret files should be readable only by the owner (`-r--------`).

## 6. Verify Ingress and Access

Check the ingress resource:

```bash
kubectl get ingress -n todo-app
```

Access the ToDo app in the browser:

```
http://localhost
```

* Application should load correctly.
* No requests should fail with 404 in the console.

## 7. Cleanup (Optional)

To delete all resources:

```bash
kubectl delete ns mysql
kubectl delete ns todo-app
```
