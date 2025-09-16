#!/bin/bash
set -e

echo "====================================="
echo "Starting DCS Dedicated Server..."
echo "====================================="

# Defaults
: "${AUTOSTART:=1}"
: "${DCSAUTOINSTALL:=0}"
: "${TZ:=UTC}"
: "${SERVER_PORT:=10308}"

# Environment
export WINEPREFIX=/config/.wine
export DISPLAY=:0
export DCS_SERVER_DIR=/app/dcs_server

# Run installer if enabled
if [ "$DCSAUTOINSTALL" -eq 1 ]; then
    echo "[INFO] Running DCS automated installer..."
    bash $DCS_SERVER_DIR/wine-dedicated-dcs-automated-installer
fi

# Start server if enabled
if [ "$AUTOSTART" -eq 1 ]; then
    echo "[INFO] Launching DCS server..."
    xvfb-run -a bash -c "cd $DCS_SERVER_DIR && wine ./DCS.exe -port $SERVER_PORT -nogui"
fi

# Keep container alive if the server detached
echo "[INFO] DCS entrypoint completed, container is running."
exec tail -f /dev/null
