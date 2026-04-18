#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update

# Core stack: X, WM, dock, display manager, sandboxing, dialogs.
apt-get install -y --no-install-recommends \
  xserver-xorg xinit x11-xserver-utils \
  openbox obconf \
  tint2 \
  lightdm lightdm-gtk-greeter \
  firejail \
  yad \
  argon2 \
  xdotool \
  unclutter \
  feh

# Curated apps (Minecraft installed in 07-, Scratch in 08-).
apt-get install -y --no-install-recommends \
  chromium-browser \
  gedit \
  kolourpaint

# Flatpak for Scratch.
apt-get install -y --no-install-recommends flatpak
flatpak remote-add --if-not-exists --system flathub https://flathub.org/repo/flathub.flatpakrepo

# Make LightDM the active display manager.
if [[ -f /etc/gdm3/daemon.conf ]]; then
  systemctl disable gdm3 &>/dev/null || true
fi
echo "/usr/sbin/lightdm" > /etc/X11/default-display-manager
DEBIAN_FRONTEND=noninteractive dpkg-reconfigure lightdm
systemctl enable lightdm
