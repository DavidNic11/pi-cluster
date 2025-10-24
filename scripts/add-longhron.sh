#!/bin/bash

# Source the common logger
source "$(dirname "$0")/logger.sh"

# Setup error handling
setup_error_handling

# Script header
script_header "Longhorn Installation" "Installing distributed storage system for Kubernetes"

run_with_log "Installing required dependencies for Longhorn" \
    "sudo apt install -y nfs-common open-iscsi util-linux"

run_with_log "Modifying boot configuration to enable cgroups" \
    "sudo sed -i 's/\$/ cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory/' /boot/firmware/cmdline.txt"

check_command "kubectl" "K3s"

log INFO "Checking cluster connectivity..."
if ! kubectl cluster-info &> /dev/null; then
    log ERROR "Cannot connect to Kubernetes cluster. Please ensure K3s is running."
    exit 1
fi
log SUCCESS "Cluster connectivity verified"

run_with_log "Deploying Longhorn v1.8.1" \
    "kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.8.1/deploy/longhorn.yaml"

log INFO "Waiting for Longhorn components to be ready..."
log INFO "This may take several minutes..."

# Wait for longhorn-system namespace to be created
log INFO "Waiting for longhorn-system namespace..."
while ! kubectl get namespace longhorn-system &> /dev/null; do
    sleep 5
done
log SUCCESS "Longhorn namespace created"

# Wait for deployments to be ready
log INFO "Waiting for Longhorn deployments to be ready (timeout: 5 minutes)..."
if kubectl wait --for=condition=available --timeout=300s deployment -n longhorn-system --all; then
    log SUCCESS "All Longhorn deployments are ready"
else
    log WARNING "Some deployments may still be starting up"
fi

log STEP "Access Longhorn UI:"
log INFO "kubectl port-forward -n longhorn-system svc/longhorn-frontend 8080:80"
log INFO "Then visit: http://localhost:8080"

script_footer "Longhorn Installation"