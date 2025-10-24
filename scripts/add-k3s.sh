#!/bin/bash

# Source the common logger
source "$(dirname "$0")/logger.sh"

# Setup error handling
setup_error_handling

# Script header
script_header "K3s Installation" "Installing and configuring K3s server with cluster initialization"

log STEP "Configuration details:"
log INFO "  - Data directory: /mnt/k3s-storage/k3s"
log INFO "  - ETCD data directory: /mnt/k3s-storage/etcd/db"
log INFO "  - ETCD WAL directory: /mnt/k3s-storage/etcd/wal"
log INFO "  - Disabled services: servicelb, cloud-controller, local-storage"

run_with_log "Downloading and installing K3s server" \
    "curl -sfL https://get.k3s.io | sh -s - server \
    --cluster-init \
    --data-dir /mnt/k3s-storage/k3s \
    --etcd-arg data-dir=/mnt/k3s-storage/etcd/db \
    --etcd-arg wal-dir=/mnt/k3s-storage/etcd/wal \
    --write-kubeconfig-mode 644 \
    --disable servicelb \
    --disable-cloud-controller \
    --disable local-storage"

check_service "k3s" 30

log INFO "Verifying kubectl access..."
if sudo kubectl get nodes > /dev/null 2>&1; then
    log SUCCESS "K3s cluster is ready and accessible"
    sudo kubectl get nodes
else
    log WARNING "Kubectl access verification failed, but K3s may still be initializing"
fi

log INFO "Kubeconfig is available at /etc/rancher/k3s/k3s.yaml"

script_footer "K3s Installation" 