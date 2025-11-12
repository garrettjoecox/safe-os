#!/bin/bash
#
# Parent Escape Hatch
# Password-protected access to system settings for parents
#

# Check if running as child user
if [ "$USER" != "child" ]; then
    zenity --error --text="This tool should only be run from the child account."
    exit 1
fi

# Prompt for password using pkexec/gksu
pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY /opt/safekids/bin/parent-menu.sh

exit 0
