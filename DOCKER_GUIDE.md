# Docker Guide - Kubernetes Cluster Health Checker

Complete guide for using Docker and Docker Compose with the Kubernetes Cluster Health Checker.

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Docker Files Explained](#docker-files-explained)
3. [Quick Start](#quick-start)
4. [Building Images](#building-images)
5. [Running with Docker Compose](#running-with-docker-compose)
6. [Configuration](#configuration)
7. [Troubleshooting](#troubleshooting)
8. [Best Practices](#best-practices)

---

## 🎯 Overview

### What's Included

This project includes complete Docker support:

- **Dockerfile** - Multi-stage build for optimized images
- **docker-compose.yml** - Complete monitoring stack
- **.dockerignore** - Optimized build context
- **Configuration files** - Prometheus, Grafana, AlertManager

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    DOCKER COMPOSE STACK                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────┐  ┌──────────────────┐               │
│  │  Health Checker  │  │   Prometheus     │               │
│  │  (Main App)      │  │  (Metrics)       │               │
│  │  Port: 8080      │  │  Port: 9090      │               │
│  └──────────────────┘  └──────────────────┘               │
│                                                             │
│  ┌──────────────────┐  ┌──────────────────┐               │
│  │    Grafana       │  │  AlertManager    │               │
│  │  (Dashboards)    │  │  (Alerts)        │               │
│  │  Port: 3000      │  │  Port: 9093      │               │
│  └──────────────────┘  └──────────────────┘               │
│                                                             │
│  ┌──────────────────┐                                      │
│  │  Node Exporter   │                                      │
│  │  (Host Metrics)  │                                      │
│  │  Port: 9100      │                                      │
│  └──────────────────┘                                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 Docker Files Explained

### 1. Dockerfile

**Purpose:** Build optimized container image for the health checker

**Key Features:**
- ✅ Multi-stage build (reduces image size)
- ✅ Non-root user (security)
- ✅ Health checks
- ✅ Minimal dependencies
- ✅ Python 3.11 slim base

**Stages:**
1. **Builder stage** - Install dependencies
2. **Runtime stage** - Copy only what's needed

**Image Size:**
- Without multi-stage: ~800MB
- With multi-stage: ~200MB
- **Savings: 75%!**

---

### 2. docker-compose.yml

**Purpose:** Orchestrate multiple containers

**Services Included:**

1. **health-checker** (Main application)
   - Monitors Kubernetes cluster
   - Runs health checks
   - Exposes metrics

2. **prometheus** (Metrics collection)
   - Scrapes metrics
   - Stores time-series data
   - Evaluates alerts

3. **grafana** (Visualization)
   - Beautiful dashboards
   - Data visualization
   - Alert management

4. **alertmanager** (Alert handling)
   - Routes alerts
   - Deduplicates notifications
   - Sends to Email/Slack/PagerDuty

5. **node-exporter** (Host metrics)
   - CPU, Memory, Disk metrics
   - Network statistics
   - System information

**Resource Limits:**
```yaml
health-checker:  CPU: 0.5, Memory: 512M
prometheus:      CPU: 1.0, Memory: 1G
grafana:         CPU: 0.5, Memory: 512M
alertmanager:    CPU: 0.25, Memory: 256M
node-exporter:   CPU: 0.25, Memory: 128M
```

---

### 3. .dockerignore

**Purpose:** Exclude files from Docker build context

**What's excluded:**
- Documentation files (*.md)
- Git files (.git/)
- Python cache (__pycache__/)
- Virtual environments (venv/)
- IDE files (.vscode/, .idea/)
- Test files (tests/)
- Logs (*.log)
- Temporary files (*.tmp)

**Benefits:**
- ✅ Faster builds (smaller context)
- ✅ Smaller images
- ✅ Better security (no secrets)
- ✅ Cleaner containers

**Build Context Size:**
- Without .dockerignore: ~50MB
- With .dockerignore: ~5MB
- **Savings: 90%!**

---

### 4. Configuration Files

#### config/prometheus.yml
- Prometheus scrape configuration
- Alert rules loading
- Service discovery

#### config/alertmanager.yml
- Alert routing rules
- Notification channels
- Inhibition rules

#### config/grafana-datasources.yml
- Grafana datasource configuration
- Prometheus connection

#### config/grafana-dashboards.yml
- Dashboard provisioning
- Auto-load dashboards

---

## 🚀 Quick Start

### Prerequisites

```bash
# Check Docker is installed
docker --version
# Docker version 20.10.0 or later

# Check Docker Compose is installed
docker-compose --version
# Docker Compose version 2.0.0 or later

# Check Docker is running
docker ps
```

### Option 1: Run Everything (Recommended)

```bash
# Start all services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f

# Access services
# Prometheus: http://localhost:9090
# Grafana: http://localhost:3000 (admin/admin)
# AlertManager: http://localhost:9093
```

### Option 2: Run Only Health Checker

```bash
# Build image
docker build -t k8s-health-checker:latest .

# Run container
docker run -d \
  --name health-checker \
  -v ~/.kube/config:/root/.kube/config:ro \
  --network host \
  k8s-health-checker:latest

# View logs
docker logs -f health-checker
```

### Option 3: Run Specific Services

```bash
# Run only Prometheus and Grafana
docker-compose up -d prometheus grafana

# Run only health checker
docker-compose up -d health-checker
```

---

## 🔨 Building Images

### Build Health Checker Image

```bash
# Build with default tag
docker build -t k8s-health-checker:latest .

# Build with custom tag
docker build -t k8s-health-checker:v1.0.0 .

# Build with build arguments
docker build \
  --build-arg PYTHON_VERSION=3.11 \
  -t k8s-health-checker:latest .

# Build without cache
docker build --no-cache -t k8s-health-checker:latest .
```

### View Image Details

```bash
# List images
docker images | grep k8s-health-checker

# Inspect image
docker inspect k8s-health-checker:latest

# View image history
docker history k8s-health-checker:latest

# Check image size
docker images k8s-health-checker:latest --format "{{.Size}}"
```

### Push to Registry

```bash
# Tag for Docker Hub
docker tag k8s-health-checker:latest username/k8s-health-checker:latest

# Push to Docker Hub
docker push username/k8s-health-checker:latest

# Tag for private registry
docker tag k8s-health-checker:latest registry.example.com/k8s-health-checker:latest

# Push to private registry
docker push registry.example.com/k8s-health-checker:latest
```

---

## 🐳 Running with Docker Compose

### Start Services

```bash
# Start all services in background
docker-compose up -d

# Start specific service
docker-compose up -d grafana

# Start with build
docker-compose up -d --build

# Start and view logs
docker-compose up
```

### Stop Services

```bash
# Stop all services
docker-compose stop

# Stop specific service
docker-compose stop grafana

# Stop and remove containers
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

### View Status

```bash
# List running containers
docker-compose ps

# View logs
docker-compose logs

# Follow logs
docker-compose logs -f

# View logs for specific service
docker-compose logs -f grafana

# View last 100 lines
docker-compose logs --tail=100
```

### Restart Services

```bash
# Restart all services
docker-compose restart

# Restart specific service
docker-compose restart prometheus

# Restart with rebuild
docker-compose up -d --build --force-recreate
```

### Scale Services

```bash
# Scale health-checker to 3 instances
docker-compose up -d --scale health-checker=3

# Scale back to 1
docker-compose up -d --scale health-checker=1
```

---

## ⚙️ Configuration

### Environment Variables

Create `.env` file:

```bash
# Application settings
LOG_LEVEL=INFO
CHECK_INTERVAL=60

# Grafana settings
GF_SECURITY_ADMIN_USER=admin
GF_SECURITY_ADMIN_PASSWORD=your-secure-password

# Prometheus settings
PROMETHEUS_RETENTION=30d

# AlertManager settings
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=alerts@example.com
SMTP_PASSWORD=your-password
```

### Volume Mounts

```yaml
# Mount kubeconfig
volumes:
  - ~/.kube/config:/root/.kube/config:ro

# Mount custom config
volumes:
  - ./config/custom-alerts.yaml:/etc/prometheus/custom-alerts.yaml:ro

# Mount logs directory
volumes:
  - ./logs:/app/logs
```

### Network Configuration

```yaml
# Use host network (access Kubernetes)
network_mode: host

# Use custom network
networks:
  - monitoring

# Expose specific ports
ports:
  - "9090:9090"
  - "3000:3000"
```

---

## 🔍 Troubleshooting

### Issue: Container won't start

```bash
# Check logs
docker-compose logs health-checker

# Check container status
docker-compose ps

# Inspect container
docker inspect k8s-health-checker

# Check resource usage
docker stats
```

### Issue: Can't access Kubernetes

```bash
# Verify kubeconfig mount
docker-compose exec health-checker ls -la /root/.kube/

# Test kubectl access
docker-compose exec health-checker kubectl get nodes

# Check network mode
docker-compose config | grep network_mode
```

### Issue: Prometheus not scraping

```bash
# Check Prometheus targets
curl http://localhost:9090/api/v1/targets

# View Prometheus logs
docker-compose logs prometheus

# Verify config
docker-compose exec prometheus cat /etc/prometheus/prometheus.yml
```

### Issue: Grafana dashboards not loading

```bash
# Check Grafana logs
docker-compose logs grafana

# Verify datasource
curl http://localhost:3000/api/datasources

# Check dashboard files
docker-compose exec grafana ls -la /etc/grafana/dashboards/
```

### Issue: High resource usage

```bash
# Check resource usage
docker stats

# Limit resources in docker-compose.yml
deploy:
  resources:
    limits:
      cpus: '0.5'
      memory: 512M
```

---

## 💡 Best Practices

### 1. Use Multi-Stage Builds

```dockerfile
# Builder stage
FROM python:3.11-slim as builder
# ... install dependencies

# Runtime stage
FROM python:3.11-slim
COPY --from=builder /root/.local /root/.local
```

### 2. Run as Non-Root User

```dockerfile
RUN useradd -m -u 1000 appuser
USER appuser
```

### 3. Use .dockerignore

```
# Exclude unnecessary files
*.md
.git/
venv/
__pycache__/
```

### 4. Add Health Checks

```dockerfile
HEALTHCHECK --interval=30s --timeout=10s \
  CMD python3 -c "import sys; sys.exit(0)"
```

### 5. Set Resource Limits

```yaml
deploy:
  resources:
    limits:
      cpus: '0.5'
      memory: 512M
```

### 6. Use Named Volumes

```yaml
volumes:
  prometheus-data:
    driver: local
```

### 7. Configure Logging

```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

### 8. Use Environment Variables

```yaml
environment:
  - LOG_LEVEL=${LOG_LEVEL:-INFO}
  - CHECK_INTERVAL=${CHECK_INTERVAL:-60}
```

---

## 📊 Monitoring Docker Containers

### View Container Metrics

```bash
# Real-time stats
docker stats

# Specific container
docker stats health-checker

# Format output
docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

### View Container Logs

```bash
# All logs
docker logs health-checker

# Follow logs
docker logs -f health-checker

# Last 100 lines
docker logs --tail=100 health-checker

# Since timestamp
docker logs --since 2024-01-01T00:00:00 health-checker
```

### Inspect Containers

```bash
# Full inspection
docker inspect health-checker

# Specific field
docker inspect health-checker --format='{{.State.Status}}'

# Network settings
docker inspect health-checker --format='{{.NetworkSettings.IPAddress}}'
```

---

## 🧹 Cleanup

### Remove Containers

```bash
# Stop and remove all containers
docker-compose down

# Remove with volumes
docker-compose down -v

# Remove specific container
docker rm -f health-checker
```

### Remove Images

```bash
# Remove image
docker rmi k8s-health-checker:latest

# Remove all unused images
docker image prune -a

# Remove with force
docker rmi -f k8s-health-checker:latest
```

### Remove Volumes

```bash
# Remove all volumes
docker volume prune

# Remove specific volume
docker volume rm prometheus-data
```

### Complete Cleanup

```bash
# Remove everything
docker-compose down -v --rmi all

# Remove all unused resources
docker system prune -a --volumes
```

---

## 📚 Additional Resources

- **Dockerfile Reference:** https://docs.docker.com/engine/reference/builder/
- **Docker Compose Reference:** https://docs.docker.com/compose/compose-file/
- **Best Practices:** https://docs.docker.com/develop/dev-best-practices/

---

**Docker makes deployment easy and consistent!** 🐳✅

