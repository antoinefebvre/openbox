#!/usr/bin/bash
set -e

# ---- #
# TODO #
# ---- #
# - bluetooth (bluez blueman)
# - compositor (compton)

ROOT="$(realpath "$(dirname "$0")")"

# ----------------- #
# Logging functions #
# ----------------- #
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

function log_error()   { echo -e "${RED}[ERROR  ] ${1}${NC}"; }
function log_warning() { echo -e "${YELLOW}[WARNING] ${1}${NC}"; }
function log_info()    { echo -e "${BLUE}[INFO   ] ${1}${NC}"; }
function log_success() { echo -e "${GREEN}[SUCCESS] ${1}${NC}"; }


# Avoid running script as root
if [ "$(id -u)" -eq 0 ]; then
    log_error "This script must no be run as root."
    exit 1
fi

# ---------------- #
# Install packages #
# ---------------- #
PKGS_CLI_TOOLS="zip unzip xarchiver jq"
PKGS_GUI_TOOLS="tint2 rofi"
PKGS_NETWORK="network-manager network-manager-gnome"
PKGS_OPENBOX="lightdm openbox obconf compton python3-xdg"
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

CFG_OPENBOX_AUTOSTART="$HOME/.config/openbox/autostart"
CFG_OPENBOX_RC_XML="$HOME/.config/openbox/rc.xml"

log_info "Copy configuration files ..."
copy_configuration_file "$ROOT/configs/openbox/autostart" "$CFG_OPENBOX_AUTOSTART"
copy_configuration_file "$ROOT/configs/openbox/rc.xml" "$CFG_OPENBOX_RC_XML"
log_success "Configuration files copied"