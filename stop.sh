#!/bin/bash

###############################################################################
# Smart System Health Monitor - Stop Script
# Purpose: Gracefully stop all monitoring services
# Usage: ./stop.sh [--clean]
###############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Change to script directory
cd "$(dirname "$0")"

# Detect docker-compose command
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker-compose"
else
    DOCKER_COMPOSE_CMD="docker compose"
fi

echo -e "${BLUE}Stopping Smart System Health Monitor...${NC}"
echo ""

# Check if --clean flag is provided
if [ "$1" = "--clean" ]; then
    echo -e "${YELLOW}Stopping services and removing volumes (clean mode)...${NC}"
    $DOCKER_COMPOSE_CMD down -v
    echo -e "${GREEN}✓ Services stopped and data cleaned${NC}"
else
    echo -e "${YELLOW}Stopping services (data will be preserved)...${NC}"
    $DOCKER_COMPOSE_CMD down
    echo -e "${GREEN}✓ Services stopped${NC}"
    echo -e "${BLUE}Note: Data volumes are preserved. Use './stop.sh --clean' to remove all data.${NC}"
fi

echo ""
echo -e "${GREEN}Smart System Health Monitor stopped successfully!${NC}"
