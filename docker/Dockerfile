#
# DCS-World-Dedicated-Server-Docker Dockerfile (Pterodactyl-ready).
# Based on Aterfax’s version, modified for Pterodactyl Panel.
#

FROM lscr.io/linuxserver/webtop:debian-xfce

LABEL maintainer="Aterfax, adapted for Pterodactyl by David"

# Enable 32 bit arch
RUN sudo dpkg --add-architecture i386 ; apt update

# Install Wine and dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip wine wine64 wine32:i386 \
    libfreetype6 fonts-freefont-ttf \
    wget cabextract xdotool xdg-utils xvfb \
    git python3 python3-dev python3-pip \
    p7zip-full grep socat nano vim

# Download latest winetricks
RUN wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
    && chmod +x winetricks \
    && mv winetricks /usr/bin

# ================================
# Adjust paths for Pterodactyl
# ================================

# Create the container user and set home
RUN useradd -m container

# Make Pterodactyl data folder
RUN mkdir -p /home/container/dcs && mkdir -p /home/container/config
RUN chown container:container -R /home/container/dcs
RUN chown container:container -R /home/container/config

# Symlink /config -> /home/container/config for compatibility
RUN ln -s /home/container/config /config
RUN chown container:container -R /config

# Symlink /app/dcs_server -> /home/container/dcs
RUN mkdir -p /home/container/dcs_server
RUN chown container:container -R /home/container/dcs_server
RUN mkdir -p /app && chown container:container -R /app
RUN ln -s /home/container/dcs_server /app/dcs_server
RUN chown container:container -R /app/dcs_server

# ================================
# Copy Aterfax service scripts
# (still needed for Wine setup, installers, etc.)
# ================================
RUN mkdir /config/.wine && chown container:container -R /config/.wine
RUN mkdir /config/.cache && chown container:container -R /config/.cache

COPY ./src/s6-services/s6-init-migrate-dcs-oneshot /etc/s6-overlay/s6-rc.d/init-migrate-dcs-oneshot
RUN touch etc/s6-overlay/s6-rc.d/user/contents.d/init-migrate-dcs-oneshot

COPY ./src/s6-services/s6-init-socat-dns-forwarding-longrun /etc/s6-overlay/s6-rc.d/init-socat-dns-forwarding-longrun
RUN touch etc/s6-overlay/s6-rc.d/user/contents.d/init-socat-dns-forwarding-longrun

COPY ./src/s6-services/s6-init-winepreqs-oneshot /etc/s6-overlay/s6-rc.d/init-winepreqs-oneshot
RUN touch etc/s6-overlay/s6-rc.d/user/contents.d/init-winepreqs-oneshot

COPY ./src/s6-services/s6-init-desktop-setup-oneshot /etc/s6-overlay/s6-rc.d/init-desktop-setup-oneshot
RUN touch etc/s6-overlay/s6-rc.d/user/contents.d/init-desktop-setup-oneshot

COPY ./src/wine-dedicated-dcs-automated-installer /app/dcs_server/wine-dedicated-dcs-automated-installer
RUN chmod +x -R /app/dcs_server/wine-dedicated-dcs-automated-installer

COPY ./src/s6-services/s6-init-dcs-auto-installer-updater-oneshot /etc/s6-overlay/s6-rc.d/init-dcs-auto-installer-updater-oneshot
RUN touch etc/s6-overlay/s6-rc.d/user/contents.d/init-dcs-auto-installer-updater-oneshot

COPY ./src/s6-services/s6-init-dcs-server-autostart-longrun /etc/s6-overlay/s6-rc.d/init-dcs-server-autostart-longrun
RUN touch etc/s6-overlay/s6-rc.d/user/contents.d/init-dcs-server-autostart-longrun

COPY ./src/desktop-setup /app/dcs_server/desktop-setup
RUN chmod +x -R /app/dcs_server/desktop-setup

COPY ./src/helper_functions/logger_function /app/dcs_server/logger_function
RUN chmod +x -R /app/dcs_server/logger_function

COPY ./src/helper_functions/find_dcs_dirs_function /app/dcs_server/find_dcs_dirs_function
RUN chmod +x -R /app/dcs_server/find_dcs_dirs_function

COPY ./src/helper_functions/display_GUI_warning_function /app/dcs_server/display_GUI_warning_function
RUN chmod +x -R /app/dcs_server/display_GUI_warning_function

COPY ./src/helper_functions/get_dl_link /app/dcs_server/get_dl_link
RUN chmod +x -R /app/dcs_server/get_dl_link

# Add branding here to avoid it getting split into pieces in the output.
COPY ./src/branding /etc/s6-overlay/s6-rc.d/init-adduser/branding2
RUN sed -i '/cat \/etc\/s6-overlay\/s6-rc.d\/init-adduser\/branding/a\cat \/etc\/s6-overlay\/s6-rc.d\/init-adduser\/branding2' /etc/s6-overlay/s6-rc.d/init-adduser/run

# ================================
# Entrypoint file for Pterodactyl
# ================================
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# ================================
# Switch to non-root user for Pterodactyl
# ================================
USER container
WORKDIR /home/container

# ================================
# Entrypoint setup for Pterodactyl
# ================================
EXPOSE 10308/tcp
EXPOSE 10308/udp

ENTRYPOINT ["/entrypoint.sh"]
