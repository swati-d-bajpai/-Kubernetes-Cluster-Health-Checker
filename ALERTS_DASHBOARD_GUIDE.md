# Prometheus Alerts Dashboard Guide

Complete guide for using the Prometheus Alerts Overview dashboard in Grafana.

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Dashboard Panels](#dashboard-panels)
3. [How to Access](#how-to-access)
4. [Use Cases](#use-cases)
5. [Understanding Alerts](#understanding-alerts)
6. [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

The **Prometheus Alerts Overview** dashboard provides complete visibility into all alerts in your Kubernetes cluster.

### Key Features

- ✅ **12 comprehensive panels** covering all aspects of alert monitoring
- ✅ **Real-time updates** every 30 seconds
- ✅ **Color-coded severity** (Critical, Warning, Info)
- ✅ **Sortable tables** with full alert details
- ✅ **Time series graphs** showing alert trends
- ✅ **Donut chart** for severity distribution
- ✅ **Top alerts** and namespace breakdown
- ✅ **Pending alerts** for early warning
- ✅ **Complete alert history**

### Dashboard Information

```
Name: Prometheus Alerts Overview
File: config/grafana-dashboard-alerts-overview.json
Size: 21K
Panels: 12
Auto-refresh: 30 seconds
Time range: Last 6 hours (configurable)
UID: prometheus-alerts-overview
```

---

## 📊 Dashboard Panels

### Row 1: Summary Statistics (4 Stat Panels)

#### 1. 🔴 Firing Alerts
- **Type:** Stat (Number)
- **Query:** `count(ALERTS{alertstate="firing"})`
- **Color:** Red background when > 0
- **Shows:** Total number of currently firing alerts

#### 2. 🔴 Critical Alerts
- **Type:** Stat (Number)
- **Query:** `count(ALERTS{alertstate="firing",severity="critical"})`
- **Color:** Red background when > 0
- **Shows:** Number of critical severity alerts

#### 3. 🟡 Warning Alerts
- **Type:** Stat (Number)
- **Query:** `count(ALERTS{alertstate="firing",severity="warning"})`
- **Color:** Yellow background when > 0
- **Shows:** Number of warning severity alerts

#### 4. ⏳ Pending Alerts
- **Type:** Stat (Number)
- **Query:** `count(ALERTS{alertstate="pending"})`
- **Color:** Green background
- **Shows:** Alerts that are pending (not yet firing)

---

### Row 2: Firing Alerts Table

#### 5. 🔥 Currently Firing Alerts
- **Type:** Table
- **Query:** `ALERTS{alertstate="firing"}`
- **Columns:**
  - Alert Name
  - Severity (color-coded: red=critical, yellow=warning)
  - State (color-coded: red=firing)
  - Namespace
  - Pod
  - Instance
- **Features:**
  - Sortable columns
  - Color-coded severity
  - Real-time updates
  - Shows all currently firing alerts

---

### Row 3: Alert Visualization

#### 6. 📊 Alerts by Severity (Time Series)
- **Type:** Time Series Graph
- **Query:** `count(ALERTS{alertstate="firing"}) by (severity)`
- **Shows:**
  - Alert trends over time
  - Separate lines for each severity
  - Last and max values in legend
- **Features:**
  - 6-hour time range
  - Auto-refresh every 30s
  - Hover tooltips

#### 7. 🥧 Alert Distribution by Severity
- **Type:** Donut Chart
- **Query:** `count(ALERTS{alertstate="firing"}) by (severity)`
- **Shows:**
  - Percentage breakdown by severity
  - Color-coded (red=critical, yellow=warning, blue=info)
  - Count and percentage in legend
- **Features:**
  - Visual distribution
  - Easy to spot severity imbalance

---

### Row 4: Pending Alerts

#### 8. ⏳ Pending Alerts
- **Type:** Table
- **Query:** `ALERTS{alertstate="pending"}`
- **Columns:**
  - Alert Name
  - Severity (color-coded)
  - State
  - Namespace
  - Pod
- **Shows:** Alerts that are pending (about to fire)

---

### Row 5: Alert Frequency

#### 9. 📈 Alert Frequency by Alert Name
- **Type:** Stacked Bar Chart (Time Series)
- **Query:** `count(ALERTS{alertstate="firing"}) by (alertname)`
- **Shows:**
  - How often each alert fires
  - Trends over time
  - Last, max, and mean values
- **Features:**
  - Stacked bars
  - Legend with statistics
  - Identify noisy alerts

---

### Row 6: Top Alerts & Namespace Breakdown

#### 10. 🔝 Top Firing Alerts
- **Type:** Table
- **Query:** `count(ALERTS{alertstate="firing"}) by (alertname)`
- **Columns:**
  - Alert Name
  - Count (sorted descending)
- **Shows:** Which alerts are firing most frequently

#### 11. 📦 Alerts by Namespace
- **Type:** Table
- **Query:** `count(ALERTS{alertstate="firing"}) by (namespace)`
- **Columns:**
  - Namespace
  - Count (sorted descending)
- **Shows:** Which namespaces have the most alerts

---

### Row 7: Complete Alert List

#### 12. 📋 All Alerts (Complete List)
- **Type:** Table
- **Query:** `ALERTS`
- **Columns:**
  - Alert Name
  - Severity (color-coded)
  - State (color-coded)
  - Namespace
  - Pod
  - Instance
  - Job
- **Shows:** Every alert (firing, pending, and inactive)
- **Features:**
  - Complete visibility
  - Color-coded backgrounds
  - Sortable columns

---

## 🚀 How to Access

### Step 1: Import the Dashboard

**Option A: Using Script (Recommended)**

```bash
# Run the monitoring configuration script
./scripts/configure-monitoring.sh
```

This will:
1. Import all 5 dashboards (including Alerts Overview)
2. Configure Prometheus alerts
3. Set up Grafana datasources
4. Restart services

**Option B: Manual Import**

```bash
# Create ConfigMap
kubectl create configmap grafana-dashboard-alerts-overview \
  --from-file=config/grafana-dashboard-alerts-overview.json \
  -n monitoring

# Label it for Grafana to discover
kubectl label configmap grafana-dashboard-alerts-overview \
  grafana_dashboard=1 \
  -n monitoring

# Restart Grafana
kubectl rollout restart deployment/kube-prometheus-stack-grafana -n monitoring
```

**Option C: Via Grafana UI**

1. Open Grafana: http://localhost:3000
2. Login: admin / prom-operator
3. Click "+" → "Import"
4. Upload: `config/grafana-dashboard-alerts-overview.json`
5. Click "Import"

---

### Step 2: Start Port Forwarding

```bash
./scripts/start-port-forwards.sh
```

---

### Step 3: Open Grafana

```
URL: http://localhost:3000
Username: admin
Password: prom-operator
```

---

### Step 4: Find the Dashboard

**Method 1: Search**
- Click "Search" (magnifying glass icon)
- Type "Prometheus Alerts Overview"
- Click the dashboard

**Method 2: Browse**
- Click "Dashboards" → "Browse"
- Look for "Prometheus Alerts Overview"
- Click to open

**Method 3: Direct URL**
- http://localhost:3000/d/prometheus-alerts-overview

---

## 💡 Use Cases

### 1. 🚨 Incident Response

**Scenario:** Production incident, need to quickly assess the situation

**How to use:**
1. Open the dashboard
2. Check the **Firing Alerts** stat panel (top left)
3. Review the **Currently Firing Alerts** table
4. Sort by severity to prioritize
5. Identify affected namespaces/pods
6. Click on alert names for more details

**What you'll see:**
- Total number of firing alerts
- Critical vs warning breakdown
- Affected resources
- Alert details

---

### 2. 📊 Alert Analysis

**Scenario:** Too many alerts, need to identify noisy alerts

**How to use:**
1. Check the **Alert Frequency by Alert Name** panel
2. Review the **Top Firing Alerts** table
3. Identify alerts that fire frequently
4. Adjust alert thresholds or rules

**What you'll see:**
- Which alerts fire most often
- Alert trends over time
- Frequency statistics

---

### 3. 🔍 Troubleshooting

**Scenario:** Investigating a cluster issue

**How to use:**
1. Check **Pending Alerts** to see early warnings
2. Review **Alerts by Namespace** to find affected areas
3. Correlate alerts across namespaces
4. Use time series to see when issues started

**What you'll see:**
- Pending alerts (about to fire)
- Alert correlation
- Timeline of issues
- Affected namespaces

---

### 4. 📈 Monitoring Health

**Scenario:** Regular monitoring and health checks

**How to use:**
1. Check the **Alert Distribution by Severity** donut chart
2. Review the **Alerts by Severity** time series
3. Monitor alert volume over time
4. Ensure alerts are working correctly

**What you'll see:**
- Alert volume trends
- Severity distribution
- Alert health metrics

---

### 5. 📋 Reporting

**Scenario:** Need to report on alerts for management

**How to use:**
1. Use the **All Alerts** table for complete list
2. Export to CSV
3. Share dashboard link
4. Take screenshots

**What you'll see:**
- Complete alert history
- Exportable data
- Shareable reports

---

## 🎨 Understanding Alerts

### Alert States

| State | Color | Meaning |
|-------|-------|---------|
| **firing** | 🔴 Red | Alert is currently active |
| **pending** | 🟠 Orange | Alert condition met, waiting for duration |
| **inactive** | 🟢 Green | Alert condition not met |

### Alert Severity

| Severity | Color | Meaning | Example |
|----------|-------|---------|---------|
| **critical** | 🔴 Red | Immediate action required | NodeDown, PodCrashLooping |
| **warning** | 🟡 Yellow | Attention needed | NodeHighCPU, PodHighMemory |
| **info** | 🔵 Blue | Informational | ConfigMapUpdated |

---

## 🔔 Common Alerts

### Critical Alerts (🔴)

- **NodeDown** - Node is down
- **PodCrashLooping** - Pod is crash looping
- **DeploymentReplicasMismatch** - Deployment replicas mismatch
- **PersistentVolumeClaimPending** - PVC stuck pending
- **KubernetesMemoryPressure** - Node memory pressure
- **KubernetesDiskPressure** - Node disk pressure

### Warning Alerts (🟡)

- **NodeHighCPU** - Node CPU > 80%
- **NodeHighMemory** - Node memory > 80%
- **PodHighCPU** - Pod CPU > 80%
- **PodHighMemory** - Pod memory > 80%
- **PodNotReady** - Pod not ready
- **ContainerRestarting** - Container restarting frequently

---

## 🔧 Troubleshooting

### Issue: No alerts showing

**Possible causes:**
1. Prometheus not scraping metrics
2. Alert rules not loaded
3. No alerts are firing

**Solutions:**
```bash
# Check Prometheus targets
curl http://localhost:9090/api/v1/targets

# Check alert rules
curl http://localhost:9090/api/v1/rules

# Verify Prometheus is running
kubectl get pods -n monitoring | grep prometheus
```

---

### Issue: Dashboard not loading

**Possible causes:**
1. Dashboard not imported
2. Grafana not running
3. Datasource not configured

**Solutions:**
```bash
# Re-import dashboard
./scripts/configure-monitoring.sh

# Check Grafana is running
kubectl get pods -n monitoring | grep grafana

# Restart Grafana
kubectl rollout restart deployment/kube-prometheus-stack-grafana -n monitoring
```

---

### Issue: Alerts not color-coded

**Possible causes:**
1. Severity label missing
2. Dashboard configuration issue

**Solutions:**
- Check alert rules have `severity` label
- Re-import dashboard
- Clear browser cache

---

## 📚 Additional Resources

- **Prometheus Alerts Documentation:** https://prometheus.io/docs/alerting/latest/
- **Grafana Dashboard Documentation:** https://grafana.com/docs/grafana/latest/dashboards/
- **PromQL Documentation:** https://prometheus.io/docs/prometheus/latest/querying/basics/

---

## 🎯 Quick Reference

### Dashboard Access
```
URL: http://localhost:3000/d/prometheus-alerts-overview
Username: admin
Password: prom-operator
```

### Import Dashboard
```bash
./scripts/configure-monitoring.sh
```

### View Alerts in Prometheus
```
URL: http://localhost:9090/alerts
```

### View AlertManager
```
URL: http://localhost:9093
```

---

**You now have complete visibility into all Prometheus alerts!** 🎯✅

