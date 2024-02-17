#!/bin/bash

# This script installs Frappe Bench on a fresh Ubuntu server.
# To use this script:
    # 1. Download the file or make sure the file is already in the directory
    # 2. make the script executable by: chmod +x install.sh
    # 3. Run the script by: ./install.sh

# Define colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Update and upgrade packages
echo -e "${YELLOW}Updating and upgrading packages...${NC}"
sudo apt-get update -y
sudo apt-get upgrade -y
