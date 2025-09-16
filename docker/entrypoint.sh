#!/usr/bin/env bash
set -euo pipefail

# -----------------------
# Configurable defaults
# -----------------------
: "${AUTOSTART:=1}"
: "${DCSAUTOINSTALL:=0}"
: "${TZ:=UTC}"
: "${SERVER_PORT:=10308}"
: "${DISPLAY_NUM:=:99}"
: "${XVFB_SCREEN:='-screen 0 1920x1080x24'}"

export TZ

WINEPREFIX="${WINEPREFIX:-/config/.wine}"
export WINEPREFIX
export DISPLAY="${DISPLAY_NUM}"

DCS_SERVER_DIR="${DCS_SERVER_DIR:-/app/dcs_server}"
XVFB_LOG="/tmp/xvfb.log"

# Ensure directories exist (no-op if created in Dockerfile)
mkdir -p "$(dirname "$WINEPREFIX")" "$WINEPREFIX" "$DCS_SERVER_DIR"

# -----------------------
# Start Xvfb if not running
# -----------------------
if ! pgrep -x Xvfb >/dev/null 2>&1; then
  echo "[INFO] Starting Xvfb on ${DISPLAY} (${XVFB_SCREEN})..."
  # start Xvfb in background; redirect output to a logfile for debugging
  Xvfb "${DISPLAY}" ${XVFB_SCREEN} &> "${XVFB_LOG}" &
  # give it a moment
  sleep 0.8
fi

# Quick check if DISPLAY usable
if ! xdpyinfo -display "${DISPLAY}" &>/dev/null; then
  echo "[WARNING] xdpyinfo cannot contact DISPLAY ${DISPLAY}. Check ${XVFB_LOG} for Xvfb output."
fi

# -----------------------
# Initialize wineprefix (if needed)
# -----------------------
if [ ! -f "${WINEPREFIX}/system.reg" ]; then
  echo "[INFO] Initializing WINEPREFIX at ${WINEPREFIX}..."
  # run under xvfb to avoid "no display" issues
  xvfb-run -a --auto-servernum --server-args="${XVFB_SCREEN}" wineboot --init || true
fi

# -----------------------
# Optional automated installer
# -----------------------
if [ "${DCSAUTOINSTALL}" = "1" ] || [ "${DCSAUTOINSTALL}" = "true" ]; then
  if [ -x "${DCS_SERVER_DIR}/wine-dedicated-dcs-automated-installer" ]; then
    echo "[INFO] Running automated installer..."
    xvfb-run -a --auto-servernum --server-args="${XVFB_SCREEN}" bash -c "${DCS_SERVER_DIR}/wine-dedicated-dcs-automated-installer"
  else
    echo "[WARN] Installer not found or not executable at ${DCS_SERVER_DIR}/wine-dedicated-dcs-automated-installer"
  fi
fi

# -----------------------
# If a command was passed (Pterodactyl startup string), execute it with shell
# This allows `cd /app/dcs_server && wine ./DCS.exe ...` style startup lines in the panel.
# -----------------------
if [ "$#" -gt 0 ]; then
  echo "[INFO] Executing passed command: $*"
  exec bash -lc "$*"
fi

# -----------------------
# No command passed: fall back to default behavior
# -----------------------
if [ "${AUTOSTART}" = "1" ]; then
  if [ -f "${DCS_SERVER_DIR}/DCS.exe" ]; then
    echo "[INFO] No startup command supplied; launching DCS default."
    exec xvfb-run -a --auto-servernum --server-args="${XVFB_SCREEN}" bash -lc "cd ${DCS_SERVER_DIR} && wine ./DCS.exe -port ${SERVER_PORT} -nogui"
  else
    echo "[ERROR] DCS executable not found at ${DCS_SERVER_DIR}/DCS.exe and no startup command supplied."
    exit 2
  fi
fi

# Keep the container alive if nothing else to do
exec tail -f /dev/null
