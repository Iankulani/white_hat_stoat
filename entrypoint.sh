#!/bin/bash
# WHITE-HAT-STOAT Entrypoint Script

set -e

echo "🦡 WHITE-HAT-STOAT Container Starting..."
echo "=============================================="

# Print environment info
echo "🌍 Environment: ${STOAT_ENVIRONMENT:-development}"
echo "📁 Config Directory: ${CONFIG_DIR:-/etc/white-hat-stoat}"
echo "📁 Log Directory: ${LOG_DIR:-/var/log/white-hat-stoat}"
echo "📁 Data Directory: ${DATA_DIR:-/var/lib/white-hat-stoat}"
echo "=============================================="

# Create directories if they don't exist
mkdir -p "${CONFIG_DIR:-/etc/white-hat-stoat}"
mkdir -p "${LOG_DIR:-/var/log/white-hat-stoat}"
mkdir -p "${DATA_DIR:-/var/lib/white-hat-stoat}"

# Set permissions
chmod -R 755 "${CONFIG_DIR:-/etc/white-hat-stoat}" 2>/dev/null || true
chmod -R 755 "${LOG_DIR:-/var/log/white-hat-stoat}" 2>/dev/null || true
chmod -R 755 "${DATA_DIR:-/var/lib/white-hat-stoat}" 2>/dev/null || true

# Initialize configuration if not exists
if [ ! -f "${CONFIG_DIR}/config.json" ]; then
    echo "📝 Creating default configuration..."
    cp -n /opt/white-hat-stoat/config/default.json "${CONFIG_DIR}/config.json" 2>/dev/null || true
fi

# Check for database
if [ ! -f "${DATA_DIR}/stoat.db" ]; then
    echo "🗄️  Initializing database..."
    python3 -c "from white_hat_stoat import DatabaseManager; DatabaseManager('${DATA_DIR}/stoat.db')" 2>/dev/null || true
fi

# Show available tools
echo "🔧 Available Tools:"
which nmap 2>/dev/null && echo "  ✅ nmap" || echo "  ❌ nmap"
which nikto 2>/dev/null && echo "  ✅ nikto" || echo "  ❌ nikto"
which whois 2>/dev/null && echo "  ✅ whois" || echo "  ❌ whois"
which traceroute 2>/dev/null && echo "  ✅ traceroute" || echo "  ❌ traceroute"

echo "=============================================="

# Start the application
if [ "$1" == "bash" ] || [ "$1" == "shell" ]; then
    exec /bin/bash
elif [ "$1" == "test" ]; then
    echo "🧪 Running tests..."
    exec python3 -m pytest tests/
elif [ "$1" == "help" ]; then
    echo "Available commands:"
    echo "  ./entrypoint.sh       - Start WHITE-HAT-STOAT"
    echo "  ./entrypoint.sh bash  - Open bash shell"
    echo "  ./entrypoint.sh test  - Run tests"
    echo "  ./entrypoint.sh help  - Show this help"
else
    # Start the main application
    echo "🚀 Starting WHITE-HAT-STOAT..."
    exec python3 /opt/white-hat-stoat/white_hat_stoat.py "$@"
fi