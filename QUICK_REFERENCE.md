# Quick Reference Guide

Essential commands and shortcuts for Sprint 1.

---

## 🚀 Quick Start

```bash
# One-command setup
./scripts/setup-minikube.sh

# Verify setup
./scripts/verify-setup.sh

# Run health check
python3 scripts/check-health.py
```

---

## 📦 Minikube Commands

```bash
# Start cluster
minikube start

# Stop cluster (preserves state)
minikube stop

# Delete cluster
minikube delete

# Check status
minikube status

# SSH into node
minikube ssh

# Open dashboard
minikube dashboard

# List addons
minikube addons list

# Enable addon
minikube addons enable <addon-name>
```

---

## ☸️ kubectl Commands

### Cluster Info
```bash
# Cluster information
kubectl cluster-info

# Get nodes
kubectl get nodes

# Get all resources
kubectl get all -A
```

### Pods
```bash
# Get all pods
kubectl get pods -A

# Get pods in namespace
kubectl get pods -n monitoring

# Describe pod
kubectl describe pod <pod-name> -n <namespace>

# View logs
kubectl logs <pod-name> -n <namespace>

# Follow logs
kubectl logs -f <pod-name> -n <namespace>

# Execute command in pod
kubectl exec -it <pod-name> -n <namespace> -- /bin/sh
```

### Services
```bash
# Get all services
kubectl get svc -A

# Get services in namespace
kubectl get svc -n monitoring

# Port forward to service
kubectl port-forward -n <namespace> svc/<service-name> <local-port>:<service-port>
```

### Namespaces
```bash
# Get namespaces
kubectl get namespaces

# Create namespace
kubectl create namespace <name>

# Delete namespace
kubectl delete namespace <name>
```

### Resources
```bash
# Node resources
kubectl top nodes

# Pod resources
kubectl top pods -A

# Pod resources in namespace
kubectl top pods -n monitoring
```

### Events
```bash
# Get recent events
kubectl get events -A --sort-by='.lastTimestamp'

# Watch events
kubectl get events -A --watch
```

---

## 🎛️ Helm Commands

```bash
# List repositories
helm repo list

# Add repository
helm repo add <name> <url>

# Update repositories
helm repo update

# Search charts
helm search repo <keyword>

# Install chart
helm install <release-name> <chart> -n <namespace>

# List releases
helm list -A

# Uninstall release
helm uninstall <release-name> -n <namespace>

# Get values
helm get values <release-name> -n <namespace>

# Upgrade release
helm upgrade <release-name> <chart> -n <namespace>
```

---

## 🐍 Python Scripts

```bash
# Activate virtual environment
source venv/bin/activate

# Deactivate virtual environment
deactivate

# Install dependencies
pip install -r requirements.txt

# Run cluster info script
python3 src/cluster_info.py

# Run health monitor
python3 src/health_monitor.py

# Run service info
python3 src/service_info.py

# Run health check
python3 scripts/check-health.py
```

---

## 📊 Access UIs

### Prometheus
```bash
# Port forward
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090

# Open in browser
open http://localhost:9090
```

### Grafana
```bash
# Port forward
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80

# Open in browser
open http://localhost:3000

# Credentials
# Username: admin
# Password: admin123
```

### Kubernetes Dashboard
```bash
# Open dashboard
minikube dashboard
```

---

## 🔍 Useful Prometheus Queries

```promql
# Check all targets are up
up

# Node information
kube_node_info

# Pod information
kube_pod_info

# CPU usage
node_cpu_seconds_total

# Memory usage
node_memory_MemTotal_bytes

# Pod count by namespace
count(kube_pod_info) by (namespace)

# Container restarts
kube_pod_container_status_restarts_total
```

---

## 🛠️ Troubleshooting

```bash
# Check pod status
kubectl get pods -A

# Describe pod (detailed info)
kubectl describe pod <pod-name> -n <namespace>

# View logs
kubectl logs <pod-name> -n <namespace>

# View previous logs (if crashed)
kubectl logs <pod-name> -n <namespace> --previous

# Check events
kubectl get events -A --sort-by='.lastTimestamp' | tail -20

# Check resources
kubectl top nodes
kubectl top pods -A

# Restart pod
kubectl delete pod <pod-name> -n <namespace>

# Restart Minikube
minikube stop
minikube start

# Complete reset
minikube delete
./scripts/setup-minikube.sh
```

---

## 📁 Project Structure

```
.
├── README.md                  # Main documentation
├── SPRINT_1_GUIDE.md         # Step-by-step setup guide
├── EXAMPLES.md               # Code examples with outputs
├── TROUBLESHOOTING.md        # Common issues and solutions
├── QUICK_REFERENCE.md        # This file
├── requirements.txt          # Python dependencies
├── scripts/
│   ├── setup-minikube.sh    # Automated setup
│   ├── verify-setup.sh      # Verification script
│   └── check-health.py      # Health check script
└── src/
    ├── cluster_info.py      # Cluster information
    ├── health_monitor.py    # Pod health monitoring
    └── service_info.py      # Service information
```

---

## 🎯 Common Workflows

### Daily Startup
```bash
# Start Minikube
minikube start

# Activate Python environment
source venv/bin/activate

# Check cluster health
python3 scripts/check-health.py
```

### Daily Shutdown
```bash
# Stop Minikube (preserves state)
minikube stop

# Deactivate Python environment
deactivate
```

### Check Cluster Status
```bash
# Quick status check
minikube status
kubectl get nodes
kubectl get pods -A

# Detailed health check
python3 scripts/check-health.py
./scripts/verify-setup.sh
```

### View Metrics
```bash
# Port forward to Prometheus (run in separate terminal)
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090

# Port forward to Grafana (run in another terminal)
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80

# Open browsers
open http://localhost:9090
open http://localhost:3000
```

---

## 💡 Tips

1. **Use aliases** for common commands:
   ```bash
   alias k='kubectl'
   alias kgp='kubectl get pods -A'
   alias kgs='kubectl get svc -A'
   alias kgn='kubectl get nodes'
   ```

2. **Enable kubectl autocompletion**:
   ```bash
   source <(kubectl completion bash)  # For bash
   source <(kubectl completion zsh)   # For zsh
   ```

3. **Watch resources in real-time**:
   ```bash
   watch kubectl get pods -A
   ```

4. **Use stern for better log viewing** (optional):
   ```bash
   brew install stern
   stern -n monitoring prometheus
   ```

---

## 📚 Next Steps

- Explore Prometheus queries
- Create custom Grafana dashboards
- Modify Python scripts for custom monitoring
- Learn about Kubernetes resources (Deployments, StatefulSets, etc.)

---

**Need more help?** Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

