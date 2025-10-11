#!/bin/bash

# Script to configure Prometheus alerts and Grafana dashboards

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
    echo -e "${BLUE}║         CONFIGURE PROMETHEUS ALERTS & GRAFANA DASHBOARDS                ║${NC}"
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

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed"
        exit 1
    fi
    
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Cannot connect to Kubernetes cluster"
        exit 1
    fi
    
    if ! kubectl get namespace monitoring &> /dev/null; then
        print_error "Monitoring namespace does not exist"
        print_info "Run ./scripts/setup-minikube.sh first"
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Apply Prometheus alerts
apply_prometheus_alerts() {
    print_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_info "Configuring Prometheus Alerts"
    print_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Apply custom alerts ConfigMap
    print_info "Applying custom alert rules..."
    kubectl apply -f ../config/prometheus-alerts.yaml
    
    print_success "Prometheus alerts configured"
    echo ""
    
    # Show configured alerts
    print_info "Configured alert groups:"
    echo "  • kubernetes_cluster_alerts (Node, Pod, Deployment alerts)"
    echo "  • prometheus_alerts (Prometheus self-monitoring)"
    echo "  • grafana_alerts (Grafana monitoring)"
    echo ""
}

# Configure Grafana datasource
configure_grafana_datasource() {
    print_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_info "Configuring Grafana Datasource"
    print_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    print_info "Prometheus datasource is pre-configured by kube-prometheus-stack"
    print_success "Grafana datasource ready"
    echo ""
}

# Import Grafana dashboards
import_grafana_dashboards() {
    print_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_info "Importing Grafana Dashboards"
    print_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    print_info "Creating ConfigMaps for custom dashboards..."

    # Dashboard 1: Cluster Overview
    kubectl create configmap grafana-dashboard-cluster-overview \
        --from-file=../config/grafana-dashboard-cluster-overview.json \
        -n monitoring \
        --dry-run=client -o yaml | kubectl apply -f -

    kubectl label configmap grafana-dashboard-cluster-overview \
        grafana_dashboard=1 \
        -n monitoring \
        --overwrite

    print_success "Cluster Overview dashboard imported"

    # Dashboard 2: Resource Monitoring
    kubectl create configmap grafana-dashboard-resource-monitoring \
        --from-file=../config/grafana-dashboard-resource-monitoring.json \
        -n monitoring \
        --dry-run=client -o yaml | kubectl apply -f -

    kubectl label configmap grafana-dashboard-resource-monitoring \
        grafana_dashboard=1 \
        -n monitoring \
        --overwrite

    print_success "Resource Monitoring dashboard imported"

    # Dashboard 3: Pod Resources
    kubectl create configmap grafana-dashboard-pod-resources \
        --from-file=../config/grafana-dashboard-pod-resources.json \
        -n monitoring \
        --dry-run=client -o yaml | kubectl apply -f -

    kubectl label configmap grafana-dashboard-pod-resources \
        grafana_dashboard=1 \
        -n monitoring \
        --overwrite

    print_success "Pod Resources dashboard imported"

    # Dashboard 4: Namespace Resources
    kubectl create configmap grafana-dashboard-namespace-resources \
        --from-file=../config/grafana-dashboard-namespace-resources.json \
        -n monitoring \
        --dry-run=client -o yaml | kubectl apply -f -

    kubectl label configmap grafana-dashboard-namespace-resources \
        grafana_dashboard=1 \
        -n monitoring \
        --overwrite

    print_success "Namespace Resources dashboard imported"

    echo ""

    print_info "Available custom dashboards:"
    echo "  • Kubernetes Cluster Overview"
    echo "  • Kubernetes Resource Monitoring - CPU & Memory"
    echo "  • Pod Resource Details - CPU & Memory"
    echo "  • Namespace Resource Monitoring"
    echo ""

    print_info "Pre-installed dashboards:"
    echo "  • Kubernetes / Compute Resources / Cluster"
    echo "  • Kubernetes / Compute Resources / Namespace"
    echo "  • Node Exporter / Nodes"
    echo ""
}

