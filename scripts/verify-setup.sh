#!/bin/bash

###############################################################################
# Verification Script for Sprint 1 Setup
#
# This script verifies that all components are properly installed and running
#
# Usage: ./scripts/verify-setup.sh
###############################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0

print_header() {
    echo -e "\n${BLUE}============================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================================${NC}\n"
}

print_test() {
    echo -e "${BLUE}🔍 Testing: $1${NC}"
}

print_pass() {
    echo -e "${GREEN}✅ PASS: $1${NC}\n"
    ((PASSED++))
}

print_fail() {
    echo -e "${RED}❌ FAIL: $1${NC}\n"
    ((FAILED++))
}

print_header "SPRINT 1 VERIFICATION"

# Test 1: Minikube Status
print_test "Minikube cluster status"
if minikube status | grep -q "Running"; then
    print_pass "Minikube is running"
else
    print_fail "Minikube is not running"
fi

# Test 2: Kubectl Connection
print_test "Kubectl connection to cluster"
if kubectl cluster-info &> /dev/null; then
    print_pass "kubectl can connect to cluster"
else
    print_fail "kubectl cannot connect to cluster"
fi

# Test 3: Nodes Ready
print_test "Node readiness"
if kubectl get nodes | grep -q "Ready"; then
    print_pass "All nodes are ready"
else
    print_fail "Nodes are not ready"
fi

# Test 4: Monitoring Namespace
print_test "Monitoring namespace exists"
if kubectl get namespace monitoring &> /dev/null; then
    print_pass "Monitoring namespace exists"
else
    print_fail "Monitoring namespace does not exist"
fi

# Test 5: Prometheus Pods
print_test "Prometheus pods running"
PROMETHEUS_PODS=$(kubectl get pods -n monitoring -l app.kubernetes.io/name=prometheus -o jsonpath='{.items[*].status.phase}')
if [[ "$PROMETHEUS_PODS" == *"Running"* ]]; then
    print_pass "Prometheus pods are running"
else
    print_fail "Prometheus pods are not running"
fi

# Test 6: Grafana Pods
print_test "Grafana pods running"
GRAFANA_PODS=$(kubectl get pods -n monitoring -l app.kubernetes.io/name=grafana -o jsonpath='{.items[*].status.phase}')
if [[ "$GRAFANA_PODS" == *"Running"* ]]; then
    print_pass "Grafana pods are running"
else
    print_fail "Grafana pods are not running"
fi

# Test 7: Python Environment
print_test "Python virtual environment"
if [ -d "venv" ]; then
    print_pass "Python virtual environment exists"
else
    print_fail "Python virtual environment does not exist"
fi

# Test 8: Python Kubernetes Client
print_test "Python Kubernetes client"
if source venv/bin/activate && python3 -c "from kubernetes import client, config" 2>/dev/null; then
    print_pass "Python Kubernetes client is installed"
else
    print_fail "Python Kubernetes client is not installed"
fi

# Test 9: Metrics Server
print_test "Metrics server addon"
if minikube addons list | grep "metrics-server" | grep -q "enabled"; then
    print_pass "Metrics server is enabled"
else
    print_fail "Metrics server is not enabled"
fi

# Test 10: Scripts Executable
print_test "Scripts are executable"
if [ -x "scripts/check-health.py" ] && [ -x "src/cluster_info.py" ]; then
    print_pass "Scripts are executable"
else
    print_fail "Scripts are not executable"
fi

# Summary
print_header "VERIFICATION SUMMARY"

TOTAL=$((PASSED + FAILED))
SUCCESS_RATE=$((PASSED * 100 / TOTAL))

echo -e "Total Tests: ${BLUE}$TOTAL${NC}"
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"
echo -e "Success Rate: ${BLUE}$SUCCESS_RATE%${NC}"

echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}============================================================${NC}"
    echo -e "${GREEN}✅ ALL TESTS PASSED - SETUP IS COMPLETE!${NC}"
    echo -e "${GREEN}============================================================${NC}"
    exit 0
else
    echo -e "${RED}============================================================${NC}"
    echo -e "${RED}❌ SOME TESTS FAILED - PLEASE CHECK THE SETUP${NC}"
    echo -e "${RED}============================================================${NC}"
    echo ""
    echo "Troubleshooting tips:"
    echo "1. Check TROUBLESHOOTING.md for common issues"
    echo "2. Run: kubectl get pods -A"
    echo "3. Run: minikube status"
    echo "4. Try: ./scripts/setup-minikube.sh"
    exit 1
fi

