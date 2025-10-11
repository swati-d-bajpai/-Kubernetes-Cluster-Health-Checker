# Prometheus & Grafana Monitoring Guide

Complete guide for configuring and using Prometheus alerts and Grafana dashboards.

---

## 📋 Table of Contents

1. [Quick Start](#quick-start)
2. [Prometheus Alerts](#prometheus-alerts)
3. [Grafana Dashboards](#grafana-dashboards)
4. [Accessing Services](#accessing-services)
5. [Alert Reference](#alert-reference)
6. [Dashboard Reference](#dashboard-reference)
7. [Troubleshooting](#troubleshooting)

---

## 🚀 Quick Start

### Step 1: Configure Monitoring

Run the configuration script:

```bash
./scripts/configure-monitoring.sh
```

This will:
- ✅ Apply Prometheus alert rules
- ✅ Configure Grafana datasource
- ✅ Import custom dashboards
- ✅ Restart Prometheus and Grafana

### Step 2: Start Port Forwards

```bash
./scripts/start-port-forwards.sh
```

### Step 3: Access Services

- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000 (admin/prom-operator)
- **AlertManager**: http://localhost:9093

---

## 🔔 Prometheus Alerts

### Configured Alert Groups

#### 1. **Kubernetes Cluster Alerts**

**Node Alerts:**
- `NodeDown` - Node is down for > 5 minutes (Critical)
- `NodeHighCPU` - CPU usage > 80% for > 5 minutes (Warning)
- `NodeHighMemory` - Memory usage > 85% for > 5 minutes (Warning)
- `NodeDiskSpaceLow` - Disk usage > 80% for > 5 minutes (Warning)

**Pod Alerts:**
- `PodCrashLooping` - Pod restarting frequently (Critical)
- `PodNotReady` - Pod not ready for > 10 minutes (Warning)
- `PodHighCPU` - Pod CPU > 80% for > 5 minutes (Warning)
- `PodHighMemory` - Pod memory > 85% of limit (Warning)

**Deployment Alerts:**
- `DeploymentReplicasMismatch` - Replicas don't match for > 10 minutes (Warning)

**Storage Alerts:**
- `PersistentVolumeSpaceLow` - PV has < 20% space (Warning)

**API Server Alerts:**
- `KubernetesAPIServerDown` - API server down > 5 minutes (Critical)
- `KubernetesAPIHighLatency` - 99th percentile latency > 1s (Warning)

#### 2. **Prometheus Self-Monitoring Alerts**

- `PrometheusDown` - Prometheus is down (Critical)
- `PrometheusConfigReloadFailed` - Config reload failed (Warning)
- `PrometheusTooManyRestarts` - Restarting too frequently (Warning)
- `PrometheusTargetDown` - Scrape target is down (Warning)

#### 3. **Grafana Monitoring Alerts**

- `GrafanaDown` - Grafana is down for > 5 minutes (Warning)

### Viewing Alerts

#### In Prometheus UI:

1. Open http://localhost:9090
2. Click **Alerts** in the top menu
3. See all configured alerts and their status

#### In AlertManager:

1. Open http://localhost:9093
2. See currently firing alerts
3. Manage alert silences

#### Using Python Scripts:

**Test Alerts:**
```bash
# Activate virtual environment
source venv/bin/activate

# Run test script
python3 scripts/test-alerts.py
```

**Show Resource Usage:**
```bash
# Activate virtual environment
source venv/bin/activate

# Show CPU and Memory usage for all resources
python3 scripts/show-resource-usage.py
```

This will display:
- Cluster resource summary
- Node CPU and Memory usage
- Namespace resource usage
- Top 10 pods by CPU and Memory

---

## 📊 Grafana Dashboards

### Pre-installed Dashboards

The kube-prometheus-stack comes with many pre-built dashboards:

1. **Kubernetes / Compute Resources / Cluster**
   - Overall cluster resource usage
   - CPU, Memory, Network, Disk metrics

2. **Kubernetes / Compute Resources / Namespace**
   - Per-namespace resource usage
   - Pod metrics by namespace

3. **Kubernetes / Compute Resources / Pod**
   - Individual pod metrics
   - Container resource usage

4. **Node Exporter / Nodes**
   - Detailed node metrics
   - System-level monitoring

### Custom Dashboards

#### 1. Kubernetes Cluster Overview

**Top Row - Key Metrics:**
- Total Nodes count
- Running Pods count
- CPU Usage gauge (with thresholds)
- Memory Usage gauge (with thresholds)

**Middle Section - Time Series:**
- CPU Usage Over Time graph
- Memory Usage Over Time graph
- Pod Status by Phase (pie chart)
- Network I/O graph

**Bottom Section - Storage & I/O:**
- Disk I/O graph
- Disk Space Usage graph

#### 2. Kubernetes Resource Monitoring - CPU & Memory

**Comprehensive resource monitoring for all Kubernetes resources:**

- **Node Resources:** CPU and Memory usage per node
- **Namespace Resources:** CPU and Memory by namespace
- **Top 10 Pods:** Highest CPU and Memory consumers
- **Container Details:** CPU and Memory per container
- **Deployment Resources:** CPU and Memory by deployment
- **StatefulSet Resources:** CPU and Memory by statefulset
- **DaemonSet Resources:** CPU and Memory by daemonset
- **Requests vs Usage:** Compare resource requests with actual usage

#### 3. Pod Resource Details - CPU & Memory

**Detailed per-pod monitoring with filters:**

- **Variables:** Select namespace and pod from dropdowns
- **Pod CPU Usage:** Real-time CPU usage per container
- **Pod Memory Usage:** Real-time memory usage per container
- **CPU Throttling:** Track CPU throttling events
- **Memory Working Set:** Active memory usage
- **Resource Tables:** Sortable tables with all pods
- **Limits vs Usage:** Compare resource limits with actual usage
- **Network I/O:** Network traffic per pod
- **Filesystem Usage:** Disk usage per pod

#### 4. Namespace Resource Monitoring

**Namespace-level resource overview:**

- **Summary Stats:** CPU, Memory, Pod count, Container count
- **Time Series:** CPU and Memory trends over time
- **Requests vs Limits vs Usage:** Three-way comparison
- **Top Pods:** Bar charts showing top consumers
- **Resource Quota:** Gauge showing quota usage percentage

### Accessing Dashboards

1. Open Grafana: http://localhost:3000
2. Login with:
   - Username: `admin`
   - Password: `prom-operator`
3. Click **Dashboards** → **Browse**
4. Select a dashboard to view

### Dashboard Features

- **Auto-refresh**: Dashboards refresh every 30 seconds
- **Time range**: Adjust time range in top-right corner
- **Variables**: Some dashboards have dropdown filters
- **Zoom**: Click and drag on graphs to zoom
- **Panel details**: Click panel title → View

---

## 🌐 Accessing Services

### Method 1: Manual Port Forwards

```bash
# Prometheus
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090

# Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80

# AlertManager
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-alertmanager 9093:9093
```

### Method 2: Automated Script (Recommended)

```bash
# Start all port forwards
./scripts/start-port-forwards.sh

# Stop all port forwards
./scripts/stop-port-forwards.sh
```

### Service URLs

| Service | URL | Credentials |
|---------|-----|-------------|
| Prometheus | http://localhost:9090 | None |
| Grafana | http://localhost:3000 | admin / prom-operator |
| AlertManager | http://localhost:9093 | None |

---

## 📖 Alert Reference

### Alert Severity Levels

- **Critical** 🔴: Immediate action required
- **Warning** 🟡: Should be investigated soon
- **Info** 🔵: Informational only

### Alert States

- **Inactive**: Alert condition not met
- **Pending**: Alert condition met, waiting for duration
- **Firing**: Alert is active and firing

### Common Alert Queries

View alerts in Prometheus:
```promql
# All firing alerts
ALERTS{alertstate="firing"}

# Critical alerts only
ALERTS{alertstate="firing",severity="critical"}

# Alerts for specific namespace
ALERTS{namespace="monitoring"}
```

---

## 📊 Dashboard Reference

### Key Metrics Explained

**CPU Usage:**
```promql
100 - (avg(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```
Shows percentage of CPU in use (100% - idle time)

**Memory Usage:**
```promql
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
```
Shows percentage of memory in use

**Pod Status:**
```promql
count(kube_pod_status_phase) by (phase)
```
Counts pods by their current phase (Running, Pending, Failed, etc.)

**Network I/O:**
```promql
rate(node_network_receive_bytes_total[5m])
rate(node_network_transmit_bytes_total[5m])
```
Shows network traffic in bytes per second

---

## 🔧 Troubleshooting

### Alerts Not Showing

**Problem**: No alerts visible in Prometheus

**Solutions**:
1. Check if alerts ConfigMap is applied:
   ```bash
   kubectl get configmap prometheus-custom-alerts -n monitoring
   ```

2. Reload Prometheus configuration:
   ```bash
   ./scripts/configure-monitoring.sh
   ```

3. Check Prometheus logs:
   ```bash
   kubectl logs -n monitoring -l app.kubernetes.io/name=prometheus
   ```

### Dashboard Not Loading

**Problem**: Custom dashboard not visible in Grafana

**Solutions**:
1. Check if ConfigMap exists:
   ```bash
   kubectl get configmap grafana-dashboard-cluster-overview -n monitoring
   ```

2. Check ConfigMap labels:
   ```bash
   kubectl get configmap grafana-dashboard-cluster-overview -n monitoring --show-labels
   ```

3. Restart Grafana:
   ```bash
   kubectl rollout restart deployment prometheus-grafana -n monitoring
   ```

### Port Forward Issues

**Problem**: Cannot access services on localhost

**Solutions**:
1. Check if port forwards are running:
   ```bash
   ps aux | grep "port-forward"
   ```

2. Stop and restart port forwards:
   ```bash
   ./scripts/stop-port-forwards.sh
   ./scripts/start-port-forwards.sh
   ```

3. Check if services are running:
   ```bash
   kubectl get svc -n monitoring
   ```

### Grafana Login Issues

**Problem**: Cannot login to Grafana

**Solutions**:
1. Get the correct password:
   ```bash
   kubectl get secret -n monitoring prometheus-grafana \
     -o jsonpath="{.data.admin-password}" | base64 --decode
   ```

2. Default credentials:
   - Username: `admin`
   - Password: `prom-operator`

---

## 📚 Additional Resources

### Prometheus Documentation
- Official Docs: https://prometheus.io/docs/
- Query Language: https://prometheus.io/docs/prometheus/latest/querying/basics/
- Alerting Rules: https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/

### Grafana Documentation
- Official Docs: https://grafana.com/docs/
- Dashboard Guide: https://grafana.com/docs/grafana/latest/dashboards/
- Panel Types: https://grafana.com/docs/grafana/latest/panels/

### Kubernetes Monitoring
- kube-prometheus-stack: https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack
- Best Practices: https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/

---

## 🎯 Next Steps

1. ✅ Configure monitoring (Done!)
2. 📊 Explore pre-built dashboards
3. 🎨 Create custom dashboards
4. 🔔 Set up alert notifications (Slack, Email, etc.)
5. 📈 Add custom metrics from your applications
6. 🔍 Learn PromQL for advanced queries

---

**Happy Monitoring!** 📊🔔

