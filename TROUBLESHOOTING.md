# Troubleshooting Guide

Common issues and solutions for Sprint 1 setup.

---

## 🔧 Minikube Issues

### Issue: Minikube won't start

**Symptoms:**
```
❌ Exiting due to PROVIDER_DOCKER_NOT_RUNNING
```

**Solution:**
```bash
# Make sure Docker Desktop is running
open -a Docker  # macOS

# Wait for Docker to start, then try again
minikube start
```

---

### Issue: Insufficient resources

**Symptoms:**
```
❌ Requested memory allocation (8192MB) is more than available
```

**Solution:**
```bash
# Start with fewer resources
minikube start --cpus=2 --memory=4096

# Or increase Docker Desktop resources:
# Docker Desktop → Settings → Resources → Increase Memory/CPU
```

---

### Issue: Minikube stuck or unresponsive

**Solution:**
```bash
# Delete and recreate the cluster
minikube delete
minikube start --cpus=4 --memory=8192
```

---

## 🐳 Kubernetes Issues

### Issue: Pods stuck in "Pending" state

**Symptoms:**
```bash
kubectl get pods -n monitoring
# Shows pods in Pending state
```

**Solution:**
```bash
# Check pod events
kubectl describe pod <pod-name> -n monitoring

# Common causes:
# 1. Insufficient resources - reduce resource requests
# 2. Image pull issues - check internet connection
# 3. PVC issues - check persistent volume claims

# Check node resources
kubectl top nodes

# If resources are low, restart with more resources
minikube delete
minikube start --cpus=4 --memory=8192
```

---

### Issue: Pods stuck in "ImagePullBackOff"

**Symptoms:**
```bash
kubectl get pods -n monitoring
# Shows ImagePullBackOff or ErrImagePull
```

**Solution:**
```bash
# Check pod events
kubectl describe pod <pod-name> -n monitoring

# Common causes:
# 1. No internet connection
# 2. Docker Hub rate limiting

# Solution: Wait a few minutes and pods will retry
# Or restart the pod:
kubectl delete pod <pod-name> -n monitoring
```

---

### Issue: Cannot connect to cluster

**Symptoms:**
```
❌ The connection to the server localhost:8080 was refused
```

**Solution:**
```bash
# Make sure Minikube is running
minikube status

# If not running, start it
minikube start

# Update kubectl context
kubectl config use-context minikube

# Verify connection
kubectl cluster-info
```

---

## 🐍 Python Issues

### Issue: "kubernetes" module not found

**Symptoms:**
```
ModuleNotFoundError: No module named 'kubernetes'
```

**Solution:**
```bash
# Make sure virtual environment is activated
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Verify installation
python3 -c "from kubernetes import client, config; print('✅ OK')"
```

---

### Issue: Cannot load kube config

**Symptoms:**
```
kubernetes.config.config_exception.ConfigException: Invalid kube-config file
```

**Solution:**
```bash
# Check if kubectl works
kubectl get nodes

# If kubectl works, the issue is with Python
# Make sure you're using the right config
python3 -c "from kubernetes import config; config.load_kube_config(); print('✅ OK')"

# If still failing, check config file
cat ~/.kube/config
```

---

## 📊 Prometheus Issues

### Issue: Prometheus pods not starting

**Symptoms:**
```bash
kubectl get pods -n monitoring
# Prometheus pods in CrashLoopBackOff or Error state
```

**Solution:**
```bash
# Check pod logs
kubectl logs -n monitoring <prometheus-pod-name>

# Common causes:
# 1. Insufficient memory - increase Minikube memory
# 2. Configuration errors - reinstall Prometheus

# Reinstall Prometheus
helm uninstall prometheus -n monitoring
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.retention=7d \
  --set grafana.enabled=true \
  --set grafana.adminPassword=admin123
```

---

### Issue: Cannot access Prometheus UI

**Symptoms:**
```
curl: (7) Failed to connect to localhost port 9090
```

**Solution:**
```bash
# Make sure port-forward is running
# Kill any existing port-forwards
pkill -f "port-forward.*9090"

# Start new port-forward
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090

# In another terminal, test:
curl http://localhost:9090

# Or open in browser: http://localhost:9090
```

---

### Issue: Grafana login not working

**Symptoms:**
```
Invalid username or password
```

**Solution:**
```bash
# Default credentials:
# Username: admin
# Password: admin123

# If you forgot the password, get it from the secret:
kubectl get secret -n monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode
echo

# Or reset the password:
helm upgrade prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --reuse-values \
  --set grafana.adminPassword=newpassword123
```

---

## 🔍 Debugging Commands

### Check overall cluster health
```bash
# Cluster info
kubectl cluster-info

# All pods
kubectl get pods -A

# All services
kubectl get svc -A

# Node status
kubectl get nodes

# Events (recent issues)
kubectl get events -A --sort-by='.lastTimestamp'
```

### Check specific component
```bash
# Describe a pod (detailed info)
kubectl describe pod <pod-name> -n <namespace>

# View pod logs
kubectl logs <pod-name> -n <namespace>

# View previous pod logs (if crashed)
kubectl logs <pod-name> -n <namespace> --previous

# Execute command in pod
kubectl exec -it <pod-name> -n <namespace> -- /bin/sh
```

### Check resources
```bash
# Node resources
kubectl top nodes

# Pod resources
kubectl top pods -A

# Minikube resources
minikube ssh
free -h
df -h
exit
```

---

## 🔄 Complete Reset

If nothing works, start fresh:

```bash
# 1. Delete Minikube cluster
minikube delete

# 2. Remove virtual environment
rm -rf venv

# 3. Start fresh
./scripts/setup-minikube.sh
```

---

## 📞 Getting More Help

### Useful Resources
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Prometheus Documentation](https://prometheus.io/docs/)

### Check Logs
```bash
# Minikube logs
minikube logs

# Docker logs
docker logs minikube

# System events
kubectl get events -A --sort-by='.lastTimestamp' | tail -20
```

### Verify Prerequisites
```bash
# Check versions
docker --version
minikube version
kubectl version --client
helm version
python3 --version

# Check Docker is running
docker ps

# Check Minikube status
minikube status
```

---

## 💡 Tips

1. **Always check pod events first**: `kubectl describe pod <pod-name> -n <namespace>`
2. **Check logs for errors**: `kubectl logs <pod-name> -n <namespace>`
3. **Verify resources**: `kubectl top nodes` and `kubectl top pods -A`
4. **When in doubt, restart**: `minikube stop && minikube start`
5. **Complete reset if needed**: `minikube delete` then run setup again

---

**Still having issues?** Run the verification script:
```bash
./scripts/verify-setup.sh
```

This will identify which components are not working correctly.

