#!/bin/bash
# Entrypoint for Pterodactyl container
cd /home/container || exit 1

# Print the startup command for logs
echo "Starting with command: $STARTUP"

# Run the Pterodactyl startup command
exec bash -c "$STARTUP"