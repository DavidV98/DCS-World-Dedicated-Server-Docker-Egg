#
# DCS-World-Dedicated-Server-Docker Dockerfile (Pterodactyl-ready, headless)
#

FROM debian:bookworm-slim

LABEL maintainer="Aterfax, adapted for Pterodactyl by David"

# Enable 32-bit architecture
RUN dpkg --add-architecture i386 && apt-get update

# Install Wine, dependencies, and basic tools
RUN apt-get install -y --no-install-recommends \
    unzip wine wine64 wine32:i386 \
    libfreetype6 fonts-freefont-ttf \
    wget cabextract xdotool xdg-utils xvfb \
    git python3 python3-dev python3-pip \
    p7zip-full grep socat nano vim curl \
    && rm -rf /var/lib/apt/lists/*

# Install latest Winetricks
RUN wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
    && chmod +x winetricks \
    && mv winetricks /usr/local/bin

# Create container user and directories
RUN useradd -m container
RUN mkdir -p /home/container/dcs_server && mkdir -p /home/container/config
RUN chown -R container:container /home/container

# Symlink for compatibility
RUN ln -s /home/container/config /config
RUN ln -s /home/container/dcs_server /app/dcs_server
RUN chown container:container -R /config
RUN chown container:container -R /app/dcs_server

# Copy server scripts
COPY ./src/wine-dedicated-dcs-automated-installer /app/dcs_server/
COPY ./src/helper_functions /app/dcs_server/helper_functions/
RUN chmod +x -R /app/dcs_server

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Switch to container user
USER container
WORKDIR /home/container

# Expose DCS server port
EXPOSE 10308/tcp
EXPOSE 10308/udp

ENTRYPOINT ["/entrypoint.sh"]
