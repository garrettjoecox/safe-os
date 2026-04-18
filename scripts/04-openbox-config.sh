#!/usr/bin/env bash
set -euo pipefail

KID_HOME="/home/kid"

install -d -m 0755 -o kid -g kid "$KID_HOME/.config/openbox"
install -m 0644 -o kid -g kid "$REPO_DIR/config/openbox/rc.xml"      "$KID_HOME/.config/openbox/rc.xml"
install -m 0644 -o kid -g kid "$REPO_DIR/config/openbox/menu.xml"    "$KID_HOME/.config/openbox/menu.xml"
install -m 0755 -o kid -g kid "$REPO_DIR/config/openbox/autostart"   "$KID_HOME/.config/openbox/autostart"

# Top-level session script the .desktop file points at.
install -m 0755 "$REPO_DIR/config/openbox/safe-os-session" /usr/local/bin/safe-os-session
