#!/bin/bash

# Source the common logger
source "$(dirname "$0")/logger.sh"

# Setup error handling
setup_error_handling

# Script header
script_header "Storage Mount Creation" "Creating directory structure for K3s storage"

BASE_DIR="/mnt/k3s-storage"
DIRECTORIES=("etcd" "longhorn" "k3s")

run_with_log "Creating base storage directory: $BASE_DIR" \
    "sudo mkdir -p '$BASE_DIR'"

log INFO "Changing to storage directory..."
cd "$BASE_DIR"

log STEP "Creating subdirectories for K3s components..."
for dir in "${DIRECTORIES[@]}"; do
    run_with_log "Creating directory: $dir" \
        "sudo mkdir -p '$dir'"
done

run_with_log "Setting appropriate permissions" \
    "sudo chmod 755 '$BASE_DIR' && sudo chmod -R 755 '$BASE_DIR'/*"

log INFO "Verifying directory structure..."
for dir in "${DIRECTORIES[@]}"; do
    if [ -d "$BASE_DIR/$dir" ]; then
        log SUCCESS "✓ $BASE_DIR/$dir"
    else
        log ERROR "✗ $BASE_DIR/$dir - Directory not found"
        exit 1
    fi
done

log STEP "Final directory structure:"
log INFO "  $BASE_DIR/"
log INFO "  ├── etcd/      (for ETCD data)"
log INFO "  ├── longhorn/  (for Longhorn storage)"
log INFO "  └── k3s/       (for K3s data)"

script_footer "Storage Mount Creation"

