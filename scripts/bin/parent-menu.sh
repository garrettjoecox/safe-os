#!/bin/bash
#
# Parent Control Menu
# Menu for parents to access system settings
# This script runs with elevated privileges after password authentication
#

# Display menu
CHOICE=$(zenity --list --title="Parent Controls" \
    --text="Select an action:" \
    --column="Option" \
    "Open System Settings" \
    "Open File Manager" \
    "Open Terminal" \
    "Install Software" \
    "Switch to Parent Account" \
    "Shutdown Computer" \
    "Restart Computer" \
    "Exit" \
    --width=400 --height=400)

case "$CHOICE" in
    "Open System Settings")
        gnome-control-center 2>/dev/null || \
        xfce4-settings-manager 2>/dev/null || \
        zenity --info --text="Settings manager not available"
        ;;
    "Open File Manager")
        nautilus /home/child 2>/dev/null || \
        thunar /home/child 2>/dev/null || \
        pcmanfm /home/child 2>/dev/null
        ;;
    "Open Terminal")
        x-terminal-emulator 2>/dev/null || \
        gnome-terminal 2>/dev/null || \
        xterm 2>/dev/null
        ;;
    "Install Software")
        gnome-software 2>/dev/null || \
        synaptic 2>/dev/null || \
        zenity --info --text="Open terminal and use: sudo apt install <package>"
        ;;
    "Switch to Parent Account")
        dm-tool switch-to-greeter
        ;;
    "Shutdown Computer")
        if zenity --question --text="Are you sure you want to shutdown?"; then
            systemctl poweroff
        fi
        ;;
    "Restart Computer")
        if zenity --question --text="Are you sure you want to restart?"; then
            systemctl reboot
        fi
        ;;
    *)
        exit 0
        ;;
esac
