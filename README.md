# Kubernetes Cluster Health Checker

> A simple, practical Kubernetes cluster health monitoring system using Minikube

## 🎯 Project Overview

This project monitors Kubernetes cluster health by checking nodes, pods, and services, with Prometheus integration for metrics collection.

## 📋 Sprint 1: Project Setup and Kubernetes Cluster Access

**Goal**: Set up a local Kubernetes environment with Minikube and configure basic monitoring with Prometheus.

### What You'll Build
- ✅ Local Kubernetes cluster using Minikube
- ✅ Basic health monitoring scripts
- ✅ Prometheus for metrics collection
- ✅ Simple Python scripts to interact with Kubernetes API

---

## 🚀 Quick Start (5 Minutes)

### Prerequisites
```bash
# Check if you have these installed:
docker --version          # Docker Desktop
minikube version         # Minikube
kubectl version --client # kubectl
python3 --version        # Python 3.11+
```

### One-Command Setup
```bash
# Run the automated setup
chmod +x scripts/setup-minikube.sh
./scripts/setup-minikube.sh
```

### Manual Setup (Step-by-Step)
See [SPRINT_1_GUIDE.md](SPRINT_1_GUIDE.md) for detailed instructions.

---

## 📁 Project Structure

```
.
├── README.md                      # This file
├── SPRINT_1_GUIDE.md             # Detailed Sprint 1 guide
├── EXAMPLES.md                   # Code examples with outputs
├── scripts/
│   ├── setup-minikube.sh        # Automated setup
│   ├── check-health.py          # Simple health checker
│   └── verify-setup.sh          # Verification script
├── src/
│   ├── cluster_info.py          # Get cluster information
│   └── health_monitor.py        # Basic health monitoring
└── requirements.txt              # Python dependencies
```

---

## 📖 Documentation

- **[SPRINT_1_GUIDE.md](SPRINT_1_GUIDE.md)** - Complete step-by-step guide
- **[EXAMPLES.md](EXAMPLES.md)** - Code examples with outputs
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Common issues and solutions

---

## 🎓 Learning Path

1. **Start Here**: Read this README
2. **Setup**: Follow [SPRINT_1_GUIDE.md](SPRINT_1_GUIDE.md)
3. **Practice**: Try examples in [EXAMPLES.md](EXAMPLES.md)
4. **Troubleshoot**: Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) if needed

---

## 🔧 What's Included

### Scripts
- `setup-minikube.sh` - Automated cluster setup
- `check-health.py` - Simple health monitoring
- `verify-setup.sh` - Validate your setup

### Python Code
- Simple, well-commented Python scripts
- Direct Kubernetes API interaction
- Easy-to-understand examples

### Documentation
- Step-by-step guides
- Code examples with expected outputs
- Troubleshooting tips

---

## 📊 Expected Outputs

After setup, you'll be able to:

```bash
# Check cluster status
kubectl get nodes
# Output: Shows your Minikube node as Ready

# Run health check
python3 scripts/check-health.py
# Output: Displays node, pod, and service health

# Access Prometheus
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
# Output: Prometheus UI at http://localhost:9090
```

---

## 🆘 Need Help?

- **Setup Issues**: See [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **Understanding Code**: Check [EXAMPLES.md](EXAMPLES.md)
- **Step-by-Step**: Follow [SPRINT_1_GUIDE.md](SPRINT_1_GUIDE.md)

---

## 📝 Sprint 1 Tasks

- [x] Define project structure
- [ ] Set up Minikube cluster
- [ ] Configure Kubernetes API access
- [ ] Install Prometheus
- [ ] Create basic health monitoring scripts
- [ ] Test and validate

---

**Ready to start?** Open [SPRINT_1_GUIDE.md](SPRINT_1_GUIDE.md) and begin! 🚀

