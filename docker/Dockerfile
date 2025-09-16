#
# DCS World Dedicated Server (Pterodactyl-ready)
# Built on top of Pelican Eggs Wine yolk
#

FROM ghcr.io/parkervcp/yolks:wine_latest

LABEL maintainer="David" \
      description="DCS World Dedicated Server for Pterodactyl"

# ================================
# Install additional deps needed by DCS
# ================================
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        unzip cabextract xdotool xdg-utils p7zip-full \
        git python3 python3-pip socat nano vim \
        libfreetype6 fonts-freefont-ttf && \
    rm -rf /var/lib/apt/lists/*

# ================================
# Setup directories
# ================================
RUN mkdir -p /home/container/dcs_server \
             /home/container/config \
             /config/.wine \
             /config/.cache \
             /app
RUN chown -R container:container /home/container /config /app

# Symlinks for compatibility
RUN ln -s /home/container/config /config
RUN ln -s /home/container/dcs_server /app/dcs_server

# ================================
# Copy scripts
# ================================
COPY src/wine-dedicated-dcs-automated-installer /app/dcs_server/wine-dedicated-dcs-automated-installer
RUN chmod +x /app/dcs_server/wine-dedicated-dcs-automated-installer

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# ================================
# Switch to non-root user for panel
# ================================
USER container
WORKDIR /home/container

# ================================
# Ports & Entrypoint
# ================================
EXPOSE 10308/tcp
EXPOSE 10308/udp

ENTRYPOINT ["/entrypoint.sh"]
