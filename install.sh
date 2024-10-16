#!/usr/bin/bash
set -e

# ---- #
# TODO #
# ---- #
# - bluetooth (bluez blueman)

# ----------------- #
# Logging functions #
# ----------------- #
function log_error()   { echo -e "\033[0;31m[ERROR  ]\033[0m ${1}"; }
function log_warning() { echo -e "\033[0;33m[WARNING]\033[0m ${1}"; }
function log_info()    { echo -e "\033[1;34m[INFO   ]\033[0m ${1}"; }
function log_success() { echo -e "\033[0;32m[SUCCESS]\033[0m ${1}"; }

# ----- #
# Setup #
# ----- #
ROOT="$(realpath "$(dirname "$0")")"

if [ "$(id -u)" -eq 0 ]; then # Avoid running script as root
    log_error "This script must no be run as root."
    exit 1
fi

# ---------------- #
# Install packages #
# ---------------- #
PKGS_CLI_TOOLS="zip unzip xarchiver jq"
PKGS_GUI_TOOLS="tint2 rofi"
PKGS_NETWORK="network-manager network-manager-gnome"
PKGS_OPENBOX="lightdm openbox obconf picom python3-xdg"
PKGS_XORG="xinit xfonts-base xserver-xorg xserver-xorg-input-all xserver-xorg-video-all"

log_info "Installing packages ..."
su -c "apt update -y && apt install $PKGS_CLI_TOOLS $PKGS_GUI_TOOLS $PKGS_NETWORK $PKGS_OPENBOX $PKGS_XORG"
log_success "Packages installed"

# ------------------------------------------------- #
# Disable network interfaces default configuration. #
# Configuration will be managed by network-manager  #
# ------------------------------------------------- #
NETWORK_INTERFACES="$(ip --json addr show | jq .[].ifname | grep -v "lo" | tr -d \")"
NETWORK_INTERFACE_FILE="/etc/network/interfaces"

log_info "Disabling network configuration managed by ifupdown ..."
for INTERFACE in $NETWORK_INTERFACES; do
    su -c "sed -i -e \"/^iface $INTERFACE/s/^/# /\" -e \"/^allow-hotplug $INTERFACE/s/^/# /\" \"$NETWORK_INTERFACE_FILE\""
    log_success "Interface $INTERFACE disabled in ifupdown"
done

# ------------------------ #
# Copy configuration files #
# ------------------------ #
function copy_configuration_file() {
    SRC="$1"
    DST="$2"

    log_info "Copy $SRC --> $DST"
    mkdir -p "$(dirname "$DST")"
    cp -r "$SRC" "$DST"
}

CFG_PICOM_CONF="$HOME/.config/picom.conf"
CFG_OPENBOX_AUTOSTART="$HOME/.config/openbox/autostart"
CFG_OPENBOX_RC_XML="$HOME/.config/openbox/rc.xml"

log_info "Copy configuration files ..."
copy_configuration_file "$ROOT/configs/picom.conf" "$CFG_PICOM_CONF"
copy_configuration_file "$ROOT/configs/openbox/autostart" "$CFG_OPENBOX_AUTOSTART"
copy_configuration_file "$ROOT/configs/openbox/rc.xml" "$CFG_OPENBOX_RC_XML"
log_success "Configuration files copied"