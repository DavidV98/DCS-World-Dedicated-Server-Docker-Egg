#!/bin/bash
set -e

# =============================
# DCS Dedicated Server Entrypoint
# =============================

echo "====================================="
echo "Starting DCS Dedicated Server..."
echo "====================================="

# Ensure required environment variables have defaults
: "${AUTOSTART:=1}"
: "${DCSAUTOINSTALL:=0}"
: "${PUID:=1000}"
: "${PGID:=1000}"
: "${TZ:=UTC}"

# Export Wine and config paths
export WINEPREFIX=/config/.wine
export DISPLAY=:0
export DCS_SERVER_DIR=/app/dcs_server

# Create /config directory if missing
mkdir -p /config
chown -R $PUID:$PGID /config

# Fix permissions for DCS scripts
chmod +x $DCS_SERVER_DIR/wine-dedicated-dcs-automated-installer
chmod +x $DCS_SERVER_DIR/desktop-setup

# Run automated installer if enabled
if [ "$DCSAUTOINSTALL" -eq 1 ]; then
    echo "[INFO] Running DCS automated installer..."
    bash $DCS_SERVER_DIR/wine-dedicated-dcs-automated-installer
fi

# Autostart server if enabled
if [ "$AUTOSTART" -eq 1 ]; then
    echo "[INFO] Launching DCS server..."
    # The long-running Wine command from Aterfax s6 service
    # Using xvfb-run for headless operation
    xvfb-run -a bash -c "cd $DCS_SERVER_DIR && wine ./DCS.exe -port ${SERVER_PORT:-10308} -nogui"
fi

# Keep container alive if nothing else is running
echo "[INFO] DCS entrypoint completed, container is running."
exec tail -f /dev/null
