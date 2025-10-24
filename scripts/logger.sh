#!/bin/bash

# Common logging library for Pi cluster scripts
# Source this file in other scripts with: source "$(dirname "$0")/logger.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging function
log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        "INFO")
            echo -e "${BLUE}[INFO]${NC} ${timestamp} - $message"
            ;;
        "SUCCESS")
            echo -e "${GREEN}[SUCCESS]${NC} ${timestamp} - $message"
            ;;
        "WARNING")
            echo -e "${YELLOW}[WARNING]${NC} ${timestamp} - $message"
            ;;
        "ERROR")
            echo -e "${RED}[ERROR]${NC} ${timestamp} - $message"
            ;;
        "DEBUG")
            echo -e "${PURPLE}[DEBUG]${NC} ${timestamp} - $message"
            ;;
        "STEP")
            echo -e "${CYAN}[STEP]${NC} ${timestamp} - $message"
            ;;
    esac
}

# Progress indicator with spinner
show_progress() {
    local pid=$1
    local message=$2
    local spin='-\|/'
    local i=0
    
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %4 ))
        printf "\r${BLUE}[INFO]${NC} ${message} ${spin:$i:1}"
        sleep 0.1
    done
    printf "\r"
}

# Error handling setup
setup_error_handling() {
    set -e
    trap 'log ERROR "Script failed at line $LINENO in function ${FUNCNAME[1]:-main}"' ERR
}

# Script header with banner
script_header() {
    local script_name=$1
    local description=$2
    
    echo -e "${CYAN}================================================${NC}"
    echo -e "${CYAN}  Pi Cluster Setup - ${script_name}${NC}"
    echo -e "${CYAN}  ${description}${NC}"
    echo -e "${CYAN}================================================${NC}"
    echo
}

# Script footer
script_footer() {
    local script_name=$1
    echo
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN}  ${script_name} completed successfully!${NC}"
    echo -e "${GREEN}================================================${NC}"
}

# Countdown function
countdown() {
    local seconds=$1
    local message=${2:-"Continuing"}
    
    for i in $(seq $seconds -1 1); do
        printf "\r${YELLOW}${message} in ${i} seconds... ${NC}"
        sleep 1
    done
    echo
}

# Check if command exists
check_command() {
    local cmd=$1
    local package=${2:-$cmd}
    
    if ! command -v "$cmd" &> /dev/null; then
        log ERROR "$cmd is not available. Please install $package first."
        return 1
    fi
    return 0
}

# Verify service status
check_service() {
    local service=$1
    local timeout=${2:-30}
    local count=0
    
    log INFO "Checking $service service status..."
    
    while [ $count -lt $timeout ]; do
        if sudo systemctl is-active --quiet "$service"; then
            log SUCCESS "$service service is running"
            return 0
        fi
        
        if [ $count -eq 0 ]; then
            log INFO "Waiting for $service service to start..."
        fi
        
        sleep 1
        count=$((count + 1))
    done
    
    log ERROR "$service service failed to start within ${timeout} seconds"
    return 1
}

# Run command with logging
run_with_log() {
    local description=$1
    shift
    local cmd="$@"
    
    log INFO "$description"
    if eval "$cmd"; then
        log SUCCESS "$description completed"
        return 0
    else
        log ERROR "$description failed"
        return 1
    fi
}
