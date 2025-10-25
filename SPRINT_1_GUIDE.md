# Sprint 1 Guide - Kubernetes Cluster Health Checker

Complete guide for Sprint 1 implementation: Setting up Minikube, configuring Kubernetes API access, and installing Prometheus monitoring.

---

## 📋 Table of Contents

1. [Sprint 1 Objectives](#sprint-1-objectives)
2. [Prerequisites](#prerequisites)
3. [Project Structure](#project-structure)
4. [Step-by-Step Setup](#step-by-step-setup)
5. [Verification](#verification)
6. [Expected Outputs](#expected-outputs)
7. [Troubleshooting](#troubleshooting)

---

## 🎯 Sprint 1 Objectives

### Primary Goals

1. **Define Project Structure** - Organize code, scripts, and documentation
2. **Set Up Minikube** - Create local Kubernetes cluster for development
3. **Configure API Access** - Set up kubectl and Python Kubernetes client
4. **Install Prometheus** - Deploy monitoring stack with Grafana and AlertManager

### Deliverables

- ✅ Working Minikube cluster
- ✅ Python scripts for cluster interaction
- ✅ Prometheus monitoring stack
- ✅ Grafana dashboards
- ✅ Complete documentation

---

## 📦 Prerequisites

### Required Software

1. **Docker Desktop**
   - Version: Latest stable
   - Memory: At least 8GB allocated (6GB minimum)
   - Download: https://www.docker.com/products/docker-desktop

2. **Minikube**
   - Version: 1.30.0 or later
   - Install:
     ```bash
     # macOS
     brew install minikube
     
     # Linux
     curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
     sudo install minikube-linux-amd64 /usr/local/bin/minikube
     ```

3. **kubectl**
   - Version: 1.27.0 or later
   - Install:
     ```bash
     # macOS
     brew install kubectl
     
     # Linux
     curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
     sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
     ```

4. **Helm**
   - Version: 3.0 or later
   - Install:
     ```bash
     # macOS
     brew install helm
     
     # Linux
     curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
     ```

5. **Python**
   - Version: 3.8 or later
   - Install:
     ```bash
     # macOS
     brew install python3
     
     # Linux
     sudo apt-get update
     sudo apt-get install python3 python3-pip python3-venv
     ```

### Verify Prerequisites

```bash
# Check Docker
docker --version

# Check Minikube
minikube version

# Check kubectl
kubectl version --client

# Check Helm
helm version

# Check Python
python3 --version
```

---

## 📁 Project Structure

```
Kubernetes-Cluster-Health-Checker/
│
├── README.md                          # Project overview
├── GETTING_STARTED.md                 # Quick start guide
├── SPRINT_1_GUIDE.md                  # This file
├── TESTING_GUIDE.md                   # Testing instructions
├── TROUBLESHOOTING.md                 # Common issues
├── QUICK_REFERENCE.md                 # Command reference
├── MONITORING_GUIDE.md                # Monitoring setup
├── ACCESS_SERVICES.md                 # Service access guide
│
├── src/                               # Python source code
│   ├── cluster_info.py                # Get cluster information
│   ├── health_monitor.py              # Monitor cluster health
│   └── service_info.py                # Get service information
│
├── scripts/                           # Automation scripts
│   ├── setup-minikube.sh              # Setup Minikube cluster
│   ├── verify-setup.sh                # Verify installation
│   ├── check-health.py                # Health check script
│   ├── start-port-forwards.sh         # Start port forwards
│   ├── stop-port-forwards.sh          # Stop port forwards
│   ├── configure-monitoring.sh        # Configure monitoring
│   ├── test-alerts.py                 # Test Prometheus alerts
│   └── show-resource-usage.py         # Show resource usage
│
├── config/                            # Configuration files
│   ├── prometheus-alerts.yaml         # Prometheus alert rules
│   ├── grafana-dashboard-cluster-overview.json
│   ├── grafana-dashboard-resource-monitoring.json
│   ├── grafana-dashboard-pod-resources.json
│   └── grafana-dashboard-namespace-resources.json
│
├── requirements.txt                   # Python dependencies
├── .gitignore                         # Git ignore rules
└── venv/                              # Python virtual environment
```

---

## 🚀 Step-by-Step Setup

### Step 1: Clone or Create Project Directory

```bash
# Create project directory
mkdir -p Kubernetes-Cluster-Health-Checker
cd Kubernetes-Cluster-Health-Checker

# Create subdirectories
mkdir -p src scripts config
```

### Step 2: Set Up Python Virtual Environment

```bash
# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Install Python dependencies
pip install kubernetes>=28.1.0
```

### Step 3: Configure Minikube Settings

The setup script will configure Minikube with:
- **CPUs**: 4
- **Memory**: 6GB (6144MB)
- **Disk**: 20GB
- **Driver**: Docker

### Step 4: Run Setup Script

```bash
# Make script executable
chmod +x scripts/setup-minikube.sh

# Run setup
./scripts/setup-minikube.sh
```

**What the script does:**

1. **Checks Prerequisites**
   - Verifies Docker, Minikube, kubectl, Helm are installed
   - Checks Docker is running

2. **Starts Minikube**
   - Creates cluster with specified resources
   - Enables metrics-server addon
   - Waits for cluster to be ready

3. **Installs Prometheus Stack**
   - Adds Prometheus Helm repository
   - Installs kube-prometheus-stack
   - Includes Prometheus, Grafana, AlertManager
   - Includes Node Exporter, Kube State Metrics

4. **Verifies Installation**
   - Checks all pods are running
   - Displays service information
   - Shows access instructions

### Step 5: Verify Setup

```bash
# Run verification script
./scripts/verify-setup.sh
```

**Verification checks:**

1. ✅ Minikube is running
2. ✅ Kubernetes cluster is accessible
3. ✅ Monitoring namespace exists
4. ✅ Prometheus pods are running
5. ✅ Grafana is running
6. ✅ AlertManager is running
7. ✅ Node Exporter is running
8. ✅ Kube State Metrics is running
9. ✅ Metrics Server is running
10. ✅ All services are ready

### Step 6: Configure Monitoring

```bash
# Configure Prometheus alerts and Grafana dashboards
./scripts/configure-monitoring.sh
```

**What this does:**

1. Applies Prometheus alert rules
2. Imports 4 custom Grafana dashboards
3. Restarts Prometheus and Grafana
4. Displays access information

### Step 7: Access Services

```bash
# Start port forwards
./scripts/start-port-forwards.sh
```

**Access URLs:**

- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000 (admin/prom-operator)
- **AlertManager**: http://localhost:9093

### Step 8: Test Python Scripts

```bash
# Activate virtual environment
source venv/bin/activate

# Test cluster info script
python3 src/cluster_info.py

# Test health monitor script
python3 src/health_monitor.py

# Test service info script
python3 src/service_info.py

# Test health check script
python3 scripts/check-health.py

# Test alerts
python3 scripts/test-alerts.py

# Show resource usage
python3 scripts/show-resource-usage.py
```

---

## ✅ Verification

### Verify Minikube

```bash
# Check Minikube status
minikube status

# Expected output:
# minikube
# type: Control Plane
# host: Running
# kubelet: Running
# apiserver: Running
# kubeconfig: Configured
```

### Verify Kubernetes

```bash
# Check cluster info
kubectl cluster-info

# Check nodes
kubectl get nodes

# Expected output:
# NAME       STATUS   ROLES           AGE   VERSION
# minikube   Ready    control-plane   5m    v1.27.x
```

### Verify Prometheus Stack

```bash
# Check monitoring namespace
kubectl get namespace monitoring

# Check all pods
kubectl get pods -n monitoring

# Expected: All pods in Running state
```

### Verify Services

```bash
# Check services
kubectl get svc -n monitoring

# Expected services:
# - prometheus-kube-prometheus-prometheus
# - prometheus-grafana
# - prometheus-kube-prometheus-alertmanager
# - prometheus-kube-state-metrics
# - prometheus-prometheus-node-exporter
```

---

## 📊 Expected Outputs

### Setup Script Output

```
╔══════════════════════════════════════════════════════════════════════════╗
║                                                                          ║
║              KUBERNETES CLUSTER HEALTH CHECKER - SETUP                   ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════════╝

ℹ️  Checking prerequisites...
✅ Docker is installed
✅ Docker is running
✅ Minikube is installed
✅ kubectl is installed
✅ Helm is installed
✅ Prerequisites check passed

ℹ️  Starting Minikube with 4 CPUs, 6144MB RAM, 20g disk...
✅ Minikube started successfully

ℹ️  Enabling metrics-server addon...
✅ Metrics server enabled

ℹ️  Installing Prometheus using Helm...
✅ Prometheus installed successfully

ℹ️  Waiting for all pods to be ready...
✅ All pods are running

🎉 Setup Complete!
```

### Python Script Outputs

**cluster_info.py:**
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
  Age: 10m
  Version: v1.27.4
```

**health_monitor.py:**
```
╔══════════════════════════════════════════════════════════════════════════╗
║                    KUBERNETES CLUSTER HEALTH MONITOR                     ║
╚══════════════════════════════════════════════════════════════════════════╝

Pod Status Summary:
  Running: 25
  Pending: 0
  Failed: 0
  Succeeded: 0

✅ Cluster is healthy!
```

---

## 🔧 Troubleshooting

### Issue: Minikube won't start

**Error:** `Exiting due to MK_USAGE: Docker Desktop has only 7837MB memory`

**Solution:**
```bash
# Option 1: Increase Docker Desktop memory
# Docker Desktop → Settings → Resources → Memory → 10GB

# Option 2: Use less memory (already configured)
# The setup script uses 6GB which should work
```

### Issue: Port forward not working

**Error:** `Unable to listen on port 9090`

**Solution:**
```bash
# Kill existing port forwards
pkill -f "port-forward"

# Restart port forwards
./scripts/start-port-forwards.sh
```

### Issue: Pods not starting

**Error:** Pods stuck in `Pending` or `CrashLoopBackOff`

**Solution:**
```bash
# Check pod details
kubectl describe pod <pod-name> -n monitoring

# Check logs
kubectl logs <pod-name> -n monitoring

# Restart pod
kubectl delete pod <pod-name> -n monitoring
```

### Issue: Python import errors

**Error:** `ModuleNotFoundError: No module named 'kubernetes'`

**Solution:**
```bash
# Activate virtual environment
source venv/bin/activate

# Install dependencies
pip install kubernetes>=28.1.0
```

---

## 📚 Next Steps

After completing Sprint 1:

1. ✅ Explore Grafana dashboards
2. ✅ Review Prometheus alerts
3. ✅ Test Python scripts
4. ✅ Read MONITORING_GUIDE.md
5. ✅ Customize dashboards
6. ✅ Add custom alerts
7. ✅ Plan Sprint 2 features

---

## 📖 Additional Resources

- **GETTING_STARTED.md** - Quick 15-minute setup
- **TESTING_GUIDE.md** - Complete testing instructions
- **MONITORING_GUIDE.md** - Monitoring configuration
- **TROUBLESHOOTING.md** - Common issues and solutions
- **QUICK_REFERENCE.md** - Command cheat sheet

---

**Sprint 1 Complete!** 🎉

You now have a fully functional Kubernetes cluster with comprehensive monitoring!

