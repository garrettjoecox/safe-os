#!/usr/bin/env bash
# Locked PBS Kids browser. URL allow/blocklist enforced via /etc/chromium/policies/managed/pbskids.json
# (loaded by chromium at startup; kid can't override).
set -euo pipefail

PROFILE="$HOME/.config/safe-pbskids"
mkdir -p "$PROFILE"

exec flatpak run org.chromium.Chromium \
  --user-data-dir="$PROFILE" \
  --kiosk \
  --no-first-run \
  --no-default-browser-check \
  --disable-pinch \
  --overscroll-history-navigation=0 \
  --app=https://pbskids.org
