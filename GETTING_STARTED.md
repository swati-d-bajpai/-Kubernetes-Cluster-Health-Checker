# Getting Started - Sprint 1

**Welcome!** This guide will get you up and running in 15 minutes.

---

## 🎯 What You'll Build

A local Kubernetes cluster with:
- ✅ Minikube (local Kubernetes)
- ✅ Prometheus (metrics collection)
- ✅ Grafana (visualization)
- ✅ Python scripts (health monitoring)

---

## ⚡ Super Quick Start (5 Commands)

```bash
# 1. Run automated setup
./scripts/setup-minikube.sh

# 2. Verify everything works
./scripts/verify-setup.sh

# 3. Activate Python environment
source venv/bin/activate

# 4. Check cluster health
python3 scripts/check-health.py

# 5. View cluster info
python3 src/cluster_info.py
```

**Done!** Your cluster is ready. 🎉

---

## 📋 Prerequisites

Before starting, install these tools:

### macOS
```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install all prerequisites
brew install --cask docker
brew install minikube kubectl helm python@3.11

# Start Docker Desktop
open -a Docker
```

### Linux
```bash
# Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Python
sudo apt-get update
sudo apt-get install python3.11 python3.11-venv
```

### Verify Installation
```bash
docker --version          # Should show: Docker version 24.0.0+
minikube version         # Should show: minikube version: v1.32.0+
kubectl version --client # Should show: Client Version information
helm version             # Should show: version.BuildInfo{Version:"v3.13.0"+}
python3 --version        # Should show: Python 3.11.0+
```

---

## 🚀 Step-by-Step Setup

### Step 1: Clone or Navigate to Project
```bash
cd -Kubernetes-Cluster-Health-Checker
```

### Step 2: Make Scripts Executable
```bash
chmod +x scripts/*.sh src/*.py scripts/*.py
```

### Step 3: Run Automated Setup
```bash
./scripts/setup-minikube.sh
```

**What happens:**
- Checks prerequisites ✓
- Starts Minikube cluster ✓
- Enables addons ✓
- Creates Python environment ✓
- Installs Prometheus ✓
- Verifies everything ✓

**Time**: 10-15 minutes

**Output**: You'll see colored progress messages. Green ✅ means success!

### Step 4: Verify Setup
```bash
./scripts/verify-setup.sh
```

**Expected Output:**
```
============================================================
SPRINT 1 VERIFICATION
============================================================

🔍 Testing: Minikube cluster status
✅ PASS: Minikube is running

🔍 Testing: Kubectl connection to cluster
✅ PASS: kubectl can connect to cluster

🔍 Testing: Node readiness
✅ PASS: All nodes are ready

... (more tests) ...

============================================================
VERIFICATION SUMMARY
============================================================

Total Tests: 10
Passed: 10
Failed: 0
Success Rate: 100%

============================================================
✅ ALL TESTS PASSED - SETUP IS COMPLETE!
============================================================
```

---

## 🎓 Try the Examples

### Activate Python Environment
```bash
source venv/bin/activate
```

You should see `(venv)` in your prompt.

### Example 1: Cluster Information
```bash
python3 src/cluster_info.py
```

**Shows:**
- Kubernetes version
- Node details (CPU, memory)
- All namespaces

### Example 2: Health Monitoring
```bash
python3 src/health_monitor.py
```

**Shows:**
- Total pod count
- Pod status summary
- Detailed pod information

### Example 3: Service Information
```bash
python3 src/service_info.py
```

**Shows:**
- Services in monitoring namespace
- Service types and IPs
- Port mappings

### Example 4: Quick Health Check
```bash
python3 scripts/check-health.py
```

**Shows:**
- Node readiness
- Critical pod status
- Overall cluster health

---

## 🌐 Access the UIs

### Prometheus (Metrics)

**Terminal 1:**
```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
```

**Browser:**
```
http://localhost:9090
```

**Try these queries:**
- `up` - Shows all targets
- `kube_node_info` - Node information
- `kube_pod_info` - Pod information

### Grafana (Dashboards)

**Terminal 2:**
```bash
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```

**Browser:**
```
http://localhost:3000
```

**Login:**
- Username: `admin`
- Password: `admin123`

**Explore:**
- Pre-installed Kubernetes dashboards
- Node metrics
- Pod metrics

---

## 🎯 What to Do Next

### 1. Explore kubectl Commands
```bash
# Get all pods
kubectl get pods -A

# Get nodes
kubectl get nodes

# Get services
kubectl get svc -A

# Describe a pod
kubectl describe pod <pod-name> -n monitoring
```

### 2. Modify Python Scripts
- Open `src/cluster_info.py`
- Try adding more information
- Run it to see your changes

### 3. Learn Prometheus Queries
- Open Prometheus UI
- Try different queries
- Explore the metrics

### 4. Create Grafana Dashboards
- Open Grafana
- Create a new dashboard
- Add panels with metrics

---

## 🛑 Stopping and Starting

### Stop for the Day
```bash
# Stop Minikube (preserves everything)
minikube stop

# Deactivate Python environment
deactivate
```

### Start Again Tomorrow
```bash
# Start Minikube
minikube start

# Activate Python environment
source venv/bin/activate

# Check health
python3 scripts/check-health.py
```

---

## 🆘 Something Wrong?

### Quick Fixes

**Minikube won't start:**
```bash
# Make sure Docker is running
open -a Docker  # macOS

# Try again
minikube start
```

**Pods not running:**
```bash
# Check pod status
kubectl get pods -A

# Check specific pod
kubectl describe pod <pod-name> -n monitoring

# View logs
kubectl logs <pod-name> -n monitoring
```

**Python errors:**
```bash
# Make sure venv is activated
source venv/bin/activate

# Reinstall dependencies
pip install -r requirements.txt
```

### Complete Reset
```bash
# Delete everything and start fresh
minikube delete
rm -rf venv
./scripts/setup-minikube.sh
```

### Get More Help
- Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- Run `./scripts/verify-setup.sh` to identify issues

---

## 📚 Learning Resources

### Documentation
- [SPRINT_1_GUIDE.md](SPRINT_1_GUIDE.md) - Detailed guide
- [EXAMPLES.md](EXAMPLES.md) - Code examples
- [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - Command reference
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Problem solving

### External Resources
- [Kubernetes Basics](https://kubernetes.io/docs/tutorials/kubernetes-basics/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [Prometheus Documentation](https://prometheus.io/docs/introduction/overview/)
- [Python Kubernetes Client](https://github.com/kubernetes-client/python)

---

## ✅ Success Checklist

You're ready to move forward when:

- [ ] Minikube is running (`minikube status`)
- [ ] All nodes are ready (`kubectl get nodes`)
- [ ] All pods are running (`kubectl get pods -A`)
- [ ] Verification passes (`./scripts/verify-setup.sh`)
- [ ] Health check passes (`python3 scripts/check-health.py`)
- [ ] You can access Prometheus UI
- [ ] You can access Grafana UI
- [ ] You understand the basic Python scripts

---

## 🎉 Congratulations!

You've successfully set up your Kubernetes cluster health monitoring system!

**What you've accomplished:**
- ✅ Set up a local Kubernetes cluster
- ✅ Installed Prometheus for monitoring
- ✅ Created Python scripts for health checks
- ✅ Learned basic kubectl commands
- ✅ Explored Prometheus and Grafana

**Next Steps:**
- Experiment with the Python scripts
- Explore Prometheus queries
- Create custom Grafana dashboards
- Learn more about Kubernetes

---

**Questions?** Check the documentation or run `./scripts/verify-setup.sh` to diagnose issues.

**Happy monitoring!** 🚀

