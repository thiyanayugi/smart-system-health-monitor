#!/bin/bash

###############################################################################
# Load Generator Script for Smart System Health Monitor
# Purpose: Generate CPU, memory, and disk load for demonstration purposes
# Usage: ./load_generator.sh [duration_in_seconds]
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default duration (5 minutes)
DURATION=${1:-300}

# Cleanup function
cleanup() {
    echo -e "\n${YELLOW}Stopping load generation...${NC}"
    
    # Kill all background jobs
    jobs -p | xargs -r kill 2>/dev/null || true
    
    # Remove temporary files
    rm -f /tmp/load_test_* 2>/dev/null || true
    
    echo -e "${GREEN}Cleanup complete!${NC}"
    exit 0
}

# Set up trap for clean exit
trap cleanup SIGINT SIGTERM EXIT

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Smart System Health Monitor - Load Generator          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Duration:${NC} ${DURATION} seconds"
echo -e "${GREEN}Start time:${NC} $(date)"
echo ""

# Function to generate CPU load
generate_cpu_load() {
    local cores=$(nproc)
    local cpu_threads=$((cores / 2))  # Use half the cores to avoid complete freeze
    
    echo -e "${YELLOW}[CPU]${NC} Generating CPU load on ${cpu_threads} threads..."
    
    for i in $(seq 1 $cpu_threads); do
        # CPU-intensive calculation in background
        (
            end_time=$((SECONDS + DURATION))
            while [ $SECONDS -lt $end_time ]; do
                echo "scale=5000; a(1)*4" | bc -l > /dev/null 2>&1
            done
        ) &
    done
}

# Function to generate memory load
generate_memory_load() {
    echo -e "${YELLOW}[MEMORY]${NC} Generating gradual memory load..."
    
    (
        # Allocate memory gradually (100MB every 10 seconds)
        end_time=$((SECONDS + DURATION))
        counter=1
        
        while [ $SECONDS -lt $end_time ]; do
            # Allocate 100MB and write to it to ensure it's actually used
            dd if=/dev/zero of=/tmp/load_test_mem_${counter} bs=1M count=100 2>/dev/null &
            
            echo -e "${BLUE}  → Allocated ${counter}00 MB${NC}"
            counter=$((counter + 1))
            
            sleep 10
        done
    ) &
}

# Function to generate disk I/O load
generate_disk_load() {
    echo -e "${YELLOW}[DISK]${NC} Generating disk I/O load..."
    
    (
        end_time=$((SECONDS + DURATION))
        counter=1
        
        while [ $SECONDS -lt $end_time ]; do
            # Write and read operations
            dd if=/dev/zero of=/tmp/load_test_disk_${counter} bs=1M count=50 2>/dev/null
            dd if=/tmp/load_test_disk_${counter} of=/dev/null bs=1M 2>/dev/null
            rm -f /tmp/load_test_disk_${counter}
            
            counter=$((counter + 1))
            sleep 5
        done
    ) &
}

# Function to display progress
show_progress() {
    local elapsed=0
    
    while [ $elapsed -lt $DURATION ]; do
        sleep 10
        elapsed=$((elapsed + 10))
        
        local remaining=$((DURATION - elapsed))
        local progress=$((elapsed * 100 / DURATION))
        
        echo -e "${GREEN}[PROGRESS]${NC} ${progress}% complete | ${remaining}s remaining"
        
        # Show current system stats
        local cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
        local mem_usage=$(free | grep Mem | awk '{printf("%.1f"), $3/$2 * 100.0}')
        
        echo -e "  ${BLUE}CPU: ${cpu_usage}% | Memory: ${mem_usage}%${NC}"
    done
}

# Main execution
echo -e "${GREEN}Starting load generation...${NC}"
echo ""

# Start load generators
generate_cpu_load
sleep 2
generate_memory_load
sleep 2
generate_disk_load

echo ""
echo -e "${GREEN}All load generators started!${NC}"
echo -e "${YELLOW}Monitor the dashboard at: http://localhost:3000${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop early${NC}"
echo ""

# Show progress
show_progress

# Wait for completion
wait

echo ""
echo -e "${GREEN}Load generation complete!${NC}"
echo -e "${GREEN}End time:${NC} $(date)"
