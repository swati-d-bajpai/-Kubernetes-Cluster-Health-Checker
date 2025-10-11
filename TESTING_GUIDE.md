# 🧪 Sprint 1 Testing Guide

Complete step-by-step testing guide with expected outputs for every command.

---

## 📋 Table of Contents

1. [Prerequisites Check](#step-1-prerequisites-check)
2. [Run Setup Script](#step-2-run-setup-script)
3. [Verify Minikube](#step-3-verify-minikube)
4. [Verify Kubernetes](#step-4-verify-kubernetes)
5. [Verify Prometheus](#step-5-verify-prometheus)
6. [Test Python Scripts](#step-6-test-python-scripts)
7. [Access Web Interfaces](#step-7-access-web-interfaces)
8. [Run Verification Script](#step-8-run-verification-script)
9. [Health Check](#step-9-health-check)
10. [Cleanup (Optional)](#step-10-cleanup-optional)

---

## Step 1: Prerequisites Check

### 1.1 Check Docker

```bash
docker --version
```

**Expected Output:**
```
Docker version 24.0.0 or higher
```

**Verify Docker is Running:**
```bash
docker ps
```

**Expected Output:**
```
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
(may be empty if no containers running)
```

---

### 1.2 Check Minikube

```bash
minikube version
```

**Expected Output:**
```
minikube version: v1.37.0 or higher
commit: <commit-hash>
```

---

### 1.3 Check kubectl

```bash
kubectl version --client
```

**Expected Output:**
```
Client Version: v1.28.0 or higher
Kustomize Version: v5.0.0 or higher
```

---

### 1.4 Check Helm

```bash
helm version
```

**Expected Output:**
```
version.BuildInfo{Version:"v3.13.0" or higher, GitCommit:"...", GitTreeState:"clean", GoVersion:"go1.21.0"}
```

---

### 1.5 Check Python

```bash
python3 --version
```

**Expected Output:**
```
Python 3.8.0 or higher
```

---

## Step 2: Run Setup Script

### 2.1 Make Script Executable (if not already)

```bash
chmod +x scripts/setup-minikube.sh
```

**Expected Output:**
```
(no output - silent success)
```

---

### 2.2 Run Setup Script

```bash
./scripts/setup-minikube.sh
```

**Expected Output (This will take 10-15 minutes):**

```
╔══════════════════════════════════════════════════════════════════════════╗
║                                                                          ║
║           KUBERNETES CLUSTER SETUP WITH MINIKUBE                        ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════════╝

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 1/7: Checking Prerequisites
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Docker is installed
✅ Minikube is installed
✅ kubectl is installed
✅ Helm is installed
✅ Python3 is installed

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 2/7: Starting Minikube Cluster
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ℹ️  Starting Minikube with 4 CPUs, 6144MB RAM (6GB), 20g disk...
😄  minikube v1.37.0 on Darwin 26.0.1 (arm64)
✨  Using the docker driver based on user configuration
📌  Using Docker Desktop driver with root privileges
👍  Starting control plane node minikube in cluster minikube
🚜  Pulling base image ...
🔥  Creating docker container (CPUs=4, Memory=6144MB) ...
🐳  Preparing Kubernetes v1.28.3 on Docker 24.0.7 ...
🔗  Configuring bridge CNI (Container Networking Interface) ...
🔎  Verifying Kubernetes components...
🌟  Enabled addons: storage-provisioner, default-storageclass
✅ Minikube cluster started

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 3/7: Enabling Addons
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ℹ️  Enabling metrics-server addon...
💡  metrics-server is an addon maintained by Kubernetes. For any concerns contact minikube on GitHub.
✅ metrics-server addon enabled

ℹ️  Enabling ingress addon...
💡  ingress is an addon maintained by Kubernetes. For any concerns contact minikube on GitHub.
✅ ingress addon enabled

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 4/7: Setting up Python Environment
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Virtual environment already exists
✅ Kubernetes Python client installed

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 5/7: Installing Prometheus
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ℹ️  Adding Prometheus Helm repository...
"prometheus-community" has been added to your repositories
✅ Prometheus Helm repository added

ℹ️  Creating monitoring namespace...
namespace/monitoring created
✅ Namespace 'monitoring' created

ℹ️  Installing Prometheus (this may take 5-10 minutes)...
NAME: prometheus
LAST DEPLOYED: ...
NAMESPACE: monitoring
STATUS: deployed
REVISION: 1
✅ Prometheus installed

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 6/7: Waiting for Pods to be Ready
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ℹ️  Waiting for all pods in monitoring namespace to be ready...
⏳ Waiting for pods... (this may take 5-10 minutes)
✅ All pods are ready!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 7/7: Setup Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ SETUP COMPLETED SUCCESSFULLY!

📊 Cluster Information:
   • Minikube Status: Running
   • Kubernetes Version: v1.28.3
   • Monitoring Namespace: Created
   • Prometheus: Installed

🎯 Next Steps:
   1. Verify setup: ./scripts/verify-setup.sh
   2. Access Prometheus: kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
   3. Access Grafana: kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
   4. Run Python scripts: python3 src/cluster_info.py

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Step 3: Verify Minikube

### 3.1 Check Minikube Status

```bash
minikube status
```

**Expected Output:**
```
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

---

### 3.2 Check Minikube Profile

```bash
minikube profile list
```

**Expected Output:**
```
|----------|-----------|---------|--------------|------|---------|---------|-------|--------|
| Profile  | VM Driver | Runtime |      IP      | Port | Version | Status  | Nodes | Active |
|----------|-----------|---------|--------------|------|---------|---------|-------|--------|
| minikube | docker    | docker  | 192.168.49.2 | 8443 | v1.28.3 | Running |     1 | *      |
|----------|-----------|---------|--------------|------|---------|---------|-------|--------|
```

---

### 3.3 Get Minikube IP

```bash
minikube ip
```

**Expected Output:**
```
192.168.49.2
(or similar IP address)
```

---

## Step 4: Verify Kubernetes

### 4.1 Check Cluster Info

```bash
kubectl cluster-info
```

**Expected Output:**
```
Kubernetes control plane is running at https://192.168.49.2:8443
CoreDNS is running at https://192.168.49.2:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

---

### 4.2 Check Nodes

```bash
kubectl get nodes
```

**Expected Output:**
```
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   10m   v1.28.3
```

---

### 4.3 Check Node Details

```bash
kubectl describe node minikube
```

**Expected Output (abbreviated):**
```
Name:               minikube
Roles:              control-plane
Labels:             beta.kubernetes.io/arch=arm64
                    beta.kubernetes.io/os=linux
                    kubernetes.io/arch=arm64
                    kubernetes.io/hostname=minikube
                    kubernetes.io/os=linux
                    minikube.k8s.io/commit=...
                    minikube.k8s.io/name=minikube
                    minikube.k8s.io/primary=true
                    minikube.k8s.io/updated_at=...
                    minikube.k8s.io/version=v1.37.0
                    node-role.kubernetes.io/control-plane=
                    node.kubernetes.io/exclude-from-external-load-balancers=
Annotations:        kubeadm.alpha.kubernetes.io/cri-socket: unix:///var/run/cri-dockerd.sock
                    node.alpha.kubernetes.io/ttl: 0
                    volumes.kubernetes.io/controller-managed-attach-detach: true
CreationTimestamp:  ...
Taints:             <none>
Unschedulable:      false
Conditions:
  Type             Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
  ----             ------  -----------------                 ------------------                ------                       -------
  MemoryPressure   False   ...                               ...                               KubeletHasSufficientMemory   kubelet has sufficient memory available
  DiskPressure     False   ...                               ...                               KubeletHasNoDiskPressure     kubelet has no disk pressure
  PIDPressure      False   ...                               ...                               KubeletHasSufficientPID      kubelet has sufficient PID available
  Ready            True    ...                               ...                               KubeletReady                 kubelet is posting ready status
Addresses:
  InternalIP:  192.168.49.2
  Hostname:    minikube
Capacity:
  cpu:                4
  ephemeral-storage:  61255492Ki
  hugepages-1Gi:      0
  hugepages-2Mi:      0
  hugepages-32Mi:     0
  hugepages-64Ki:     0
  memory:             6291456Ki
  pods:               110
Allocatable:
  cpu:                4
  ephemeral-storage:  61255492Ki
  hugepages-1Gi:      0
  hugepages-2Mi:      0
  hugepages-32Mi:     0
  hugepages-64Ki:     0
  memory:             6291456Ki
  pods:               110
...
```

---

### 4.4 Check All Namespaces

```bash
kubectl get namespaces
```

**Expected Output:**
```
NAME              STATUS   AGE
default           Active   10m
kube-node-lease   Active   10m
kube-public       Active   10m
kube-system       Active   10m
monitoring        Active   5m
```

---

### 4.5 Check All Pods

```bash
kubectl get pods --all-namespaces
```

**Expected Output:**
```
NAMESPACE     NAME                                                     READY   STATUS    RESTARTS   AGE
kube-system   coredns-5dd5756b68-xxxxx                                1/1     Running   0          10m
kube-system   etcd-minikube                                           1/1     Running   0          10m
kube-system   kube-apiserver-minikube                                 1/1     Running   0          10m
kube-system   kube-controller-manager-minikube                        1/1     Running   0          10m
kube-system   kube-proxy-xxxxx                                        1/1     Running   0          10m
kube-system   kube-scheduler-minikube                                 1/1     Running   0          10m
kube-system   metrics-server-xxxxx                                    1/1     Running   0          8m
kube-system   storage-provisioner                                     1/1     Running   0          10m
monitoring    alertmanager-prometheus-kube-prometheus-alertmanager-0  2/2     Running   0          5m
monitoring    prometheus-grafana-xxxxx                                3/3     Running   0          5m
monitoring    prometheus-kube-prometheus-operator-xxxxx               1/1     Running   0          5m
monitoring    prometheus-kube-state-metrics-xxxxx                     1/1     Running   0          5m
monitoring    prometheus-prometheus-kube-prometheus-prometheus-0      2/2     Running   0          5m
monitoring    prometheus-prometheus-node-exporter-xxxxx               1/1     Running   0          5m
```

---

## Step 5: Verify Prometheus

### 5.1 Check Monitoring Namespace

```bash
kubectl get all -n monitoring
```

**Expected Output:**
```
NAME                                                         READY   STATUS    RESTARTS   AGE
pod/alertmanager-prometheus-kube-prometheus-alertmanager-0   2/2     Running   0          5m
pod/prometheus-grafana-xxxxx                                 3/3     Running   0          5m
pod/prometheus-kube-prometheus-operator-xxxxx                1/1     Running   0          5m
pod/prometheus-kube-state-metrics-xxxxx                      1/1     Running   0          5m
pod/prometheus-prometheus-kube-prometheus-prometheus-0       2/2     Running   0          5m
pod/prometheus-prometheus-node-exporter-xxxxx                1/1     Running   0          5m

NAME                                              TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
service/alertmanager-operated                     ClusterIP   None             <none>        9093/TCP,9094/TCP,9094/UDP   5m
service/prometheus-grafana                        ClusterIP   10.96.xxx.xxx    <none>        80/TCP                       5m
service/prometheus-kube-prometheus-alertmanager   ClusterIP   10.96.xxx.xxx    <none>        9093/TCP,8080/TCP            5m
service/prometheus-kube-prometheus-operator       ClusterIP   10.96.xxx.xxx    <none>        443/TCP                      5m
service/prometheus-kube-prometheus-prometheus     ClusterIP   10.96.xxx.xxx    <none>        9090/TCP,8080/TCP            5m
service/prometheus-kube-state-metrics             ClusterIP   10.96.xxx.xxx    <none>        8080/TCP                     5m
service/prometheus-operated                       ClusterIP   None             <none>        9090/TCP                     5m
service/prometheus-prometheus-node-exporter       ClusterIP   10.96.xxx.xxx    <none>        9100/TCP                     5m

NAME                                                 DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
daemonset.apps/prometheus-prometheus-node-exporter   1         1         1       1            1           kubernetes.io/os=linux   5m

NAME                                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/prometheus-grafana                    1/1     1            1           5m
deployment.apps/prometheus-kube-prometheus-operator   1/1     1            1           5m
deployment.apps/prometheus-kube-state-metrics         1/1     1            1           5m

NAME                                                             DESIRED   CURRENT   READY   AGE
replicaset.apps/prometheus-grafana-xxxxx                         1         1         1       5m
replicaset.apps/prometheus-kube-prometheus-operator-xxxxx        1         1         1       5m
replicaset.apps/prometheus-kube-state-metrics-xxxxx              1         1         1       5m

NAME                                                                    READY   AGE
statefulset.apps/alertmanager-prometheus-kube-prometheus-alertmanager   1/1     5m
statefulset.apps/prometheus-prometheus-kube-prometheus-prometheus       1/1     5m
```

---

### 5.2 Check Prometheus Services

```bash
kubectl get svc -n monitoring
```

**Expected Output:**
```
NAME                                      TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
alertmanager-operated                     ClusterIP   None             <none>        9093/TCP,9094/TCP,9094/UDP   5m
prometheus-grafana                        ClusterIP   10.96.xxx.xxx    <none>        80/TCP                       5m
prometheus-kube-prometheus-alertmanager   ClusterIP   10.96.xxx.xxx    <none>        9093/TCP,8080/TCP            5m
prometheus-kube-prometheus-operator       ClusterIP   10.96.xxx.xxx    <none>        443/TCP                      5m
prometheus-kube-prometheus-prometheus     ClusterIP   10.96.xxx.xxx    <none>        9090/TCP,8080/TCP            5m
prometheus-kube-state-metrics             ClusterIP   10.96.xxx.xxx    <none>        8080/TCP                     5m
prometheus-operated                       ClusterIP   None             <none>        9090/TCP                     5m
prometheus-prometheus-node-exporter       ClusterIP   10.96.xxx.xxx    <none>        9100/TCP                     5m
```

---

### 5.3 Check Helm Releases

```bash
helm list -n monitoring
```

**Expected Output:**
```
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                           APP VERSION
prometheus      monitoring      1               2024-01-15 10:30:00.000000 -0800 PST    deployed        kube-prometheus-stack-55.5.0    v0.70.0
```

---

## Step 6: Test Python Scripts

### 6.1 Activate Virtual Environment

```bash
source venv/bin/activate
```

**Expected Output:**
```
(venv) appears at the beginning of your prompt
```

---

### 6.2 Test Cluster Info Script

```bash
python3 src/cluster_info.py
```

**Expected Output:**
```
============================================================
KUBERNETES CLUSTER INFORMATION
============================================================

📌 Kubernetes Version: v1.28.3
📌 Platform: linux/arm64

============================================================
NODES
============================================================

✅ Node: minikube
   Status: Ready
   Ready: True
   CPU: 4
   Memory: 6291456Ki

============================================================
NAMESPACES
============================================================

Total Namespaces: 5

  • default
  • kube-node-lease
  • kube-public
  • kube-system
  • monitoring

============================================================
```

---

### 6.3 Test Health Monitor Script

```bash
python3 src/health_monitor.py
```

**Expected Output:**
```
============================================================
POD HEALTH MONITOR
============================================================

📊 Pod Status Summary:
   Running: 14 pods
   Succeeded: 0 pods
   Failed: 0 pods
   Pending: 0 pods

============================================================
MONITORING NAMESPACE PODS
============================================================

✅ alertmanager-prometheus-kube-prometheus-alertmanager-0
   Status: Running
   Containers: 2/2 ready
   Node: minikube

✅ prometheus-grafana-xxxxx
   Status: Running
   Containers: 3/3 ready
   Node: minikube

✅ prometheus-kube-prometheus-operator-xxxxx
   Status: Running
   Containers: 1/1 ready
   Node: minikube

✅ prometheus-kube-state-metrics-xxxxx
   Status: Running
   Containers: 1/1 ready
   Node: minikube

✅ prometheus-prometheus-kube-prometheus-prometheus-0
   Status: Running
   Containers: 2/2 ready
   Node: minikube

✅ prometheus-prometheus-node-exporter-xxxxx
   Status: Running
   Containers: 1/1 ready
   Node: minikube

============================================================
```

---

### 6.4 Test Service Info Script

```bash
python3 src/service_info.py
```

**Expected Output:**
```
============================================================
KUBERNETES SERVICES
============================================================

📊 Services in 'monitoring' namespace: 8

🔹 Service: alertmanager-operated
   Type: ClusterIP
   Cluster IP: None
   Ports:
      • web: 9093/TCP
      • tcp-mesh: 9094/TCP
      • udp-mesh: 9094/UDP

🔹 Service: prometheus-grafana
   Type: ClusterIP
   Cluster IP: 10.96.xxx.xxx
   Ports:
      • http-web: 80/TCP

🔹 Service: prometheus-kube-prometheus-alertmanager
   Type: ClusterIP
   Cluster IP: 10.96.xxx.xxx
   Ports:
      • http-web: 9093/TCP
      • reloader-web: 8080/TCP

🔹 Service: prometheus-kube-prometheus-operator
   Type: ClusterIP
   Cluster IP: 10.96.xxx.xxx
   Ports:
      • https: 443/TCP

🔹 Service: prometheus-kube-prometheus-prometheus
   Type: ClusterIP
   Cluster IP: 10.96.xxx.xxx
   Ports:
      • http-web: 9090/TCP
      • reloader-web: 8080/TCP

🔹 Service: prometheus-kube-state-metrics
   Type: ClusterIP
   Cluster IP: 10.96.xxx.xxx
   Ports:
      • http: 8080/TCP

🔹 Service: prometheus-operated
   Type: ClusterIP
   Cluster IP: None
   Ports:
      • web: 9090/TCP

🔹 Service: prometheus-prometheus-node-exporter
   Type: ClusterIP
   Cluster IP: 10.96.xxx.xxx
   Ports:
      • metrics: 9100/TCP

============================================================
```

---

### 6.5 Test Health Check Script

```bash
python3 scripts/check-health.py
```

**Expected Output:**
```
============================================================
KUBERNETES CLUSTER HEALTH CHECK
============================================================

🔍 Checking Nodes...
✅ Node minikube is ready

🔍 Checking Critical Pods...
✅ All critical pods are running

============================================================
✅ CLUSTER IS HEALTHY
============================================================
```

---

## Step 7: Access Web Interfaces

### 7.1 Access Prometheus UI

**Open a NEW terminal window** and run:

```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
```

**Expected Output:**
```
Forwarding from 127.0.0.1:9090 -> 9090
Forwarding from [::1]:9090 -> 9090
```

**Then open in browser:**
```
http://localhost:9090
```

**What you should see:**
- Prometheus web interface
- Graph tab with query interface
- Status → Targets showing all targets
- All targets should be "UP"

**Test a query:**
In the query box, type:
```
up
```
Click "Execute" - you should see metrics for all running services.

**Leave this terminal running!** Press `Ctrl+C` to stop when done.

---

### 7.2 Access Grafana UI

**Open ANOTHER NEW terminal window** and run:

```bash
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```

**Expected Output:**
```
Forwarding from 127.0.0.1:3000 -> 3000
Forwarding from [::1]:3000 -> 3000
```

**Then open in browser:**
```
http://localhost:3000
```

**Login credentials:**
- Username: `admin`
- Password: Get it with this command:

```bash
kubectl get secret -n monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

**Expected password output:**
```
prom-operator
```

**What you should see:**
- Grafana login page
- After login: Grafana dashboard
- Pre-configured dashboards for Kubernetes monitoring

**Leave this terminal running!** Press `Ctrl+C` to stop when done.

---

### 7.3 Access AlertManager UI (Optional)

**Open ANOTHER NEW terminal window** and run:

```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-alertmanager 9093:9093
```

**Expected Output:**
```
Forwarding from 127.0.0.1:9093 -> 9093
Forwarding from [::1]:9093 -> 9093
```

**Then open in browser:**
```
http://localhost:9093
```

**What you should see:**
- AlertManager web interface
- List of alerts (should be empty if cluster is healthy)

---

## Step 8: Run Verification Script

### 8.1 Run Verification

```bash
./scripts/verify-setup.sh
```

**Expected Output:**
```
╔══════════════════════════════════════════════════════════════════════════╗
║                                                                          ║
║              KUBERNETES CLUSTER VERIFICATION                            ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════════╝

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Running Verification Tests
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[1/10] Checking Minikube status...
✅ PASS: Minikube is running

[2/10] Checking kubectl connection...
✅ PASS: kubectl can connect to cluster

[3/10] Checking node readiness...
✅ PASS: All nodes are ready

[4/10] Checking monitoring namespace...
✅ PASS: Monitoring namespace exists

[5/10] Checking Prometheus pods...
✅ PASS: Prometheus pods are running

[6/10] Checking Grafana pods...
✅ PASS: Grafana pods are running

[7/10] Checking Python virtual environment...
✅ PASS: Python virtual environment exists

[8/10] Checking Kubernetes Python client...
✅ PASS: Kubernetes Python client is installed

[9/10] Checking metrics-server...
✅ PASS: Metrics server is running

[10/10] Checking script permissions...
✅ PASS: All scripts are executable

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Verification Results
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ ALL TESTS PASSED (10/10)

Success Rate: 100%

╔══════════════════════════════════════════════════════════════════════════╗
║                                                                          ║
║                  ✅ VERIFICATION SUCCESSFUL!                            ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════════╝

Your Kubernetes cluster is ready to use! 🎉
```

---

## Step 9: Health Check

### 9.1 Quick Health Check

```bash
python3 scripts/check-health.py && echo "Exit code: $?"
```

**Expected Output:**
```
============================================================
KUBERNETES CLUSTER HEALTH CHECK
============================================================

🔍 Checking Nodes...
✅ Node minikube is ready

🔍 Checking Critical Pods...
✅ All critical pods are running

============================================================
✅ CLUSTER IS HEALTHY
============================================================
Exit code: 0
```

**Exit code 0 means healthy!**

---

## Step 10: Cleanup (Optional)

### 10.1 Stop Port Forwards

In each terminal running port-forward, press:
```
Ctrl+C
```

---

### 10.2 Stop Minikube (Optional)

```bash
minikube stop
```

**Expected Output:**
```
✋  Stopping node "minikube"  ...
🛑  Powering off "minikube" via SSH ...
🛑  1 node stopped.
```

---

### 10.3 Delete Minikube Cluster (Optional - Only if you want to start fresh)

```bash
minikube delete
```

**Expected Output:**
```
🔥  Deleting "minikube" in docker ...
🔥  Deleting container "minikube" ...
🔥  Removing /Users/username/.minikube/machines/minikube ...
💀  Removed all traces of the "minikube" cluster.
```

---

## 📊 Summary Checklist

Use this checklist to verify everything is working:

- [ ] **Prerequisites installed**
  - [ ] Docker running
  - [ ] Minikube installed
  - [ ] kubectl installed
  - [ ] Helm installed
  - [ ] Python 3.8+ installed

- [ ] **Cluster running**
  - [ ] Minikube status: Running
  - [ ] Node status: Ready
  - [ ] All namespaces created

- [ ] **Prometheus installed**
  - [ ] Monitoring namespace exists
  - [ ] All Prometheus pods running
  - [ ] All services created
  - [ ] Helm release deployed

- [ ] **Python scripts working**
  - [ ] Virtual environment activated
  - [ ] cluster_info.py runs successfully
  - [ ] health_monitor.py runs successfully
  - [ ] service_info.py runs successfully
  - [ ] check-health.py returns exit code 0

- [ ] **Web interfaces accessible**
  - [ ] Prometheus UI accessible at localhost:9090
  - [ ] Grafana UI accessible at localhost:3000
  - [ ] Can login to Grafana

- [ ] **Verification passed**
  - [ ] verify-setup.sh shows 10/10 tests passed
  - [ ] 100% success rate

---

## 🎉 Congratulations!

If all tests passed, you have successfully completed Sprint 1!

**You now have:**
- ✅ A running Kubernetes cluster (Minikube)
- ✅ Prometheus monitoring installed
- ✅ Grafana dashboards configured
- ✅ Python scripts to interact with the cluster
- ✅ Full API access to Kubernetes resources

**Next Steps:**
- Explore Prometheus queries
- Create custom Grafana dashboards
- Modify Python scripts for your needs
- Move on to Sprint 2!

---

## 📚 Quick Reference

**Start Minikube:**
```bash
minikube start
```

**Stop Minikube:**
```bash
minikube stop
```

**Check Status:**
```bash
minikube status
kubectl get nodes
kubectl get pods --all-namespaces
```

**Access Prometheus:**
```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
# Open: http://localhost:9090
```

**Access Grafana:**
```bash
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
# Open: http://localhost:3000
# Login: admin / prom-operator
```

**Run Python Scripts:**
```bash
source venv/bin/activate
python3 src/cluster_info.py
python3 src/health_monitor.py
python3 src/service_info.py
python3 scripts/check-health.py
```

---

**Happy Kubernetes Learning!** 🚀

