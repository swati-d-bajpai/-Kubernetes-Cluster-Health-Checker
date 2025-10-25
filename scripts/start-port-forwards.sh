#!/bin/bash

# Script to start all port forwards for Kubernetes services
# This makes it easy to access Prometheus, Grafana, and AlertManager on localhost

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_header() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                                                                          ║${NC}"
    echo -e "${BLUE}║              STARTING PORT FORWARDS FOR KUBERNETES SERVICES              ║${NC}"
    echo -e "${BLUE}║                                                                          ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
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

# Check if kubectl is available
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed or not in PATH"
        exit 1
    fi
}

# Check if cluster is running
check_cluster() {
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Cannot connect to Kubernetes cluster"
        print_info "Make sure Minikube is running: minikube status"
        exit 1
    fi
}

# Check if monitoring namespace exists
check_namespace() {
    if ! kubectl get namespace monitoring &> /dev/null; then
        print_error "Monitoring namespace does not exist"
        print_info "Run the setup script first: ./scripts/setup-minikube.sh"
        exit 1
    fi
}

# Check if services are ready
check_services() {
    print_info "Checking if services are ready..."
    
    local services=("prometheus-kube-prometheus-prometheus" "prometheus-grafana" "prometheus-kube-prometheus-alertmanager")
    local all_ready=true
    
    for svc in "${services[@]}"; do
        if kubectl get svc -n monitoring "$svc" &> /dev/null; then
            print_success "Service $svc exists"
        else
            print_error "Service $svc not found"
            all_ready=false
        fi
    done
    
    if [ "$all_ready" = false ]; then
        print_error "Some services are not ready"
        print_info "Wait for all pods to be running: kubectl get pods -n monitoring"
        exit 1
    fi
}

# Kill existing port forwards
kill_existing_port_forwards() {
    print_info "Checking for existing port forwards..."
    
    if pgrep -f "kubectl port-forward.*monitoring" > /dev/null; then
        print_warning "Found existing port forwards. Stopping them..."
        pkill -f "kubectl port-forward.*monitoring" || true
        sleep 2
        print_success "Stopped existing port forwards"
    fi
}

# Start port forward in background
start_port_forward() {
    local service=$1
    local local_port=$2
    local remote_port=$3
    local name=$4
    
    print_info "Starting port forward for $name..."
    
    # Start port forward in background
    kubectl port-forward -n monitoring "svc/$service" "$local_port:$remote_port" > /dev/null 2>&1 &
    local pid=$!
    
    # Wait a moment and check if it's still running
    sleep 2
    
    if ps -p $pid > /dev/null; then
        print_success "$name is now accessible at http://localhost:$local_port (PID: $pid)"
        echo "$pid" >> /tmp/k8s-port-forwards.pid
        return 0
    else
        print_error "Failed to start port forward for $name"
        return 1
    fi
}

# Get Grafana password
get_grafana_password() {
    local password=$(kubectl get secret -n monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" 2>/dev/null | base64 --decode 2>/dev/null)
    if [ -n "$password" ]; then
        echo "$password"
    else
        echo "prom-operator"
    fi
}

# Main function
main() {
    print_header
    
    # Checks
    check_kubectl
    check_cluster
    check_namespace
    check_services
    
    # Kill existing port forwards
    kill_existing_port_forwards
    
    # Clear PID file
    rm -f /tmp/k8s-port-forwards.pid
    
    echo ""
    print_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_info "Starting Port Forwards"
    print_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Start port forwards
    start_port_forward "prometheus-kube-prometheus-prometheus" "9090" "9090" "Prometheus"
    start_port_forward "prometheus-grafana" "3000" "80" "Grafana"
    start_port_forward "prometheus-kube-prometheus-alertmanager" "9093" "9093" "AlertManager"
    
    echo ""
    print_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_success "All Port Forwards Started!"
    print_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Get Grafana password
    local grafana_password=$(get_grafana_password)
    
    # Print access information
    echo -e "${GREEN}🌐 Access URLs:${NC}"
    echo ""
    echo -e "  ${BLUE}📊 Prometheus:${NC}   http://localhost:9090"
    echo -e "     • Query metrics"
    echo -e "     • View targets: Status → Targets"
    echo -e "     • Try query: ${YELLOW}up${NC}"
    echo ""
    echo -e "  ${BLUE}📈 Grafana:${NC}      http://localhost:3000"
    echo -e "     • Username: ${YELLOW}admin${NC}"
    echo -e "     • Password: ${YELLOW}${grafana_password}${NC}"
    echo -e "     • View dashboards: Dashboards → Browse"
    echo ""
    echo -e "  ${BLUE}🔔 AlertManager:${NC} http://localhost:9093"
    echo -e "     • View alerts"
    echo -e "     • Manage silences"
    echo ""
    
    print_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    print_warning "Port forwards are running in the background"
    print_info "To stop all port forwards, run: ./scripts/stop-port-forwards.sh"
    print_info "Or press Ctrl+C and run: pkill -f 'kubectl port-forward'"
    echo ""
    
    print_info "PIDs saved to: /tmp/k8s-port-forwards.pid"
    echo ""
    
    # Keep script running
    print_info "Press Ctrl+C to stop all port forwards and exit"
    echo ""
    
    # Wait for Ctrl+C
    trap 'echo ""; print_info "Stopping port forwards..."; pkill -f "kubectl port-forward.*monitoring"; rm -f /tmp/k8s-port-forwards.pid; print_success "Port forwards stopped"; exit 0' INT
    
    # Keep running
    while true; do
        sleep 1
    done
}

# Run main function
main

