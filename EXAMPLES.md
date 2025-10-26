# Examples - Kubernetes Cluster Health Checker

Practical examples and code samples for using the Kubernetes Cluster Health Checker.

---

## 📋 Table of Contents

1. [Python Script Examples](#python-script-examples)
2. [kubectl Command Examples](#kubectl-command-examples)
3. [Prometheus Query Examples](#prometheus-query-examples)
4. [Grafana Dashboard Examples](#grafana-dashboard-examples)
5. [Automation Examples](#automation-examples)
6. [Troubleshooting Examples](#troubleshooting-examples)

---

## 🐍 Python Script Examples

### Example 1: Get Cluster Information

**Script:** `src/cluster_info.py`

```python
#!/usr/bin/env python3
from typing import Any
from kubernetes import client, config  # type: ignore

def main() -> None:
    # Load kubeconfig
    config.load_kube_config()
    
    # Create API client
    v1: Any = client.CoreV1Api()
    
    # Get nodes
    nodes: Any = v1.list_node()
    
    print("Cluster Nodes:")
    for node in nodes.items:
        print(f"  Name: {node.metadata.name}")
        print(f"  Status: {node.status.conditions[-1].type}")
        print(f"  Version: {node.status.node_info.kubelet_version}")
        print()

if __name__ == "__main__":
    main()
```

**Run:**
```bash
source venv/bin/activate
python3 src/cluster_info.py
```

**Expected Output:**
```
╔══════════════════════════════════════════════════════════════════════════╗
║                    KUBERNETES CLUSTER INFORMATION                        ║
╚══════════════════════════════════════════════════════════════════════════╝

Cluster: https://192.168.49.2:8443
Nodes: 1

Node Details:
  Name: minikube
  Status: Ready
  Roles: control-plane
  Age: 15m
  Version: v1.27.4
  OS: Linux
  Architecture: arm64
```

---

### Example 2: Monitor Cluster Health

**Script:** `src/health_monitor.py`

```python
#!/usr/bin/env python3
from typing import Any, Dict
from kubernetes import client, config  # type: ignore

def main() -> None:
    config.load_kube_config()
    v1: Any = client.CoreV1Api()
    
    # Get all pods
    pods: Any = v1.list_pod_for_all_namespaces()
    
    # Count pod statuses
    status_count: Dict[str, int] = {}
    for pod in pods.items:
        status: str = pod.status.phase
        status_count[status] = status_count.get(status, 0) + 1
    
    print("Pod Status Summary:")
    for status, count in status_count.items():
        print(f"  {status}: {count}")

if __name__ == "__main__":
    main()
```

**Run:**
```bash
python3 src/health_monitor.py
```

**Expected Output:**
```
╔══════════════════════════════════════════════════════════════════════════╗
║                    KUBERNETES CLUSTER HEALTH MONITOR                     ║
╚══════════════════════════════════════════════════════════════════════════╝

Pod Status Summary:
  Running: 28
  Pending: 0
  Failed: 0
  Succeeded: 0

Critical Namespaces Status:
  ✅ kube-system: All pods running (8/8)
  ✅ monitoring: All pods running (15/15)

✅ Cluster is healthy!
```

---

### Example 3: Get Service Information

**Script:** `src/service_info.py`

```python
#!/usr/bin/env python3
from typing import Any
from kubernetes import client, config  # type: ignore

def main() -> None:
    config.load_kube_config()
    v1: Any = client.CoreV1Api()
    
    # Get services in monitoring namespace
    services: Any = v1.list_namespaced_service("monitoring")
    
    print("Services in monitoring namespace:")
    for svc in services.items:
        print(f"  Name: {svc.metadata.name}")
        print(f"  Type: {svc.spec.type}")
        print(f"  Ports: {svc.spec.ports[0].port if svc.spec.ports else 'N/A'}")
        print()

if __name__ == "__main__":
    main()
```

**Run:**
```bash
python3 src/service_info.py
```

**Expected Output:**
```
╔══════════════════════════════════════════════════════════════════════════╗
║                    KUBERNETES SERVICE INFORMATION                        ║
╚══════════════════════════════════════════════════════════════════════════╝

Services in monitoring namespace:

Service: prometheus-kube-prometheus-prometheus
  Type: ClusterIP
  ClusterIP: 10.96.123.45
  Port: 9090
  Selector: app.kubernetes.io/name=prometheus

Service: prometheus-grafana
  Type: ClusterIP
  ClusterIP: 10.96.234.56
  Port: 80
  Selector: app.kubernetes.io/name=grafana

Service: prometheus-kube-prometheus-alertmanager
  Type: ClusterIP
  ClusterIP: 10.96.345.67
  Port: 9093
  Selector: app.kubernetes.io/name=alertmanager
```

---

### Example 4: Check Cluster Health

**Script:** `scripts/check-health.py`

```python
#!/usr/bin/env python3
from typing import Any, List, bool
from kubernetes import client, config  # type: ignore

def check_nodes() -> bool:
    v1: Any = client.CoreV1Api()
    nodes: Any = v1.list_node()
    
    all_ready: bool = True
    for node in nodes.items:
        for condition in node.status.conditions:
            if condition.type == "Ready":
                if condition.status != "True":
                    print(f"❌ Node {node.metadata.name} is not ready")
                    all_ready = False
                else:
                    print(f"✅ Node {node.metadata.name} is ready")
    
    return all_ready

def check_critical_pods() -> bool:
    v1: Any = client.CoreV1Api()
    critical_namespaces: List[str] = ["kube-system", "monitoring"]
    
    all_healthy: bool = True
    for namespace in critical_namespaces:
        pods: Any = v1.list_namespaced_pod(namespace)
        
        running: int = 0
        total: int = len(pods.items)
        
        for pod in pods.items:
            if pod.status.phase == "Running":
                running += 1
        
        if running == total:
            print(f"✅ {namespace}: All pods running ({running}/{total})")
        else:
            print(f"❌ {namespace}: Some pods not running ({running}/{total})")
            all_healthy = False
    
    return all_healthy

def main() -> None:
    config.load_kube_config()
    
    print("Checking cluster health...\n")
    
    nodes_ok: bool = check_nodes()
    pods_ok: bool = check_critical_pods()
    
    if nodes_ok and pods_ok:
        print("\n✅ Cluster is healthy!")
    else:
        print("\n❌ Cluster has issues!")

if __name__ == "__main__":
    main()
```

**Run:**
```bash
python3 scripts/check-health.py
```

**Expected Output:**
```
╔══════════════════════════════════════════════════════════════════════════╗
║                    KUBERNETES CLUSTER HEALTH CHECK                       ║
╚══════════════════════════════════════════════════════════════════════════╝

Checking cluster health...

Node Health:
  ✅ Node minikube is ready

Critical Namespace Health:
  ✅ kube-system: All pods running (8/8)
  ✅ monitoring: All pods running (15/15)

✅ Cluster is healthy!
```

---

## 🔧 kubectl Command Examples

### Example 5: View Cluster Resources

```bash
# Get cluster info
kubectl cluster-info

# Get nodes
kubectl get nodes

# Get all namespaces
kubectl get namespaces

# Get all pods in all namespaces
kubectl get pods --all-namespaces

# Get pods in monitoring namespace
kubectl get pods -n monitoring

# Get services in monitoring namespace
kubectl get svc -n monitoring
```

**Expected Output:**
```bash
$ kubectl get pods -n monitoring

NAME                                                     READY   STATUS    RESTARTS   AGE
alertmanager-prometheus-kube-prometheus-alertmanager-0   2/2     Running   0          10m
prometheus-grafana-7d4c8f9b8d-x7k2m                     3/3     Running   0          10m
prometheus-kube-prometheus-operator-6b8c9d8f7d-9h4k5    1/1     Running   0          10m
prometheus-kube-state-metrics-5d6c7b8f9d-2j3k4          1/1     Running   0          10m
prometheus-prometheus-kube-prometheus-prometheus-0       2/2     Running   0          10m
prometheus-prometheus-node-exporter-abc12               1/1     Running   0          10m
```

---

### Example 6: Describe Resources

```bash
# Describe a node
kubectl describe node minikube

# Describe a pod
kubectl describe pod <pod-name> -n monitoring

# Describe a service
kubectl describe svc prometheus-grafana -n monitoring
```

---

### Example 7: View Logs

```bash
# View logs from a pod
kubectl logs <pod-name> -n monitoring

# Follow logs in real-time
kubectl logs -f <pod-name> -n monitoring

# View logs from previous container instance
kubectl logs <pod-name> -n monitoring --previous

# View logs from specific container in pod
kubectl logs <pod-name> -c <container-name> -n monitoring
```

---

## 📊 Prometheus Query Examples

### Example 8: Basic Metrics Queries

Access Prometheus at http://localhost:9090 and try these queries:

**CPU Usage:**
```promql
# Node CPU usage percentage
100 - (avg(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Pod CPU usage
sum(rate(container_cpu_usage_seconds_total{container!="",container!="POD"}[5m])) by (namespace, pod)

# Top 10 pods by CPU
topk(10, sum(rate(container_cpu_usage_seconds_total{container!="",container!="POD"}[5m])) by (pod, namespace))
```

**Memory Usage:**
```promql
# Node memory usage percentage
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

# Pod memory usage
sum(container_memory_usage_bytes{container!="",container!="POD"}) by (namespace, pod)

# Top 10 pods by memory
topk(10, sum(container_memory_usage_bytes{container!="",container!="POD"}) by (pod, namespace))
```

**Pod Status:**
```promql
# Count pods by phase
count(kube_pod_status_phase) by (phase)

# Running pods
count(kube_pod_status_phase{phase="Running"})

# Failed pods
count(kube_pod_status_phase{phase="Failed"})
```

**Network I/O:**
```promql
# Network receive rate
rate(node_network_receive_bytes_total[5m])

# Network transmit rate
rate(node_network_transmit_bytes_total[5m])
```

---

### Example 9: Alert Queries

**Check Firing Alerts:**
```promql
# All firing alerts
ALERTS{alertstate="firing"}

# Critical alerts only
ALERTS{alertstate="firing",severity="critical"}

# Alerts for specific namespace
ALERTS{namespace="monitoring"}
```

---

## 📈 Grafana Dashboard Examples

### Example 10: View Dashboards

1. **Access Grafana:**
   ```bash
   # Start port forward
   kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
   
   # Open browser
   open http://localhost:3000
   
   # Login: admin / prom-operator
   ```

2. **Navigate to Dashboards:**
   - Click **Dashboards** → **Browse**
   - Select a dashboard:
     - Kubernetes Cluster Overview
     - Kubernetes Resource Monitoring - CPU & Memory
     - Pod Resource Details - CPU & Memory
     - Namespace Resource Monitoring

3. **Customize Time Range:**
   - Click time picker in top-right
   - Select: Last 5 minutes, Last 15 minutes, Last 1 hour, etc.

4. **Use Variables:**
   - In "Pod Resource Details" dashboard
   - Select namespace from dropdown
   - Select pod from dropdown
   - View filtered metrics

---

## 🤖 Automation Examples

### Example 11: Automated Setup

```bash
#!/bin/bash
# Complete setup automation

# 1. Setup cluster
./scripts/setup-minikube.sh

# 2. Configure monitoring
./scripts/configure-monitoring.sh

# 3. Start port forwards
./scripts/start-port-forwards.sh

# 4. Run health check
source venv/bin/activate
python3 scripts/check-health.py

# 5. Show resource usage
python3 scripts/show-resource-usage.py

echo "✅ Setup complete!"
```

---

### Example 12: Daily Health Check

```bash
#!/bin/bash
# Daily health check script

echo "Running daily health check..."

# Activate virtual environment
source venv/bin/activate

# Run health check
python3 scripts/check-health.py

# Show resource usage
python3 scripts/show-resource-usage.py

# Test alerts
python3 scripts/test-alerts.py

echo "✅ Daily health check complete!"
```

---

### Example 13: Resource Monitoring Loop

```bash
#!/bin/bash
# Monitor resources every 30 seconds

source venv/bin/activate

while true; do
    clear
    echo "=== Resource Usage - $(date) ==="
    python3 scripts/show-resource-usage.py
    sleep 30
done
```

---

## 🔍 Troubleshooting Examples

### Example 14: Debug Pod Issues

```bash
# Get pod status
kubectl get pods -n monitoring

# Describe problematic pod
kubectl describe pod <pod-name> -n monitoring

# View pod logs
kubectl logs <pod-name> -n monitoring

# Get events
kubectl get events -n monitoring --sort-by='.lastTimestamp'

# Execute command in pod
kubectl exec -it <pod-name> -n monitoring -- /bin/sh
```

---

### Example 15: Check Resource Usage

```bash
# Node resource usage
kubectl top nodes

# Pod resource usage
kubectl top pods -n monitoring

# All pods resource usage
kubectl top pods --all-namespaces
```

---

### Example 16: Restart Services

```bash
# Restart Grafana
kubectl rollout restart deployment prometheus-grafana -n monitoring

# Restart Prometheus
kubectl rollout restart statefulset prometheus-prometheus-kube-prometheus-prometheus -n monitoring

# Check rollout status
kubectl rollout status deployment prometheus-grafana -n monitoring
```

---

## 📚 Additional Examples

### Example 17: Export Metrics

```bash
# Export Prometheus metrics
curl http://localhost:9090/api/v1/query?query=up

# Export to file
curl http://localhost:9090/api/v1/query?query=up > metrics.json
```

---

### Example 18: Backup Configuration

```bash
# Backup Prometheus config
kubectl get configmap prometheus-custom-alerts -n monitoring -o yaml > prometheus-alerts-backup.yaml

# Backup Grafana dashboards
kubectl get configmap grafana-dashboard-cluster-overview -n monitoring -o yaml > dashboard-backup.yaml
```

---

### Example 19: Scale Resources

```bash
# Scale Grafana replicas
kubectl scale deployment prometheus-grafana --replicas=2 -n monitoring

# Check scaling
kubectl get deployment prometheus-grafana -n monitoring
```

---

### Example 20: Clean Up

```bash
# Stop port forwards
./scripts/stop-port-forwards.sh

# Delete Minikube cluster
minikube delete

# Clean up virtual environment
deactivate
rm -rf venv
```

---

## 🎯 Best Practices

1. **Always activate virtual environment** before running Python scripts
2. **Use port forwards** to access services securely
3. **Monitor resource usage** regularly
4. **Check logs** when troubleshooting
5. **Backup configurations** before making changes
6. **Test in development** before production
7. **Document custom changes**
8. **Keep dependencies updated**

---

**Happy Coding!** 🚀

