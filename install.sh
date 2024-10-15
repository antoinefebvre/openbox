#!/usr/bin/bash

# ------------------- #
# Packages to install #
# ------------------- #
PKGS_CLI_TOOLS="zip unzip xarchiver"
PKGS_GUI_TOOLS="tint2 rofi"
PKGS_OPENBOX="lightdm openbox obconf"
PKGS_XORG="xinit xfonts-base xserver-xorg xserver-xorg-input-all xserver-xorg-video-all"


apt update -y
apt install $PKGS_CLI_TOOLS $PKGS_GUI_TOOLS $PKGS_OPENBOX $PKGS_XORG



