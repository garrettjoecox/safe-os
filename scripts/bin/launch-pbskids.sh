#!/bin/bash
#
# PBS Kids Kiosk Mode Browser Launcher
# Launches Chromium in kiosk mode restricted to pbskids.org
#

# Configuration
ALLOWED_DOMAIN="pbskids.org"
START_URL="https://pbskids.org"
USER_DATA_DIR="/tmp/pbskids-browser-$$"

# Function to cleanup on exit
cleanup() {
    rm -rf "$USER_DATA_DIR"
    pkill -f "chromium.*pbskids" 2>/dev/null
}

trap cleanup EXIT INT TERM

# Create temporary user data directory
mkdir -p "$USER_DATA_DIR"

# Launch Chromium in kiosk mode with restrictions
chromium-browser \
    --kiosk "$START_URL" \
    --no-first-run \
    --noerrdialogs \
    --disable-infobars \
    --disable-session-crashed-bubble \
    --disable-translate \
    --disable-features=TranslateUI \
    --disable-component-update \
    --user-data-dir="$USER_DATA_DIR" \
    --disable-sync \
    --disable-notifications \
    --disable-default-apps \
    --no-default-browser-check \
    --disable-extensions \
    --disable-plugins-discovery \
    --disable-preconnect \
    --disable-background-networking \
    --disable-dev-tools \
    --disable-java \
    --incognito \
    --no-context-menu \
    --overscroll-history-navigation=0 \
    2>/dev/null

cleanup
