# Monitoring Quick Reference Card

Quick reference for Prometheus alerts and Grafana dashboards.

---

## ⚡ Quick Commands

### Setup Monitoring
```bash
# Configure Prometheus & Grafana
./scripts/configure-monitoring.sh

# Start port forwards
./scripts/start-port-forwards.sh

# Test alerts
source venv/bin/activate
python3 scripts/test-alerts.py

# Show resource usage
python3 scripts/show-resource-usage.py
```

### Access Services
```bash
# Prometheus
open http://localhost:9090

# Grafana (admin/prom-operator)
open http://localhost:3000

# AlertManager
open http://localhost:9093
```

---

## 🔔 Alert Summary

### Critical Alerts (🔴)
| Alert | Condition | Duration |
|-------|-----------|----------|
| NodeDown | Node is down | 5 min |
| PodCrashLooping | Pod restarting | 5 min |
| KubernetesAPIServerDown | API server down | 5 min |
| PrometheusDown | Prometheus down | 5 min |

### Warning Alerts (🟡)
| Alert | Condition | Duration |
|-------|-----------|----------|
| NodeHighCPU | CPU > 80% | 5 min |
| NodeHighMemory | Memory > 85% | 5 min |
| NodeDiskSpaceLow | Disk > 80% | 5 min |
| PodNotReady | Pod not ready | 10 min |
| PodHighCPU | Pod CPU > 80% | 5 min |
| PodHighMemory | Pod memory > 85% | 5 min |
| DeploymentReplicasMismatch | Replicas mismatch | 10 min |
| PersistentVolumeSpaceLow | PV < 20% free | 5 min |
| KubernetesAPIHighLatency | API latency > 1s | 10 min |
| PrometheusConfigReloadFailed | Config reload failed | 5 min |
| PrometheusTooManyRestarts | Too many restarts | 5 min |
| PrometheusTargetDown | Target down | 5 min |
| GrafanaDown | Grafana down | 5 min |

---

## 📊 Dashboard Summary

### Custom Dashboards
- **Kubernetes Cluster Overview** - Overall cluster status
  - Cluster status (nodes, pods)
  - CPU & Memory gauges
  - Time series graphs
  - Network & Disk I/O
  - Pod status breakdown

- **Kubernetes Resource Monitoring - CPU & Memory** - Detailed resource monitoring
  - Node CPU and Memory usage
  - Namespace resource usage
  - Top 10 pods by CPU and Memory
  - Container-level details
  - Deployment, StatefulSet, DaemonSet resources
  - Requests vs Usage comparison

- **Pod Resource Details - CPU & Memory** - Per-pod monitoring
  - Filter by namespace and pod
  - CPU and Memory usage per container
  - CPU throttling tracking
  - Resource limits vs usage
  - Network and Filesystem I/O

- **Namespace Resource Monitoring** - Namespace-level overview
  - Summary statistics
  - CPU and Memory trends
  - Requests vs Limits vs Usage
  - Top pods by resource usage
  - Resource quota usage

### Pre-installed Dashboards
- **Kubernetes / Compute Resources / Cluster** - Overall cluster metrics
- **Kubernetes / Compute Resources / Namespace** - Per-namespace metrics
- **Kubernetes / Compute Resources / Pod** - Individual pod metrics
- **Node Exporter / Nodes** - Detailed node metrics

---

## 📈 Key Metrics

