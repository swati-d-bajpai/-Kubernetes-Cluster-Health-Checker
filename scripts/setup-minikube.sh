#!/bin/bash

###############################################################################
# Automated Minikube Setup Script for Sprint 1
#
# This script automates the complete setup of:
# - Minikube Kubernetes cluster
# - Prometheus monitoring stack
# - Python environment
# - Basic validation
#
# Usage: ./scripts/setup-minikube.sh
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
MINIKUBE_CPUS=4
MINIKUBE_MEMORY=6144  # 6GB (reduced from 8GB to fit Docker Desktop limits)
MINIKUBE_DISK="20g"
NAMESPACE="monitoring"

###############################################################################
# Helper Functions
###############################################################################

print_header() {
    echo -e "\n${BLUE}============================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

check_command() {
    if command -v $1 &> /dev/null; then
        print_success "$1 is installed"
        return 0
    else
        print_error "$1 is not installed"
        return 1
    fi
}

###############################################################################
# Main Setup
###############################################################################

print_header "SPRINT 1: MINIKUBE SETUP"

# Step 1: Check Prerequisites
print_header "Step 1: Checking Prerequisites"

MISSING_DEPS=0

check_command docker || MISSING_DEPS=1
check_command minikube || MISSING_DEPS=1
check_command kubectl || MISSING_DEPS=1
check_command helm || MISSING_DEPS=1
check_command python3 || MISSING_DEPS=1

if [ $MISSING_DEPS -eq 1 ]; then
    print_error "Missing required dependencies. Please install them first."
    print_info "See SPRINT_1_GUIDE.md for installation instructions"
    exit 1
fi

print_success "All prerequisites are installed"

# Step 2: Start Minikube
print_header "Step 2: Starting Minikube Cluster"

# Check if minikube is already running
if minikube status &> /dev/null; then
    print_warning "Minikube is already running"
    read -p "Do you want to delete and recreate the cluster? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Deleting existing Minikube cluster..."
        minikube delete
    else
        print_info "Using existing cluster"
    fi
fi

if ! minikube status &> /dev/null; then
    print_info "Starting Minikube with ${MINIKUBE_CPUS} CPUs, ${MINIKUBE_MEMORY}MB RAM (6GB), ${MINIKUBE_DISK} disk..."
    minikube start \
        --cpus=$MINIKUBE_CPUS \
        --memory=$MINIKUBE_MEMORY \
        --disk-size=$MINIKUBE_DISK \
        --driver=docker

    print_success "Minikube cluster started"
else
    print_success "Minikube cluster is running"
fi

# Verify cluster
print_info "Verifying cluster..."
kubectl cluster-info
kubectl get nodes

# Step 3: Enable Addons
print_header "Step 3: Enabling Minikube Addons"

print_info "Enabling metrics-server..."
minikube addons enable metrics-server
print_success "metrics-server enabled"

print_info "Enabling ingress..."
minikube addons enable ingress
print_success "ingress enabled"

# Step 4: Set Up Python Environment
print_header "Step 4: Setting Up Python Environment"

if [ ! -d "venv" ]; then
    print_info "Creating virtual environment..."
    python3 -m venv venv
    print_success "Virtual environment created"
else
    print_warning "Virtual environment already exists"
fi

print_info "Installing Python dependencies..."
source venv/bin/activate
pip install --upgrade pip > /dev/null 2>&1
pip install kubernetes > /dev/null 2>&1
print_success "Python dependencies installed"

# Step 5: Install Prometheus
print_header "Step 5: Installing Prometheus Stack"

# Add Helm repository
print_info "Adding Prometheus Helm repository..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts > /dev/null 2>&1
helm repo update > /dev/null 2>&1
print_success "Helm repository added"

# Create namespace
if ! kubectl get namespace $NAMESPACE &> /dev/null; then
    print_info "Creating monitoring namespace..."
    kubectl create namespace $NAMESPACE
    print_success "Namespace created"
else
    print_warning "Namespace $NAMESPACE already exists"
fi

# Install Prometheus
if ! helm list -n $NAMESPACE | grep -q prometheus; then
    print_info "Installing Prometheus stack (this may take a few minutes)..."
    helm install prometheus prometheus-community/kube-prometheus-stack \
        --namespace $NAMESPACE \
        --set prometheus.prometheusSpec.retention=7d \
        --set prometheus.prometheusSpec.resources.requests.memory=512Mi \
        --set grafana.enabled=true \
        --set grafana.adminPassword=admin123 \
        --wait \
        --timeout 10m
    
    print_success "Prometheus stack installed"
else
    print_warning "Prometheus is already installed"
fi

# Step 6: Wait for Pods
print_header "Step 6: Waiting for Pods to be Ready"

print_info "Waiting for all pods in monitoring namespace to be ready..."
kubectl wait --for=condition=ready pod --all -n $NAMESPACE --timeout=300s

print_success "All pods are ready"

# Step 7: Verify Setup
print_header "Step 7: Verifying Setup"

print_info "Checking pods in monitoring namespace..."
kubectl get pods -n $NAMESPACE

print_info "Checking services in monitoring namespace..."
kubectl get svc -n $NAMESPACE

# Make scripts executable
print_info "Making scripts executable..."
chmod +x src/*.py scripts/*.py 2>/dev/null || true
print_success "Scripts are executable"

# Final Summary
print_header "SETUP COMPLETE!"

echo -e "${GREEN}✅ Minikube cluster is running${NC}"
echo -e "${GREEN}✅ Prometheus stack is installed${NC}"
echo -e "${GREEN}✅ Python environment is configured${NC}"
echo -e "${GREEN}✅ All pods are ready${NC}"

print_header "Next Steps"

echo "1. Run health check:"
echo -e "   ${BLUE}python3 scripts/check-health.py${NC}"
echo ""
echo "2. Get cluster information:"
echo -e "   ${BLUE}python3 src/cluster_info.py${NC}"
echo ""
echo "3. Monitor pod health:"
echo -e "   ${BLUE}python3 src/health_monitor.py${NC}"
echo ""
echo "4. Access Prometheus UI:"
echo -e "   ${BLUE}kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090${NC}"
echo -e "   Then open: ${BLUE}http://localhost:9090${NC}"
echo ""
echo "5. Access Grafana UI:"
echo -e "   ${BLUE}kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80${NC}"
echo -e "   Then open: ${BLUE}http://localhost:3000${NC}"
echo -e "   Username: ${BLUE}admin${NC} | Password: ${BLUE}admin123${NC}"
echo ""

print_success "Sprint 1 setup completed successfully!"

