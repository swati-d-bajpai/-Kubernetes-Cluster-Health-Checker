# Prometheus & Grafana Queries Reference

Complete reference of all PromQL queries used in this project for Prometheus alerts and Grafana dashboards.

---

## 📋 Table of Contents

1. [Prometheus Alert Queries](#prometheus-alert-queries)
2. [Grafana Dashboard Queries](#grafana-dashboard-queries)
3. [Query Categories](#query-categories)
4. [Common Patterns](#common-patterns)
5. [Query Optimization Tips](#query-optimization-tips)

---

## 🚨 Prometheus Alert Queries

All alert queries from `config/prometheus-alerts.yaml`

### Node Alerts

#### 1. NodeDown
```promql
up{job="kubernetes-nodes"} == 0
```
**Purpose:** Detect when a Kubernetes node is down  
**Duration:** 5 minutes  
**Severity:** Critical  

---

#### 2. NodeHighCPU
```promql
(100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)) > 80
```
**Purpose:** Detect high CPU usage on nodes (>80%)  
**Duration:** 5 minutes  
**Severity:** Warning  

---

#### 3. NodeHighMemory
```promql
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 85
```
**Purpose:** Detect high memory usage on nodes (>85%)  
**Duration:** 5 minutes  
**Severity:** Warning  

---

#### 4. NodeDiskSpaceLow
```promql
(1 - (node_filesystem_avail_bytes{fstype!="tmpfs"} / node_filesystem_size_bytes{fstype!="tmpfs"})) * 100 > 80
```
**Purpose:** Detect low disk space on nodes (>80% used)  
**Duration:** 5 minutes  
**Severity:** Warning  

---

### Pod Alerts

#### 5. PodCrashLooping
```promql
rate(kube_pod_container_status_restarts_total[15m]) > 0
```
**Purpose:** Detect pods that are crash looping  
**Duration:** 5 minutes  
**Severity:** Critical  

---

#### 6. PodNotReady
```promql
kube_pod_status_phase{phase!="Running",phase!="Succeeded"} == 1
```
**Purpose:** Detect pods not in Running or Succeeded state  
**Duration:** 10 minutes  
**Severity:** Warning  

---

#### 7. PodHighCPU
```promql
sum(rate(container_cpu_usage_seconds_total{container!=""}[5m])) by (pod, namespace) > 0.8
```
**Purpose:** Detect high CPU usage in pods (>80%)  
**Duration:** 5 minutes  
**Severity:** Warning  

---

#### 8. PodHighMemory
```promql
sum(container_memory_usage_bytes{container!=""}) by (pod, namespace) / sum(container_spec_memory_limit_bytes{container!=""}) by (pod, namespace) > 0.85
```
**Purpose:** Detect high memory usage in pods (>85% of limit)  
**Duration:** 5 minutes  
**Severity:** Warning  

---

### Deployment Alerts

#### 9. DeploymentReplicasMismatch
```promql
kube_deployment_spec_replicas != kube_deployment_status_replicas_available
```
**Purpose:** Detect when deployment replicas don't match expected count  
**Duration:** 10 minutes  
**Severity:** Warning  

---

### Container Alerts

#### 10. ContainerKilled
```promql
time() - container_last_seen > 60
```
**Purpose:** Detect when a container was killed  
**Duration:** 5 minutes  
**Severity:** Warning  

---

### Storage Alerts

#### 11. PersistentVolumeSpaceLow
```promql
(kubelet_volume_stats_available_bytes / kubelet_volume_stats_capacity_bytes) * 100 < 20
```
**Purpose:** Detect low space on persistent volumes (<20% available)  
**Duration:** 5 minutes  
**Severity:** Warning  

---

### API Server Alerts

#### 12. KubernetesAPIServerDown
```promql
up{job="kubernetes-apiservers"} == 0
```
**Purpose:** Detect when Kubernetes API server is down  
**Duration:** 5 minutes  
**Severity:** Critical  

---

#### 13. KubernetesAPIHighLatency
```promql
histogram_quantile(0.99, sum(rate(apiserver_request_duration_seconds_bucket{verb!="WATCH"}[5m])) by (verb, le)) > 1
```
**Purpose:** Detect high API server latency (99th percentile >1s)  
**Duration:** 10 minutes  
**Severity:** Warning  

---

### Prometheus Self-Monitoring Alerts

#### 14. PrometheusDown
```promql
up{job="prometheus"} == 0
```
**Purpose:** Detect when Prometheus is down  
**Duration:** 5 minutes  
**Severity:** Critical  

---

#### 15. PrometheusConfigReloadFailed
```promql
prometheus_config_last_reload_successful == 0
```
**Purpose:** Detect failed Prometheus configuration reload  
**Duration:** 5 minutes  
**Severity:** Warning  

---

#### 16. PrometheusTooManyRestarts
```promql
changes(process_start_time_seconds{job="prometheus"}[15m]) > 2
```
**Purpose:** Detect when Prometheus restarts too frequently (>2 in 15 min)  
**Duration:** 5 minutes  
**Severity:** Warning  

---

#### 17. PrometheusTargetDown
```promql
up == 0
```
**Purpose:** Detect when any Prometheus target is down  
**Duration:** 5 minutes  
**Severity:** Warning  

---

### Grafana Monitoring Alerts

#### 18. GrafanaDown
```promql
up{job="grafana"} == 0
```
**Purpose:** Detect when Grafana is down  
**Duration:** 5 minutes  
**Severity:** Warning  

---

## 📊 Grafana Dashboard Queries

### Dashboard 1: Cluster Overview

#### Panel 1: Cluster Status (Total Nodes)
```promql
count(kube_node_info)
```
**Shows:** Total number of nodes in the cluster

---

#### Panel 2: Running Pods
```promql
count(kube_pod_status_phase{phase="Running"})
```
**Shows:** Total number of running pods

---

#### Panel 3: CPU Usage
```promql
100 - (avg(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```
**Shows:** Average CPU usage across all nodes (%)

---

#### Panel 4: Memory Usage
```promql
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
```
**Shows:** Average memory usage across all nodes (%)

---

#### Panel 5: CPU Usage Over Time
```promql
100 - (avg(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```
**Shows:** CPU usage trend over time

---

#### Panel 6: Memory Usage Over Time
```promql
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
```
**Shows:** Memory usage trend over time

---

#### Panel 7: Pod Status by Phase
```promql
count(kube_pod_status_phase) by (phase)
```
**Shows:** Pod count grouped by phase (Running, Pending, Failed, etc.)

---

#### Panel 8: Network I/O (Receive)
```promql
rate(node_network_receive_bytes_total[5m])
```
**Shows:** Network receive rate per device

#### Panel 8: Network I/O (Transmit)
```promql
rate(node_network_transmit_bytes_total[5m])
```
**Shows:** Network transmit rate per device

---

#### Panel 9: Disk I/O (Read)
```promql
rate(node_disk_read_bytes_total[5m])
```
**Shows:** Disk read rate per device

#### Panel 9: Disk I/O (Write)
```promql
rate(node_disk_written_bytes_total[5m])
```
**Shows:** Disk write rate per device

---

#### Panel 10: Disk Space Usage
```promql
(1 - (node_filesystem_avail_bytes{fstype!="tmpfs"} / node_filesystem_size_bytes{fstype!="tmpfs"})) * 100
```
**Shows:** Disk space usage per mount point (%)

---

### Dashboard 2: Alerts Overview

#### Panel 1: Firing Alerts Count
```promql
count(ALERTS{alertstate="firing"})
```
**Shows:** Total number of firing alerts

---

#### Panel 2: Critical Alerts Count
```promql
count(ALERTS{alertstate="firing",severity="critical"})
```
**Shows:** Number of critical severity alerts

---

#### Panel 3: Warning Alerts Count
```promql
count(ALERTS{alertstate="firing",severity="warning"})
```
**Shows:** Number of warning severity alerts

---

#### Panel 4: Pending Alerts Count
```promql
count(ALERTS{alertstate="pending"})
```
**Shows:** Number of pending alerts

---

#### Panel 5: Currently Firing Alerts (Table)
```promql
ALERTS{alertstate="firing"}
```
**Shows:** All currently firing alerts with details

---

#### Panel 6: Alerts by Severity (Time Series)
```promql
count(ALERTS{alertstate="firing"}) by (severity)
```
**Shows:** Alert count over time grouped by severity

---

#### Panel 7: Alert Distribution (Donut Chart)
```promql
count(ALERTS{alertstate="firing"}) by (severity)
```
**Shows:** Percentage distribution of alerts by severity

---

#### Panel 8: Pending Alerts (Table)
```promql
ALERTS{alertstate="pending"}
```
**Shows:** All pending alerts with details

---

#### Panel 9: Alert Frequency by Name
```promql
count(ALERTS{alertstate="firing"}) by (alertname)
```
**Shows:** Alert count over time grouped by alert name

---

#### Panel 10: Top Firing Alerts
```promql
count(ALERTS{alertstate="firing"}) by (alertname)
```
**Shows:** Most frequently firing alerts

---

#### Panel 11: Alerts by Namespace
```promql
count(ALERTS{alertstate="firing"}) by (namespace)
```
**Shows:** Alert count grouped by namespace

---

#### Panel 12: All Alerts (Complete List)
```promql
ALERTS
```
**Shows:** Every alert (firing, pending, inactive)

---

### Dashboard 3: Resource Monitoring

#### Panel 1: Node CPU Usage
```promql
100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```
**Shows:** CPU usage per node

---

#### Panel 2: Node Memory Usage
```promql
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
```
**Shows:** Memory usage per node

---

#### Panel 3: Pod CPU Usage by Namespace
```promql
sum(rate(container_cpu_usage_seconds_total{container!="",container!="POD"}[5m])) by (namespace)
```
**Shows:** CPU usage grouped by namespace

---

#### Panel 4: Pod Memory Usage by Namespace
```promql
sum(container_memory_usage_bytes{container!="",container!="POD"}) by (namespace)
```
**Shows:** Memory usage grouped by namespace

---

#### Panel 5: Top 10 Pods by CPU
```promql
topk(10, sum(rate(container_cpu_usage_seconds_total{container!="",container!="POD"}[5m])) by (pod, namespace))
```
**Shows:** Top 10 pods consuming most CPU

---

#### Panel 6: Top 10 Pods by Memory
```promql
topk(10, sum(container_memory_usage_bytes{container!="",container!="POD"}) by (pod, namespace))
```
**Shows:** Top 10 pods consuming most memory

---

#### Panel 7: Container CPU Usage by Pod (Table)
```promql
sum(rate(container_cpu_usage_seconds_total{container!="",container!="POD"}[5m])) by (namespace, pod, container)
```
**Shows:** CPU usage per container in each pod

---

#### Panel 8: Container Memory Usage by Pod (Table)
```promql
sum(container_memory_usage_bytes{container!="",container!="POD"}) by (namespace, pod, container)
```
**Shows:** Memory usage per container in each pod

---

#### Panel 9: Deployment CPU Usage
```promql
sum(rate(container_cpu_usage_seconds_total{container!="",container!="POD"}[5m])) by (namespace, pod) * on(namespace, pod) group_left(owner_name) kube_pod_owner{owner_kind="ReplicaSet"}
```
**Shows:** CPU usage for deployments

---

#### Panel 10: Deployment Memory Usage
```promql
sum(container_memory_usage_bytes{container!="",container!="POD"}) by (namespace, pod) * on(namespace, pod) group_left(owner_name) kube_pod_owner{owner_kind="ReplicaSet"}
```
**Shows:** Memory usage for deployments

---

#### Panel 11: StatefulSet CPU Usage
```promql
sum(rate(container_cpu_usage_seconds_total{container!="",container!="POD"}[5m])) by (namespace, pod) * on(namespace, pod) group_left(owner_name) kube_pod_owner{owner_kind="StatefulSet"}
```
**Shows:** CPU usage for statefulsets

---

#### Panel 12: StatefulSet Memory Usage
```promql
sum(container_memory_usage_bytes{container!="",container!="POD"}) by (namespace, pod) * on(namespace, pod) group_left(owner_name) kube_pod_owner{owner_kind="StatefulSet"}
```
**Shows:** Memory usage for statefulsets

---

#### Panel 13: DaemonSet CPU Usage
```promql
sum(rate(container_cpu_usage_seconds_total{container!="",container!="POD"}[5m])) by (namespace, pod) * on(namespace, pod) group_left(owner_name) kube_pod_owner{owner_kind="DaemonSet"}
```
**Shows:** CPU usage for daemonsets

---

#### Panel 14: DaemonSet Memory Usage
```promql
sum(container_memory_usage_bytes{container!="",container!="POD"}) by (namespace, pod) * on(namespace, pod) group_left(owner_name) kube_pod_owner{owner_kind="DaemonSet"}
```
**Shows:** Memory usage for daemonsets

---

#### Panel 15: CPU Requests vs Usage by Namespace
```promql
# CPU Requests
sum(kube_pod_container_resource_requests{resource="cpu"}) by (namespace)

# CPU Usage
sum(rate(container_cpu_usage_seconds_total{container!="",container!="POD"}[5m])) by (namespace)
```
**Shows:** Comparison of CPU requests vs actual usage

---

#### Panel 16: Memory Requests vs Usage by Namespace
```promql
# Memory Requests
sum(kube_pod_container_resource_requests{resource="memory"}) by (namespace)

# Memory Usage
sum(container_memory_usage_bytes{container!="",container!="POD"}) by (namespace)
```
**Shows:** Comparison of memory requests vs actual usage

---

### Dashboard 4: Pod Resources

#### Panel 1: Pod CPU Usage
```promql
sum(rate(container_cpu_usage_seconds_total{namespace="$namespace",pod=~"$pod",container!="",container!="POD"}[5m])) by (pod, container)
```
**Shows:** CPU usage per container in selected pod
**Variables:** $namespace, $pod

---

#### Panel 2: Pod Memory Usage
```promql
sum(container_memory_usage_bytes{namespace="$namespace",pod=~"$pod",container!="",container!="POD"}) by (pod, container)
```
**Shows:** Memory usage per container in selected pod
**Variables:** $namespace, $pod

---

#### Panel 3: Pod CPU Throttling
```promql
sum(rate(container_cpu_cfs_throttled_seconds_total{namespace="$namespace",pod=~"$pod",container!="",container!="POD"}[5m])) by (pod, container)
```
**Shows:** CPU throttling per container
**Variables:** $namespace, $pod

---

#### Panel 4: Pod Memory Working Set
```promql
sum(container_memory_working_set_bytes{namespace="$namespace",pod=~"$pod",container!="",container!="POD"}) by (pod, container)
```
**Shows:** Memory working set per container
**Variables:** $namespace, $pod

---

#### Panel 5: All Pods CPU Usage in Namespace (Table)
```promql
sum(rate(container_cpu_usage_seconds_total{namespace="$namespace",container!="",container!="POD"}[5m])) by (namespace, pod, container)
```
**Shows:** CPU usage for all pods in namespace
**Variables:** $namespace

---

#### Panel 6: All Pods Memory Usage in Namespace (Table)
```promql
sum(container_memory_usage_bytes{namespace="$namespace",container!="",container!="POD"}) by (namespace, pod, container)
```
**Shows:** Memory usage for all pods in namespace
**Variables:** $namespace

---

#### Panel 7: Pod Resource Limits vs Usage (Table)
```promql
# CPU Limit
sum(kube_pod_container_resource_limits{namespace="$namespace",pod=~"$pod",resource="cpu"}) by (namespace, pod, container)

# CPU Usage
sum(rate(container_cpu_usage_seconds_total{namespace="$namespace",pod=~"$pod",container!="",container!="POD"}[5m])) by (namespace, pod, container)

# Memory Limit
sum(kube_pod_container_resource_limits{namespace="$namespace",pod=~"$pod",resource="memory"}) by (namespace, pod, container)

# Memory Usage
sum(container_memory_usage_bytes{namespace="$namespace",pod=~"$pod",container!="",container!="POD"}) by (namespace, pod, container)
```
**Shows:** Resource limits vs actual usage
**Variables:** $namespace, $pod

---

#### Panel 8: Network I/O by Pod
```promql
# Receive
sum(rate(container_network_receive_bytes_total{namespace="$namespace",pod=~"$pod"}[5m])) by (pod)

# Transmit
sum(rate(container_network_transmit_bytes_total{namespace="$namespace",pod=~"$pod"}[5m])) by (pod)
```
**Shows:** Network receive and transmit rates
**Variables:** $namespace, $pod

---

#### Panel 9: Filesystem Usage by Pod
```promql
sum(container_fs_usage_bytes{namespace="$namespace",pod=~"$pod",container!="",container!="POD"}) by (pod, container)
```
**Shows:** Filesystem usage per container
**Variables:** $namespace, $pod

---

### Dashboard 5: Namespace Resources

#### Panel 1: Namespace CPU Usage (Stat)
```promql
sum(rate(container_cpu_usage_seconds_total{namespace="$namespace",container!="",container!="POD"}[5m]))
```
**Shows:** Total CPU usage in namespace
**Variables:** $namespace

---

#### Panel 2: Namespace Memory Usage (Stat)
```promql
sum(container_memory_usage_bytes{namespace="$namespace",container!="",container!="POD"})
```
**Shows:** Total memory usage in namespace
**Variables:** $namespace

---

#### Panel 3: Pod Count (Stat)
```promql
count(kube_pod_info{namespace="$namespace"})
```
**Shows:** Number of pods in namespace
**Variables:** $namespace

---

#### Panel 4: Container Count (Stat)
```promql
count(kube_pod_container_info{namespace="$namespace"})
```
**Shows:** Number of containers in namespace
**Variables:** $namespace

---

#### Panel 5: CPU Usage Over Time
```promql
sum(rate(container_cpu_usage_seconds_total{namespace="$namespace",container!="",container!="POD"}[5m])) by (pod)
```
**Shows:** CPU usage trend per pod
**Variables:** $namespace

---

#### Panel 6: Memory Usage Over Time
```promql
sum(container_memory_usage_bytes{namespace="$namespace",container!="",container!="POD"}) by (pod)
```
**Shows:** Memory usage trend per pod
**Variables:** $namespace

---

#### Panel 7: CPU Requests vs Limits vs Usage
```promql
# Requests
sum(kube_pod_container_resource_requests{namespace="$namespace",resource="cpu"})

# Limits
sum(kube_pod_container_resource_limits{namespace="$namespace",resource="cpu"})

# Usage
sum(rate(container_cpu_usage_seconds_total{namespace="$namespace",container!="",container!="POD"}[5m]))
```
**Shows:** CPU requests, limits, and actual usage
**Variables:** $namespace

---

#### Panel 8: Memory Requests vs Limits vs Usage
```promql
# Requests
sum(kube_pod_container_resource_requests{namespace="$namespace",resource="memory"})

# Limits
sum(kube_pod_container_resource_limits{namespace="$namespace",resource="memory"})

# Usage
sum(container_memory_usage_bytes{namespace="$namespace",container!="",container!="POD"})
```
**Shows:** Memory requests, limits, and actual usage
**Variables:** $namespace

---

#### Panel 9: Top Pods by CPU
```promql
topk(10, sum(rate(container_cpu_usage_seconds_total{namespace="$namespace",container!="",container!="POD"}[5m])) by (pod))
```
**Shows:** Top 10 CPU-consuming pods in namespace
**Variables:** $namespace

---

#### Panel 10: Top Pods by Memory
```promql
topk(10, sum(container_memory_usage_bytes{namespace="$namespace",container!="",container!="POD"}) by (pod))
```
**Shows:** Top 10 memory-consuming pods in namespace
**Variables:** $namespace

---

#### Panel 11: Resource Quota Usage - CPU
```promql
(sum(rate(container_cpu_usage_seconds_total{namespace="$namespace",container!="",container!="POD"}[5m])) / sum(kube_resourcequota{namespace="$namespace",resource="cpu",type="hard"})) * 100
```
**Shows:** CPU quota usage percentage
**Variables:** $namespace

---

#### Panel 12: Resource Quota Usage - Memory
```promql
(sum(container_memory_usage_bytes{namespace="$namespace",container!="",container!="POD"}) / sum(kube_resourcequota{namespace="$namespace",resource="memory",type="hard"})) * 100
```
**Shows:** Memory quota usage percentage
**Variables:** $namespace

---

## 📂 Query Categories

### Node Metrics
- `node_cpu_seconds_total` - CPU time per mode
- `node_memory_MemAvailable_bytes` - Available memory
- `node_memory_MemTotal_bytes` - Total memory
- `node_filesystem_avail_bytes` - Available filesystem space
- `node_filesystem_size_bytes` - Total filesystem size
- `node_network_receive_bytes_total` - Network receive bytes
- `node_network_transmit_bytes_total` - Network transmit bytes
- `node_disk_read_bytes_total` - Disk read bytes
- `node_disk_written_bytes_total` - Disk write bytes

### Pod Metrics
- `kube_pod_info` - Pod information
- `kube_pod_status_phase` - Pod phase (Running, Pending, etc.)
- `kube_pod_container_status_restarts_total` - Container restart count
- `kube_pod_owner` - Pod owner information
- `kube_pod_container_info` - Container information

### Container Metrics
- `container_cpu_usage_seconds_total` - Container CPU usage
- `container_memory_usage_bytes` - Container memory usage
- `container_memory_working_set_bytes` - Container memory working set
- `container_cpu_cfs_throttled_seconds_total` - CPU throttling
- `container_network_receive_bytes_total` - Network receive
- `container_network_transmit_bytes_total` - Network transmit
- `container_fs_usage_bytes` - Filesystem usage
- `container_spec_memory_limit_bytes` - Memory limit
- `container_last_seen` - Last time container was seen

### Resource Metrics
- `kube_pod_container_resource_requests` - Resource requests
- `kube_pod_container_resource_limits` - Resource limits
- `kube_resourcequota` - Resource quota information

### Deployment Metrics
- `kube_deployment_spec_replicas` - Desired replicas
- `kube_deployment_status_replicas_available` - Available replicas

### Volume Metrics
- `kubelet_volume_stats_available_bytes` - Volume available space
- `kubelet_volume_stats_capacity_bytes` - Volume capacity

### API Server Metrics
- `apiserver_request_duration_seconds_bucket` - API request duration

### Prometheus Metrics
- `up` - Target up/down status
- `prometheus_config_last_reload_successful` - Config reload status
- `process_start_time_seconds` - Process start time

### Alert Metrics
- `ALERTS` - All alerts
- `ALERTS{alertstate="firing"}` - Firing alerts
- `ALERTS{alertstate="pending"}` - Pending alerts

---

## 🔧 Common Patterns

### 1. Rate Calculation
```promql
rate(metric_name[5m])
```
**Purpose:** Calculate per-second rate over 5 minutes

### 2. irate (Instant Rate)
```promql
irate(metric_name[5m])
```
**Purpose:** Calculate instant rate (more sensitive to spikes)

### 3. Aggregation by Label
```promql
sum(metric_name) by (label1, label2)
```
**Purpose:** Sum metric values grouped by labels

### 4. Top K
```promql
topk(10, metric_name)
```
**Purpose:** Get top 10 values

### 5. Percentage Calculation
```promql
(metric_a / metric_b) * 100
```
**Purpose:** Calculate percentage

### 6. Filtering
```promql
metric_name{label="value",label2!="value2"}
```
**Purpose:** Filter by label values

### 7. Histogram Quantile
```promql
histogram_quantile(0.99, sum(rate(metric_bucket[5m])) by (le))
```
**Purpose:** Calculate 99th percentile

### 8. Join Metrics
```promql
metric_a * on(label) group_left(label2) metric_b
```
**Purpose:** Join two metrics on common label

---

## ⚡ Query Optimization Tips

### 1. Use Recording Rules
For frequently used complex queries, create recording rules:
```yaml
- record: node:cpu_usage:percent
  expr: 100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

### 2. Limit Time Range
Use shorter time ranges for better performance:
```promql
rate(metric[5m])  # Good
rate(metric[1h])  # Slower
```

### 3. Use Specific Labels
Filter early to reduce data:
```promql
# Good
sum(rate(container_cpu_usage_seconds_total{namespace="production"}[5m]))

# Bad (filters after aggregation)
sum(rate(container_cpu_usage_seconds_total[5m])) by (namespace)
```

### 4. Avoid High Cardinality
Don't group by labels with many unique values:
```promql
# Bad (pod has many values)
sum(metric) by (pod)

# Better (namespace has fewer values)
sum(metric) by (namespace)
```

### 5. Use `without` Instead of `by`
When you want to keep most labels:
```promql
# Instead of listing many labels
sum(metric) by (label1, label2, label3, ...)

# Use without
sum(metric) without (unwanted_label)
```

---

## 📚 Additional Resources

- **PromQL Documentation:** https://prometheus.io/docs/prometheus/latest/querying/basics/
- **PromQL Examples:** https://prometheus.io/docs/prometheus/latest/querying/examples/
- **Grafana Query Editor:** https://grafana.com/docs/grafana/latest/datasources/prometheus/

---

## 📊 Query Summary

**Total Queries in Project:**
- **Prometheus Alerts:** 18 queries
- **Grafana Dashboards:** 70+ queries
- **Total:** 88+ unique PromQL queries

**Query Types:**
- Node monitoring: 15 queries
- Pod monitoring: 20 queries
- Container monitoring: 25 queries
- Resource monitoring: 15 queries
- Alert monitoring: 13 queries

---

**Complete reference of all Prometheus and Grafana queries used in this project!** 📊✅

