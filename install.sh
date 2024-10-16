#!/usr/bin/bash

# ---- #
# TODO #
# ---- #
# - bluetooth (bluez blueman)
# - compositor (compton)

ROOT="$(realpath "$(dirname "$0")")"

# Avoid running script as root
if [ "$(id -u)" -eq 0 ]; then
    echo "This script must no be run as root."
    exit 1
fi

# ---------------- #
# Install packages #
# ---------------- #
PKGS_CLI_TOOLS="zip unzip xarchiver"
PKGS_GUI_TOOLS="tint2 rofi"
PKGS_NETWORK="network-manager network-manager-gnome"
PKGS_OPENBOX="lightdm openbox obconf"
PKGS_XORG="xinit xfonts-base xserver-xorg xserver-xorg-input-all xserver-xorg-video-all"

su -c "apt update -y && apt install $PKGS_CLI_TOOLS $PKGS_GUI_TOOLS $PKGS_NETWORK $PKGS_OPENBOX $PKGS_XORG"

# ------------------------ #
# Copy configuration files #
# ------------------------ #

function copy_configuration_file() {
    SRC="$1"
    DST="$2"

    mkdir -pv "$(dirname "$DST")"
    cp -rv "$SRC" "$DST"
}

CFG_OPENBOX_RC_XML="$HOME/.config/openbox/rc.xml"

copy_configuration_file "$ROOT/configs/openbox/rc.xml" "$CFG_OPENBOX_RC_XML"