# Restart Prometheus to load new alerts
restart_prometheus() {
    print_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_info "Reloading Prometheus Configuration"
    print_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    print_info "Triggering Prometheus configuration reload..."
    
    # Get Prometheus pod name
    PROM_POD=$(kubectl get pods -n monitoring -l app.kubernetes.io/name=prometheus -o jsonpath='{.items[0].metadata.name}')
    
    if [ -n "$PROM_POD" ]; then
        # Reload Prometheus config
        kubectl exec -n monitoring "$PROM_POD" -c prometheus -- kill -HUP 1
        print_success "Prometheus configuration reloaded"
    else
        print_warning "Could not find Prometheus pod, configuration will reload automatically"
    fi
    
    echo ""
}

# Restart Grafana to load new dashboards
restart_grafana() {
    print_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_info "Restarting Grafana"
    print_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    print_info "Restarting Grafana to load new dashboards..."
    kubectl rollout restart deployment prometheus-grafana -n monitoring
    
    print_info "Waiting for Grafana to be ready..."
    kubectl rollout status deployment prometheus-grafana -n monitoring --timeout=120s
    
    print_success "Grafana restarted successfully"
    echo ""
}

# Get access information
show_access_info() {
    print_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_success "Configuration Complete!"
    print_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Get Grafana password
    GRAFANA_PASSWORD=$(kubectl get secret -n monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" 2>/dev/null | base64 --decode 2>/dev/null || echo "prom-operator")
    
    echo -e "${GREEN}🎉 Prometheus & Grafana are now configured!${NC}"
    echo ""
    echo -e "${BLUE}📊 Access Prometheus:${NC}"
    echo "   1. Start port forward:"
    echo "      kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090"
    echo "   2. Open: http://localhost:9090"
    echo "   3. Go to: Status → Rules (to see alerts)"
    echo "   4. Go to: Alerts (to see active alerts)"
    echo ""
    echo -e "${BLUE}📈 Access Grafana:${NC}"
    echo "   1. Start port forward:"
    echo "      kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
    echo "   2. Open: http://localhost:3000"
    echo "   3. Login:"
    echo "      Username: ${YELLOW}admin${NC}"
    echo "      Password: ${YELLOW}${GRAFANA_PASSWORD}${NC}"
    echo "   4. Go to: Dashboards → Browse"
    echo ""
    echo -e "${BLUE}🔔 Access AlertManager:${NC}"
    echo "   1. Start port forward:"
    echo "      kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-alertmanager 9093:9093"
    echo "   2. Open: http://localhost:9093"
    echo ""
    echo -e "${BLUE}⚡ Quick Start:${NC}"
    echo "   Run: ${YELLOW}./scripts/start-port-forwards.sh${NC}"
    echo "   This will start all port forwards automatically!"
    echo ""
    
    print_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    print_info "📋 Configured Alerts:"
    echo "   • NodeDown - Critical when node is down"
    echo "   • NodeHighCPU - Warning when CPU > 80%"
    echo "   • NodeHighMemory - Warning when Memory > 85%"
    echo "   • PodCrashLooping - Critical when pod restarts frequently"
    echo "   • PodNotReady - Warning when pod not ready > 10min"
    echo "   • PrometheusDown - Critical when Prometheus is down"
    echo "   • And many more..."
    echo ""
    
    print_info "📊 Available Dashboards:"
    echo ""
    echo "   Custom Dashboards:"
    echo "   • Kubernetes Cluster Overview"
    echo "   • Kubernetes Resource Monitoring - CPU & Memory"
    echo "   • Pod Resource Details - CPU & Memory"
    echo "   • Namespace Resource Monitoring"
    echo ""
    echo "   Pre-installed Dashboards:"
    echo "   • Kubernetes / Compute Resources / Cluster"
    echo "   • Kubernetes / Compute Resources / Namespace"
    echo "   • Node Exporter / Nodes"
    echo ""
}

# Main function
main() {
    print_header
    
    check_prerequisites
    echo ""
    
    apply_prometheus_alerts
    configure_grafana_datasource
    import_grafana_dashboards
    restart_prometheus
    restart_grafana
    
    show_access_info
}

# Run main function
main

