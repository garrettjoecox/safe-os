#!/bin/bash
#
# Scratch Desktop Launcher
# Simple launcher for Scratch Desktop application
#

SCRATCH_BIN="/usr/bin/scratch-desktop"

# Check if Scratch is installed
if [ ! -f "$SCRATCH_BIN" ]; then
    zenity --error --text="Scratch is not installed.\nPlease contact a parent for installation."
    exit 1
fi

# Launch Scratch Desktop
"$SCRATCH_BIN" 2>/dev/null &