### CPU Usage
```promql
100 - (avg(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

### Memory Usage
```promql
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
```

### Pod Count by Status
```promql
count(kube_pod_status_phase) by (phase)
```

### Network I/O
```promql
rate(node_network_receive_bytes_total[5m])
rate(node_network_transmit_bytes_total[5m])
```

### Disk Usage
```promql
(1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes)) * 100
```

---

## 🔍 Useful PromQL Queries

### View All Firing Alerts
```promql
ALERTS{alertstate="firing"}
```

### Critical Alerts Only
```promql
ALERTS{alertstate="firing",severity="critical"}
```

### Alerts by Namespace
```promql
ALERTS{namespace="monitoring"}
```

### Top CPU Consuming Pods
```promql
topk(5, sum(rate(container_cpu_usage_seconds_total[5m])) by (pod))
```

### Top Memory Consuming Pods
```promql
topk(5, sum(container_memory_usage_bytes) by (pod))
```

### Pod Restart Count
```promql
kube_pod_container_status_restarts_total
```

---

## 🛠️ Troubleshooting Commands

### Check Alert ConfigMap
```bash
kubectl get configmap prometheus-custom-alerts -n monitoring
kubectl describe configmap prometheus-custom-alerts -n monitoring
```

### Check Dashboard ConfigMap
```bash
kubectl get configmap grafana-dashboard-cluster-overview -n monitoring
kubectl get configmap grafana-dashboard-cluster-overview -n monitoring --show-labels
```

### View Prometheus Logs
```bash
kubectl logs -n monitoring -l app.kubernetes.io/name=prometheus
```

### View Grafana Logs
```bash
kubectl logs -n monitoring -l app.kubernetes.io/name=grafana
```

### Restart Services
```bash
# Restart Prometheus
kubectl rollout restart statefulset prometheus-prometheus-kube-prometheus-prometheus -n monitoring

# Restart Grafana
kubectl rollout restart deployment prometheus-grafana -n monitoring

# Restart AlertManager
kubectl rollout restart statefulset alertmanager-prometheus-kube-prometheus-alertmanager -n monitoring
```

### Get Grafana Password
```bash
kubectl get secret -n monitoring prometheus-grafana \
  -o jsonpath="{.data.admin-password}" | base64 --decode
echo
```

### Check Port Forwards
```bash
# List running port forwards
ps aux | grep "port-forward"

# Kill all port forwards
pkill -f "port-forward"
```

---

## 📁 File Locations

### Configuration Files
```
config/
├── prometheus-alerts.yaml              # Alert rules
└── grafana-dashboard-cluster-overview.json  # Custom dashboard
```

### Scripts
```
scripts/
├── configure-monitoring.sh   # Setup monitoring
├── test-alerts.py           # Test alerts
├── start-port-forwards.sh   # Start port forwards
└── stop-port-forwards.sh    # Stop port forwards
```

### Documentation
```
MONITORING_GUIDE.md              # Complete guide
MONITORING_QUICK_REFERENCE.md    # This file
```

---

## 🎯 Common Tasks

### View Alerts in Prometheus
1. Open http://localhost:9090
2. Click **Alerts** tab
3. See all configured alerts

### View Firing Alerts in AlertManager
1. Open http://localhost:9093
2. See currently firing alerts
3. Create silences if needed

### Create Custom Dashboard
1. Open Grafana: http://localhost:3000
2. Click **+** → **Dashboard**
3. Add panels with PromQL queries
4. Save dashboard

### Export Dashboard
1. Open dashboard in Grafana
2. Click **Dashboard settings** (gear icon)
3. Click **JSON Model**
4. Copy JSON and save to file

### Import Dashboard
1. Click **Dashboards** → **Import**
2. Paste JSON or upload file
3. Select Prometheus datasource
4. Click **Import**

---

## 🔗 Quick Links

### Prometheus
- UI: http://localhost:9090
- Alerts: http://localhost:9090/alerts
- Targets: http://localhost:9090/targets
- Config: http://localhost:9090/config

### Grafana
- UI: http://localhost:3000
- Dashboards: http://localhost:3000/dashboards
- Explore: http://localhost:3000/explore

### AlertManager
- UI: http://localhost:9093
- Alerts: http://localhost:9093/#/alerts

---

## 📚 Documentation

- **MONITORING_GUIDE.md** - Complete monitoring guide
- **GETTING_STARTED.md** - Initial setup
- **ACCESS_SERVICES.md** - Port forwarding guide
- **TROUBLESHOOTING.md** - Common issues

---

**Quick Reference v1.0** | Last Updated: 2025-10-11

