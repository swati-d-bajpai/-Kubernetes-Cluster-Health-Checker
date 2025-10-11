#!/bin/bash

# Script to stop all port forwards

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

echo ""
print_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_info "Stopping All Port Forwards"
print_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if any port forwards are running
if pgrep -f "kubectl port-forward" > /dev/null; then
    print_info "Found running port forwards. Stopping them..."
    
    # Kill all kubectl port-forward processes
    pkill -f "kubectl port-forward" || true
    
    # Wait a moment
    sleep 1
    
    # Verify they're stopped
    if ! pgrep -f "kubectl port-forward" > /dev/null; then
        print_success "All port forwards stopped"
    else
        print_warning "Some port forwards may still be running"
        print_info "Try: pkill -9 -f 'kubectl port-forward'"
    fi
else
    print_info "No port forwards are currently running"
fi

# Clean up PID file
if [ -f /tmp/k8s-port-forwards.pid ]; then
    rm -f /tmp/k8s-port-forwards.pid
    print_success "Cleaned up PID file"
fi

echo ""
print_success "Done!"
echo ""

