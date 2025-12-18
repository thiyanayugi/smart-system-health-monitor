#!/bin/bash

###############################################################################
# Smart System Health Monitor - Startup Script
# Purpose: One-command startup for the entire monitoring stack
# Usage: ./run.sh
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print banner
print_banner() {
    echo -e "${CYAN}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║     ███████╗███╗   ███╗ █████╗ ██████╗ ████████╗            ║
║     ██╔════╝████╗ ████║██╔══██╗██╔══██╗╚══██╔══╝            ║
║     ███████╗██╔████╔██║███████║██████╔╝   ██║               ║
║     ╚════██║██║╚██╔╝██║██╔══██║██╔══██╗   ██║               ║
║     ███████║██║ ╚═╝ ██║██║  ██║██║  ██║   ██║               ║
║     ╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝               ║
║                                                               ║
║          System Health Monitor with Predictive AI            ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Check prerequisites
check_prerequisites() {
    echo -e "${BLUE}[1/5]${NC} Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}✗ Docker is not installed!${NC}"
        echo -e "${YELLOW}Please install Docker: https://docs.docker.com/get-docker/${NC}"
        exit 1
    fi
    echo -e "${GREEN}  ✓ Docker found: $(docker --version)${NC}"
    
    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        echo -e "${RED}✗ Docker Compose is not installed!${NC}"
        echo -e "${YELLOW}Please install Docker Compose: https://docs.docker.com/compose/install/${NC}"
        exit 1
    fi
    
    if command -v docker-compose &> /dev/null; then
        DOCKER_COMPOSE_CMD="docker-compose"
        echo -e "${GREEN}  ✓ Docker Compose found: $(docker-compose --version)${NC}"
    else
        DOCKER_COMPOSE_CMD="docker compose"
        echo -e "${GREEN}  ✓ Docker Compose found: $(docker compose version)${NC}"
    fi
    
    # Check if Docker daemon is running
    if ! docker info &> /dev/null; then
        echo -e "${RED}✗ Docker daemon is not running!${NC}"
        echo -e "${YELLOW}Please start Docker and try again${NC}"
        exit 1
    fi
    echo -e "${GREEN}  ✓ Docker daemon is running${NC}"
    
    echo ""
}

# Validate configuration files
validate_configs() {
    echo -e "${BLUE}[2/5]${NC} Validating configuration files..."
    
    local config_files=(
        "prometheus/prometheus.yml"
        "prometheus/alert_rules.yml"
        "grafana/provisioning/datasources/datasources.yml"
        "grafana/provisioning/dashboards/dashboards.yml"
        "grafana/dashboards/system_health_dashboard.json"
        "docker-compose.yml"
    )
    
    for file in "${config_files[@]}"; do
        if [ ! -f "$file" ]; then
            echo -e "${RED}✗ Missing configuration file: $file${NC}"
            exit 1
        fi
        echo -e "${GREEN}  ✓ $file${NC}"
    done
    
    echo ""
}

# Create .env file if it doesn't exist
create_env_file() {
    if [ ! -f .env ]; then
        echo -e "${YELLOW}Creating .env file with default credentials...${NC}"
        cat > .env << EOF
# Grafana Configuration
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=admin

# Note: Change these credentials in production!
EOF
        echo -e "${GREEN}  ✓ .env file created${NC}"
    fi
}

# Start services
start_services() {
    echo -e "${BLUE}[3/5]${NC} Starting monitoring stack..."
    echo ""
    
    # Pull latest images
    echo -e "${YELLOW}Pulling Docker images...${NC}"
    $DOCKER_COMPOSE_CMD pull
    echo ""
    
    # Start services
    echo -e "${YELLOW}Starting services...${NC}"
    $DOCKER_COMPOSE_CMD up -d
    echo ""
    
    echo -e "${GREEN}  ✓ Services started successfully!${NC}"
    echo ""
}

# Wait for services to be ready
wait_for_services() {
    echo -e "${BLUE}[4/5]${NC} Waiting for services to be ready..."
    
    # Wait for Prometheus
    echo -e "${YELLOW}  → Waiting for Prometheus...${NC}"
    local prometheus_ready=false
    for i in {1..30}; do
        if curl -s http://localhost:9090/-/ready > /dev/null 2>&1; then
            prometheus_ready=true
            break
        fi
        sleep 2
    done
    
    if [ "$prometheus_ready" = true ]; then
        echo -e "${GREEN}  ✓ Prometheus is ready${NC}"
    else
        echo -e "${YELLOW}  ⚠ Prometheus may still be starting...${NC}"
    fi
    
    # Wait for Node Exporter
    echo -e "${YELLOW}  → Waiting for Node Exporter...${NC}"
    local node_exporter_ready=false
    for i in {1..30}; do
        if curl -s http://localhost:9100/metrics > /dev/null 2>&1; then
            node_exporter_ready=true
            break
        fi
        sleep 2
    done
    
    if [ "$node_exporter_ready" = true ]; then
        echo -e "${GREEN}  ✓ Node Exporter is ready${NC}"
    else
        echo -e "${YELLOW}  ⚠ Node Exporter may still be starting...${NC}"
    fi
    
    # Wait for Grafana
    echo -e "${YELLOW}  → Waiting for Grafana...${NC}"
    local grafana_ready=false
    for i in {1..30}; do
        if curl -s http://localhost:3000/api/health > /dev/null 2>&1; then
            grafana_ready=true
            break
        fi
        sleep 2
    done
    
    if [ "$grafana_ready" = true ]; then
        echo -e "${GREEN}  ✓ Grafana is ready${NC}"
    else
        echo -e "${YELLOW}  ⚠ Grafana may still be starting...${NC}"
    fi
    
    echo ""
}

# Display access information
show_access_info() {
    echo -e "${BLUE}[5/5]${NC} Setup complete!"
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    ACCESS INFORMATION                         ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}📊 Grafana Dashboard:${NC}"
    echo -e "   ${YELLOW}URL:${NC}      http://localhost:3000"
    echo -e "   ${YELLOW}Username:${NC} admin"
    echo -e "   ${YELLOW}Password:${NC} admin"
    echo -e "   ${YELLOW}Dashboard:${NC} Smart System Health Monitor"
    echo ""
    echo -e "${CYAN}📈 Prometheus:${NC}"
    echo -e "   ${YELLOW}URL:${NC}      http://localhost:9090"
    echo ""
    echo -e "${CYAN}🖥️  Node Exporter:${NC}"
    echo -e "   ${YELLOW}URL:${NC}      http://localhost:9100/metrics"
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    QUICK START GUIDE                          ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}1.${NC} Open Grafana: ${CYAN}http://localhost:3000${NC}"
    echo -e "${YELLOW}2.${NC} Login with admin/admin (change password when prompted)"
    echo -e "${YELLOW}3.${NC} Navigate to 'Dashboards' → 'Smart System Health Monitor'"
    echo -e "${YELLOW}4.${NC} To test alerts, run: ${CYAN}./scripts/load_generator.sh${NC}"
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    USEFUL COMMANDS                            ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}View logs:${NC}           $DOCKER_COMPOSE_CMD logs -f"
    echo -e "${YELLOW}Stop services:${NC}       ./stop.sh"
    echo -e "${YELLOW}Restart services:${NC}    $DOCKER_COMPOSE_CMD restart"
    echo -e "${YELLOW}Generate load:${NC}       ./scripts/load_generator.sh [duration]"
    echo ""
}

# Main execution
main() {
    clear
    print_banner
    
    # Change to script directory
    cd "$(dirname "$0")"
    
    check_prerequisites
    validate_configs
    create_env_file
    start_services
    wait_for_services
    show_access_info
    
    echo -e "${CYAN}Press Ctrl+C to view logs, or run '${DOCKER_COMPOSE_CMD} logs -f' in another terminal${NC}"
    echo ""
    
    # Follow logs
    $DOCKER_COMPOSE_CMD logs -f
}

# Run main function
main
