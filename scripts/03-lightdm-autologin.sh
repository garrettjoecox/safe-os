#!/usr/bin/env bash
set -euo pipefail

install -d -m 0755 /etc/lightdm/lightdm.conf.d
install -m 0644 "$REPO_DIR/config/lightdm/50-kiosk.conf" /etc/lightdm/lightdm.conf.d/50-kiosk.conf

# autologin needs this group on Debian-family systems.
groupadd -f autologin
usermod -aG autologin kid

# The session name "openbox-kiosk" is provided by the .desktop file we install here.
install -m 0644 "$REPO_DIR/config/lightdm/openbox-kiosk.desktop" /usr/share/xsessions/openbox-kiosk.desktop
