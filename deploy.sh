#!/bin/bash

###############################################################################
# Hotel Management System - Deployment Script for Ubuntu Server
# This script automates the deployment process
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Hotel Management System - Deployment ===${NC}\n"

# Step 1: Check if Docker is installed
echo -e "${YELLOW}[1/8] Checking Docker installation...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed. Installing...${NC}"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo -e "${GREEN}✓ Docker installed${NC}"
else
    echo -e "${GREEN}✓ Docker already installed${NC}"
fi

# Step 2: Check if Docker Compose is installed
echo -e "\n${YELLOW}[2/8] Checking Docker Compose installation...${NC}"
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Docker Compose is not installed. Installing...${NC}"
    sudo apt update
    sudo apt install -y docker-compose
    echo -e "${GREEN}✓ Docker Compose installed${NC}"
else
    echo -e "${GREEN}✓ Docker Compose already installed${NC}"
fi

# Step 3: Stop existing containers (if any)
echo -e "\n${YELLOW}[3/8] Stopping existing containers...${NC}"
if [ -f "docker-compose.prod.yml" ]; then
    docker-compose -f docker-compose.prod.yml down 2>/dev/null || true
fi
echo -e "${GREEN}✓ Containers stopped${NC}"

# Step 4: Build and start containers
echo -e "\n${YELLOW}[4/8] Building and starting containers...${NC}"
docker-compose -f docker-compose.prod.yml up -d --build
echo -e "${GREEN}✓ Containers started${NC}"

# Step 5: Wait for MySQL to be ready
echo -e "\n${YELLOW}[5/8] Waiting for MySQL to be ready...${NC}"
sleep 10
until docker exec hotel-db mysql -uroot -pt0tFlyToDream -e "SELECT 1" &> /dev/null; do
    echo "Waiting for MySQL..."
    sleep 3
done
echo -e "${GREEN}✓ MySQL is ready${NC}"

# Step 6: Create database and import schema
echo -e "\n${YELLOW}[6/8] Setting up database...${NC}"
docker exec hotel-db mysql -uroot -pt0tFlyToDream -e "CREATE DATABASE IF NOT EXISTS hotel_management CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

if [ -f "src/database/schema.sql" ]; then
    docker exec -i hotel-db mysql -uroot -pt0tFlyToDream hotel_management < src/database/schema.sql
    echo -e "${GREEN}✓ Database schema imported${NC}"
fi

# Step 7: Set user passwords
echo -e "\n${YELLOW}[7/8] Setting up user accounts...${NC}"
docker exec hotel-db mysql -uroot -pt0tFlyToDream hotel_management << 'SQL'
UPDATE users SET password_hash = '$2y$10$kax1BzbSErfsaEoRS9o5cuDQPb4MyKzTbLlxmJDA5ge.LWfq4bWBa' WHERE username = 'admin';
UPDATE users SET password_hash = '$2y$10$ITP8utHBKobzU0m/c76iMOt9EPlgwrtrtsQfS8Q3i3V28YK3b8PM6' WHERE username IN ('reception', 'reception1');
UPDATE users SET password_hash = '$2y$10$rEIpC2oYrBiOrsyPhL7CIOueNvn1BPaSQcY7J8B8A0KGH4Mx4CRfy' WHERE username IN ('housekeeping', 'housekeeper1', 'housekeeper2');
SQL
echo -e "${GREEN}✓ User passwords configured${NC}"

# Step 8: Display status and URLs
echo -e "\n${YELLOW}[8/8] Checking deployment status...${NC}"
docker-compose -f docker-compose.prod.yml ps

echo -e "\n${GREEN}=== Deployment Complete! ===${NC}\n"
echo -e "Access your application at:"
echo -e "  ${GREEN}Web Application:${NC} http://$(hostname -I | awk '{print $1}')"
echo -e "  ${GREEN}phpMyAdmin:${NC}     http://$(hostname -I | awk '{print $1}'):8080"
echo -e "\n${GREEN}Login credentials:${NC}"
echo -e "  Admin:        admin / admin123"
echo -e "  Reception:    reception / rec123"
echo -e "  Housekeeping: housekeeping / hk123"
echo -e "\n${GREEN}Database credentials:${NC}"
echo -e "  User:     root"
echo -e "  Password: t0tFlyToDream"
echo -e "\n${YELLOW}Useful commands:${NC}"
echo -e "  View logs:    docker-compose -f docker-compose.prod.yml logs -f"
echo -e "  Stop:         docker-compose -f docker-compose.prod.yml down"
echo -e "  Restart:      docker-compose -f docker-compose.prod.yml restart"
echo ""
