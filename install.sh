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

# Step 2: Install required packages
echo -e "${YELLOW}Installing required packages...${NC}"
sudo apt-get install -y \
    git \
    python3-dev python3.10-dev python3-setuptools python3-pip python3-distutils \
    python3.10-venv \
    redis-server \
    xvfb libfontconfig wkhtmltopdf \
    libmysqlclient-dev \
    curl

# Step 3: Install mariadb
# Check if there is a need to install mariadb, or it is already installed
if ! mariadb --version; then
    echo -e "${YELLOW}Installing MariaDB...${NC}"
    sudo apt-get install -y \
    software-properties-common \
    mariadb-server mariadb-client

    # Configure MySQL server
    echo -e "${YELLOW}Configuring MySQL server...${NC}"
    sudo mysql_secure_installation

    # Check if configuration needs to be appended to my.cnf
    if ! grep -qxF '[mysqld]' /etc/mysql/my.cnf; then
        echo -e "[mysqld]\ncharacter-set-client-handshake = FALSE\ncharacter-set-server = utf8mb4\ncollation-server = utf8mb4_unicode_ci" | sudo tee -a /etc/mysql/my.cnf
    fi

    if ! grep -qxF '[mysql]' /etc/mysql/my.cnf; then
        echo -e "\n[mysql]\ndefault-character-set = utf8mb4" | sudo tee -a /etc/mysql/my.cnf
    fi
else
    echo -e "${GREEN}MariaDB is already installed...${NC}"
fi

# Restart MySQL service
sudo service mysql restart

# Step 4: Install Node.js, NPM, and Yarn
echo -e "${YELLOW}Installing Node.js, NPM, and Yarn...${NC}"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
source ~/.bashrc
nvm install node
sudo apt-get install -y npm
sudo npm install -g yarn

# Step 5: Install Frappe Bench
echo -e "${YELLOW}Installing Frappe Bench...${NC}"
sudo pip3 install frappe-bench

# Prompt user for Frappe version
read -p "Enter the Frappe version (e.g., version-15): " frappe_version

# Prompt user for Frappe Bench directory name
read -p "Enter The Directory name for frappe bench: " bench_dir

# Initialize Frappe Bench
echo -e "${YELLOW}Initializing Frappe Bench...${NC}"
if [[ -n "$frappe_version" ]]; then
    bench init --frappe-branch $frappe_version $bench_dir
else
    bench init $bench_dir
fi

# Step 7: Change user directory permissions
echo -e "${YELLOW}Changing user directory permissions...${NC}"
read -p "Enter the frappe user: " frappe_user

# Change user directory permissions
chmod -R o+rx /home/$frappe_user/

# Change to the bench directory
cd $bench_dir

# propmt user to choose either development or production
read -p "Is this a production bench? (Y/N): " bench_type

# Step 8: setup production bench
# If the user chooses production bench, then run the following commands
if [[ $bench_type == "Y" || $bench_type == "y" ]]; then
    echo -e "${YELLOW}Setting up production...${NC}"
    sudo bench setup production $frappe_user

    # Set up multitenant
    echo -e "${YELLOW}Setting up multitenant...${NC}"
    bench config dns_multitenant on

    # Set up nginx
    echo -e "${YELLOW}Setting up nginx...${NC}"
    bench setup nginx
    sudo service nginx reload
fi
