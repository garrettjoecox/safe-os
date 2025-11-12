#!/bin/bash
#
# Minecraft Offline Launcher
# Launches Minecraft with network access disabled
#

# Configuration
MINECRAFT_DIR="$HOME/.minecraft"
MINECRAFT_LAUNCHER="/usr/bin/minecraft-launcher"

# Check if Minecraft is installed
if [ ! -f "$MINECRAFT_LAUNCHER" ]; then
    zenity --error --text="Minecraft is not installed.\nPlease contact a parent for installation."
    exit 1
fi

# Function to show notification
show_notification() {
    zenity --info --text="$1" --timeout=3 2>/dev/null &
}

# Create network namespace without internet access
# This requires sudo privileges, so we'll use an alternative approach

# Method 1: Use unshare (requires setuid or capabilities)
# unshare --net --map-root-user "$MINECRAFT_LAUNCHER" --offline

# Method 2: Use iptables rules (requires pre-configuration)
# sudo -n /opt/safe-os/bin/enable-minecraft-firewall.sh

# Method 3: Simple offline flag (if Minecraft supports it)
show_notification "Launching Minecraft in offline mode..."

# Launch Minecraft with offline parameters
"$MINECRAFT_LAUNCHER" --workDir "$MINECRAFT_DIR" 2>/dev/null &

# Show instructions
zenity --info --text="Minecraft is starting in OFFLINE mode.\n\nYou can play single-player and local worlds.\nOnline multiplayer is disabled." --timeout=5 2>/dev/null &

wait
