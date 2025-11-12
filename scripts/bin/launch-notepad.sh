#!/bin/bash
#
# Notepad (gedit) Launcher
# Simple text editor launcher
#

EDITOR_BIN="/usr/bin/gedit"

# Check if gedit is installed
if [ ! -f "$EDITOR_BIN" ]; then
    zenity --error --text="Notepad is not installed.\nPlease contact a parent for installation."
    exit 1
fi

# Launch gedit
"$EDITOR_BIN" 2>/dev/null &
