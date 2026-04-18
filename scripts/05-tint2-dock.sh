#!/usr/bin/env bash
set -euo pipefail

KID_HOME="/home/kid"
install -d -m 0755 -o kid -g kid "$KID_HOME/.config/tint2"
install -m 0644 -o kid -g kid "$REPO_DIR/config/tint2/tint2rc" "$KID_HOME/.config/tint2/tint2rc"
