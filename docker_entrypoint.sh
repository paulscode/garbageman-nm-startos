#!/bin/sh
# ==============================================================================
# Garbageman Nodes Manager - StartOS Entrypoint
# ==============================================================================
# Initializes directory structure, reads StartOS config, starts services

set -euo pipefail

echo "[i] Starting Garbageman Nodes Manager for StartOS..."

# ==============================================================================
# Read StartOS Configuration
# ==============================================================================

CONFIG_FILE="/root/start9/config.yaml"
DEFAULT_API_PORT=8080
DEFAULT_UI_PORT=5173
DEFAULT_SUPERVISOR_PORT=9000
DEFAULT_LOG_LEVEL="info"
DEFAULT_ADMIN_PASSWORD="changeme"
DEFAULT_TOR_ENABLED=true
DEFAULT_MAX_INSTANCES=10

# Parse config with defaults if file doesn't exist yet
if [ -f "$CONFIG_FILE" ]; then
    echo "[i] Reading configuration from $CONFIG_FILE"
    
    # Use simple grep/sed for parsing YAML (yq not available in minimal Alpine)
    # StartOS config format is simple key-value YAML
    export API_PORT=$(grep -E '^api-port:' "$CONFIG_FILE" | sed 's/api-port: *//' || echo "$DEFAULT_API_PORT")
    export UI_PORT=$(grep -E '^ui-port:' "$CONFIG_FILE" | sed 's/ui-port: *//' || echo "$DEFAULT_UI_PORT")
    export SUPERVISOR_PORT=$(grep -E '^supervisor-port:' "$CONFIG_FILE" | sed 's/supervisor-port: *//' || echo "$DEFAULT_SUPERVISOR_PORT")
    export LOG_LEVEL=$(grep -E '^log-level:' "$CONFIG_FILE" | sed 's/log-level: *//' | tr -d '"' || echo "$DEFAULT_LOG_LEVEL")
    export ADMIN_PASSWORD=$(grep -E '^admin-password:' "$CONFIG_FILE" | sed 's/admin-password: *//' | tr -d '"' || echo "$DEFAULT_ADMIN_PASSWORD")
    export TOR_ENABLED=$(grep -E '^enable-tor-proxy:' "$CONFIG_FILE" | sed 's/enable-tor-proxy: *//' || echo "$DEFAULT_TOR_ENABLED")
    export MAX_INSTANCES=$(grep -E '^max-instances:' "$CONFIG_FILE" | sed 's/max-instances: *//' || echo "$DEFAULT_MAX_INSTANCES")
else
    echo "[i] Config file not found, using defaults"
    export API_PORT=$DEFAULT_API_PORT
    export UI_PORT=$DEFAULT_UI_PORT
    export SUPERVISOR_PORT=$DEFAULT_SUPERVISOR_PORT
    export LOG_LEVEL=$DEFAULT_LOG_LEVEL
    export ADMIN_PASSWORD=$DEFAULT_ADMIN_PASSWORD
    export TOR_ENABLED=$DEFAULT_TOR_ENABLED
    export MAX_INSTANCES=$DEFAULT_MAX_INSTANCES
fi

echo "[i] Configuration:"
echo "    API Port:        $API_PORT"
echo "    UI Port:         $UI_PORT"
echo "    Supervisor Port: $SUPERVISOR_PORT"
echo "    Log Level:       $LOG_LEVEL"
echo "    Tor Enabled:     $TOR_ENABLED"
echo "    Max Instances:   $MAX_INSTANCES"

# ==============================================================================
# Initialize Directory Structure
# ==============================================================================

echo "[i] Initializing directory structure..."

# Create data directories (must be under /root per StartOS spec)
mkdir -p /root/data
mkdir -p /root/envfiles/instances
mkdir -p /root/artifacts
mkdir -p /root/start9

echo "[i] Directory structure ready"

# ==============================================================================
# Export Environment Variables for Services
# ==============================================================================

# Data paths
export DATA_DIR="/root/data"
export ENVFILES_DIR="/root/envfiles"
export ARTIFACTS_DIR="/root/artifacts"

# Tor proxy configuration
# Note: StartOS may provide Tor service integration in future versions
# For now, the internal Tor proxy manager handles peer discovery
export TOR_PROXY_HOST="${TOR_PROXY_HOST:-127.0.0.1}"
export TOR_PROXY_PORT="${TOR_PROXY_PORT:-9050}"

# Authentication
export WEBUI_PASSWORD="${ADMIN_PASSWORD}"
export WRAPPER_UI_PASSWORD="${ADMIN_PASSWORD}"

# ==============================================================================
# Display Runtime Info
# ==============================================================================

echo "[i] Runtime environment:"
echo "    Data Directory:      $DATA_DIR"
echo "    Envfiles Directory:  $ENVFILES_DIR"
echo "    Artifacts Directory: $ARTIFACTS_DIR"
echo "    User:                $(whoami)"
echo "    Working Directory:   $(pwd)"

# ==============================================================================
# Start Services via Supervisord
# ==============================================================================

echo "[i] Starting services with supervisord..."

# Supervisord will manage:
# - Multi-daemon supervisor (port $SUPERVISOR_PORT)
# - API server (port $API_PORT)
# - UI server (port $UI_PORT)

exec /usr/bin/supervisord -c /etc/supervisord.conf
