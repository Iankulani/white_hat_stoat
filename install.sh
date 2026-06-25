#!/bin/bash
# WHITE-HAT-STOAT Linux Installation Script
# Version: 1.0.0

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

echo -e "${PURPLE}=============================================${NC}"
echo -e "${WHITE}🦡 WHITE-HAT-STOAT - Linux Installation${NC}"
echo -e "${PURPLE}=============================================${NC}"
echo

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${YELLOW}⚠️  This installer requires root privileges.${NC}"
    echo -e "${YELLOW}Please run with sudo.${NC}"
    exit 1
fi

# Installation directories
INSTALL_DIR="/opt/white-hat-stoat"
DATA_DIR="/var/lib/white-hat-stoat"
LOG_DIR="/var/log/white-hat-stoat"
CONFIG_DIR="/etc/white-hat-stoat"
BIN_DIR="/usr/local/bin"

echo -e "${CYAN}📁 Installation Directory: ${INSTALL_DIR}${NC}"
echo -e "${CYAN}📁 Data Directory: ${DATA_DIR}${NC}"
echo -e "${CYAN}📁 Log Directory: ${LOG_DIR}${NC}"
echo -e "${CYAN}📁 Config Directory: ${CONFIG_DIR}${NC}"
echo

# Create directories
echo -e "${BLUE}Creating directories...${NC}"
mkdir -p "${INSTALL_DIR}" "${DATA_DIR}" "${LOG_DIR}" "${CONFIG_DIR}"

# Set permissions
chmod 755 "${INSTALL_DIR}" "${DATA_DIR}" "${LOG_DIR}" "${CONFIG_DIR}"

# Check Python installation
echo -e "${BLUE}🔍 Checking Python...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python3 not found.${NC}"
    echo -e "${YELLOW}Installing Python...${NC}"
    apt-get update && apt-get install -y python3 python3-pip python3-dev
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
echo -e "${GREEN}✅ Python ${PYTHON_VERSION} found${NC}"

# Install system dependencies
echo -e "${BLUE}📦 Installing system dependencies...${NC}"
apt-get update && apt-get install -y \
    wget curl git vim nano \
    net-tools iputils-ping traceroute dnsutils whois \
    nmap nikto \
    build-essential libssl-dev libffi-dev \
    netcat tcpdump wireshark \
    sqlite3 postgresql-client \
    jq xmlstarlet \
    openssh-client openssh-server sshpass \
    wkhtmltopdf

# Upgrade pip
echo -e "${BLUE}📦 Upgrading pip...${NC}"
python3 -m pip install --upgrade pip setuptools wheel

# Install Python dependencies
echo -e "${BLUE}📦 Installing Python dependencies...${NC}"
python3 -m pip install -r requirements.txt

if [ $? -ne 0 ]; then
    echo -e "${YELLOW}⚠️  Some dependencies failed to install.${NC}"
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Install dev dependencies (optional)
read -p "Install development dependencies? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    python3 -m pip install -r requirements-dev.txt
fi

# Install extra dependencies (optional)
read -p "Install extra features (ML, Cloud, etc.)? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    python3 -m pip install -r requirements-extra.txt
fi

# Copy application files
echo -e "${BLUE}📋 Copying application files...${NC}"
rsync -av --exclude='.git' --exclude='.venv' --exclude='__pycache__' ./ "${INSTALL_DIR}/"

# Create symlinks
echo -e "${BLUE}🔗 Creating symlinks...${NC}"
ln -sf "${INSTALL_DIR}/white_hat_stoat.py" "${BIN_DIR}/white-hat-stoat"
chmod +x "${BIN_DIR}/white-hat-stoat"

# Create environment variables
echo -e "${BLUE}📝 Setting environment variables...${NC}"
cat > /etc/profile.d/stoat.sh << EOF
export STOAT_HOME="${INSTALL_DIR}"
export STOAT_DATA="${DATA_DIR}"
export STOAT_LOG="${LOG_DIR}"
export STOAT_CONFIG="${CONFIG_DIR}"
export PATH="\$PATH:${INSTALL_DIR}"
EOF

chmod 644 /etc/profile.d/stoat.sh

# Create sample configuration
echo -e "${BLUE}📝 Creating sample configuration...${NC}"
if [ ! -f "${CONFIG_DIR}/config.json" ]; then
    cp "${INSTALL_DIR}/config/default.json" "${CONFIG_DIR}/config.json" 2>/dev/null || true
fi

# Setup firewall
echo -e "${BLUE}🔒 Configuring firewall...${NC}"
if command -v ufw &> /dev/null; then
    ufw allow 5000/tcp  # Web Dashboard
    ufw allow 5555/tcp  # Callback Server
    ufw allow 4444/tcp  # Keylogger Server
    ufw allow 8080/tcp  # Phishing Server
    echo -e "${GREEN}✅ Firewall rules added${NC}"
fi

# Setup systemd service
echo -e "${BLUE}📝 Creating systemd service...${NC}"
cat > /etc/systemd/system/white-hat-stoat.service << EOF
[Unit]
Description=WHITE-HAT-STOAT Cybersecurity Platform
Documentation=https://github.com/white-hat-stoat
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=${INSTALL_DIR}
ExecStart=/usr/bin/python3 ${INSTALL_DIR}/white_hat_stoat.py
Restart=on-failure
RestartSec=10
Environment="STOAT_HOME=${INSTALL_DIR}"
Environment="STOAT_DATA=${DATA_DIR}"
Environment="STOAT_LOG=${LOG_DIR}"
Environment="STOAT_CONFIG=${CONFIG_DIR}"
StandardOutput=append:${LOG_DIR}/stoat.log
StandardError=append:${LOG_DIR}/stoat-error.log

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
systemctl daemon-reload
systemctl enable white-hat-stoat.service

echo
echo -e "${PURPLE}=============================================${NC}"
echo -e "${GREEN}✅ Installation Complete!${NC}"
echo -e "${PURPLE}=============================================${NC}"
echo
echo -e "${WHITE}🦡 WHITE-HAT-STOAT has been installed.${NC}"
echo
echo -e "${CYAN}📁 Installation: ${INSTALL_DIR}${NC}"
echo -e "${CYAN}📁 Data: ${DATA_DIR}${NC}"
echo -e "${CYAN}📁 Logs: ${LOG_DIR}${NC}"
echo -e "${CYAN}📁 Config: ${CONFIG_DIR}${NC}"
echo
echo -e "${WHITE}📌 To run:${NC}"
echo -e "  ${CYAN}sudo systemctl start white-hat-stoat${NC}"
echo -e "  ${CYAN}white-hat-stoat${NC}"
echo
echo -e "${WHITE}📌 To stop:${NC}"
echo -e "  ${CYAN}sudo systemctl stop white-hat-stoat${NC}"
echo
echo -e "${WHITE}📌 To view logs:${NC}"
echo -e "  ${CYAN}sudo journalctl -u white-hat-stoat -f${NC}"
echo
echo -e "${WHITE}💡 Type 'help' in the console for available commands${NC}"
echo
echo -e "${YELLOW}⚠️  Note: Some features require additional configuration.${NC}"
echo -e "${YELLOW}   Edit ${CONFIG_DIR}/config.json to customize.${NC}"
echo