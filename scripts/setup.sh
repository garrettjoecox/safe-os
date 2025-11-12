#!/bin/bash
#
# Safe OS Setup Script
# Automates the installation and configuration of the Safe OS environment
# Run this script on a fresh Ubuntu installation
#

set -e  # Exit on error

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run this script as root or with sudo"
    exit 1
fi

print_info "Starting Safe OS setup..."

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Update system
print_info "Updating system packages..."
apt update
apt upgrade -y

# Install required packages
print_info "Installing required packages..."
apt install -y \
    openbox obconf \
    plank \
    nitrogen \
    lightdm \
    xorg \
    git \
    chromium-browser \
    gimp \
    gedit \
    zenity \
    policykit-1-gnome \
    unclutter \
    xdotool \
    wget \
    curl

# Create child user if it doesn't exist
if id "child" &>/dev/null; then
    print_warn "User 'child' already exists"
else
    print_info "Creating child user..."
    adduser --disabled-password --gecos "" child
    passwd -d child  # Remove password requirement
    # Remove from sudo and admin groups if present
    deluser child sudo 2>/dev/null || true
    deluser child adm 2>/dev/null || true
fi

# Create directory structure
print_info "Creating application directories..."
mkdir -p /opt/safe-os/bin
mkdir -p /opt/safe-os/apps

# Copy scripts
print_info "Installing application launchers..."
cp -r "$PROJECT_ROOT/scripts/bin/"* /opt/safe-os/bin/
chmod +x /opt/safe-os/bin/*.sh

# Set up child user's Openbox configuration
print_info "Configuring Openbox for child user..."
mkdir -p /home/child/.config/openbox
cp "$PROJECT_ROOT/configs/openbox-rc.xml" /home/child/.config/openbox/rc.xml
cp "$PROJECT_ROOT/configs/openbox-menu.xml" /home/child/.config/openbox/menu.xml

# Create Openbox autostart
cat > /home/child/.config/openbox/autostart << 'EOF'
# Disable screen saver and power management
xset s off
xset -dpms
xset s noblank

# Hide mouse cursor when inactive
unclutter -idle 3 &

# Start dock
plank &

# PolicyKit agent for password prompts
/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &

# Set desktop background
nitrogen --restore &
EOF

chmod +x /home/child/.config/openbox/autostart

# Set up desktop files
print_info "Installing application shortcuts..."
mkdir -p /home/child/.local/share/applications
cp "$PROJECT_ROOT/desktop-files/"*.desktop /home/child/.local/share/applications/

# Fix ownership
chown -R child:child /home/child/.config
chown -R child:child /home/child/.local

# Configure LightDM for autologin
print_info "Configuring LightDM autologin..."
mkdir -p /etc/lightdm/lightdm.conf.d
cat > /etc/lightdm/lightdm.conf.d/50-autologin.conf << EOF
[Seat:*]
autologin-user=child
autologin-user-timeout=0
user-session=openbox
EOF

# Create Openbox session file
cat > /usr/share/xsessions/openbox.desktop << 'EOF'
[Desktop Entry]
Name=Openbox
Comment=Lightweight Window Manager
Exec=openbox-session
Type=Application
EOF

# Install Scratch Desktop
print_info "Installing Scratch..."
apt install -y scratch || print_warn "Failed to install Scratch from repositories"

# Clean up
print_info "Cleaning up..."
apt autoremove -y
apt clean

print_info "${GREEN}Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Reboot the system: sudo reboot"
echo "2. System will autologin as 'child' user"
echo "3. Configure Plank dock (Ctrl+Right-click on dock)"
echo "4. Set desktop wallpaper using nitrogen"
echo "5. Test parent escape hatch: Ctrl+Alt+Shift+P"
echo ""
echo "Parent account password: [your current user]"
echo "Child account: no password required"
echo ""
print_warn "Remember to install Minecraft manually if needed"
print_warn "Download from: https://minecraft.net"
