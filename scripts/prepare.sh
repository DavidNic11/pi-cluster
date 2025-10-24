#!/bin/bash

# Source the common logger
source "$(dirname "$0")/logger.sh"

# Setup error handling
setup_error_handling

# Script header
script_header "System Preparation" "Installing dependencies and configuring system for K3s"

run_with_log "Updating package lists" "sudo apt-get update -y"

run_with_log "Installing required dependencies (nfs-common, open-iscsi, util-linux)" \
    "sudo apt install -y nfs-common open-iscsi util-linux"

run_with_log "Modifying boot configuration to enable cgroups" \
    "sudo sed -i 's/\$/ cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory/' /boot/firmware/cmdline.txt"

log SUCCESS "All dependencies installed and configuration updated"
log WARNING "System will reboot to apply cgroup changes..."

countdown 5 "Rebooting"

log INFO "Rebooting system now..."
sudo reboot now

