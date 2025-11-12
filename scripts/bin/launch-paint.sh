#!/bin/bash
#
# Paint (GIMP) Launcher
# Launches GIMP as a simple paint program
#

GIMP_BIN="/usr/bin/gimp"

# Check if GIMP is installed
if [ ! -f "$GIMP_BIN" ]; then
    zenity --error --text="Paint program is not installed.\nPlease contact a parent for installation."
    exit 1
fi

# Launch GIMP in single-window mode
"$GIMP_BIN" --no-splash 2>/dev/null &
