# 🚀 Quick Access Guide - Kubernetes Services on Localhost

**Problem:** `http://localhost` doesn't work because services run inside Kubernetes cluster.

**Solution:** Use port forwarding to access services on localhost.

---

## ⚡ Quick Start (Easiest Way)

### 1. Start All Port Forwards

```bash
./scripts/start-port-forwards.sh
```

**This will:**
- ✅ Start port forwards for Prometheus, Grafana, and AlertManager
- ✅ Run in the background
- ✅ Show you all access URLs and credentials
- ✅ Keep running until you stop it

---

### 2. Access Services

Open in your browser:

| Service | URL | Credentials |
|---------|-----|-------------|
| **Prometheus** | http://localhost:9090 | No login required |
| **Grafana** | http://localhost:3000 | Username: `admin`<br>Password: `prom-operator` |
| **AlertManager** | http://localhost:9093 | No login required |

---

### 3. Stop Port Forwards

When you're done:

```bash
./scripts/stop-port-forwards.sh
```

Or press `Ctrl+C` in the terminal running the port forwards.

---

## 📖 Manual Method (Alternative)

If you prefer to run port forwards manually in separate terminals:

### Terminal 1: Prometheus

```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
```

Then open: http://localhost:9090

---

### Terminal 2: Grafana

```bash
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```

Then open: http://localhost:3000

Login: `admin` / `prom-operator`

---

### Terminal 3: AlertManager

```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-alertmanager 9093:9093
```

Then open: http://localhost:9093

---

## 🔍 What to Do in Each Service

### Prometheus (http://localhost:9090)

1. **Run a query:**
   - Click "Graph" tab
   - Enter query: `up`
   - Click "Execute"
   - You'll see all services and their status

2. **View targets:**
   - Click "Status" → "Targets"
   - All targets should show "UP" (green)

3. **Try more queries:**
   - `node_cpu_seconds_total` - CPU metrics
   - `node_memory_MemAvailable_bytes` - Memory metrics
   - `kube_pod_status_phase` - Pod status

---

### Grafana (http://localhost:3000)

1. **Login:**
   - Username: `admin`
   - Password: `prom-operator`

2. **View dashboards:**
   - Click "Dashboards" (left menu)
   - Click "Browse"
   - You'll see pre-configured Kubernetes dashboards

3. **Recommended dashboards:**
   - "Kubernetes / Compute Resources / Cluster"
   - "Kubernetes / Compute Resources / Namespace (Pods)"
   - "Node Exporter / Nodes"

4. **Create alerts:**
   - Click "Alerting" (left menu)
   - Click "Alert rules"

---

### AlertManager (http://localhost:9093)

1. **View alerts:**
   - Should be empty if cluster is healthy
   - Alerts appear here when something is wrong

2. **Create silences:**
   - Click "Silences"
   - Click "New Silence"
   - Useful for maintenance windows

---

## 🛠️ Troubleshooting

### Problem: "Connection Refused"

**Solution:**
```bash
# Check if pods are running
kubectl get pods -n monitoring

# All should show "Running"
# If not, wait a few minutes
```

---

### Problem: "Address Already in Use"

**Solution:**
```bash
# Stop existing port forwards
./scripts/stop-port-forwards.sh

# Or kill specific port
lsof -i :9090
kill -9 <PID>

# Then start again
./scripts/start-port-forwards.sh
```

---

### Problem: Port Forward Stops Working

**Solution:**
```bash
# Restart port forwards
./scripts/stop-port-forwards.sh
./scripts/start-port-forwards.sh
```

---

### Problem: Can't Get Grafana Password

**Solution:**
```bash
# Get password manually
kubectl get secret -n monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

# Default password is usually: prom-operator
```

---

## 📊 All Available Services

You can also access these additional services:

```bash
# Node Exporter (node metrics)
kubectl port-forward -n monitoring svc/prometheus-prometheus-node-exporter 9100:9100
# Access: http://localhost:9100/metrics

# Kube State Metrics (Kubernetes metrics)
kubectl port-forward -n monitoring svc/prometheus-kube-state-metrics 8080:8080
# Access: http://localhost:8080/metrics
```

---

## 💡 Pro Tips

### Keep Port Forwards Running

**Option 1: Use tmux**
```bash
# Install tmux
brew install tmux

# Start tmux session
tmux new -s k8s

# Run port forwards
./scripts/start-port-forwards.sh

# Detach: Ctrl+B then D
# Reattach later: tmux attach -t k8s
```

**Option 2: Run in background**
```bash
# The start-port-forwards.sh script already runs in background
./scripts/start-port-forwards.sh

# It will keep running until you stop it
```

---

### Check What's Running

```bash
# See all port forwards
ps aux | grep "kubectl port-forward"

# See which ports are in use
lsof -i :9090
lsof -i :3000
lsof -i :9093
```

---

### Access from Other Devices (Advanced)

```bash
# Forward to all interfaces (not just localhost)
kubectl port-forward -n monitoring --address 0.0.0.0 svc/prometheus-grafana 3000:80

# Then access from another device:
# http://YOUR_COMPUTER_IP:3000
```

**⚠️ Warning:** Only do this on trusted networks!

---

## 📝 Summary

**To access Kubernetes services on localhost:**

1. ✅ Run: `./scripts/start-port-forwards.sh`
2. ✅ Open browser to http://localhost:9090 (Prometheus)
3. ✅ Open browser to http://localhost:3000 (Grafana)
4. ✅ Login to Grafana: admin / prom-operator
5. ✅ When done: `./scripts/stop-port-forwards.sh`

**Why this is needed:**
- Kubernetes services run inside the cluster
- They have internal IPs (10.96.x.x)
- Port forwarding creates a tunnel to localhost
- This is the standard way to access Kubernetes services locally

---

## 🎉 You're Ready!

Now you can access all your Kubernetes services on localhost! 🚀

**Quick commands:**
```bash
# Start everything
./scripts/start-port-forwards.sh

# Stop everything
./scripts/stop-port-forwards.sh

# Check status
kubectl get pods -n monitoring
```

**Access URLs:**
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000
- AlertManager: http://localhost:9093

Happy monitoring! 📊

