# Safe OS Installation Guide

## Prerequisites
- USB drive (4GB+) for Ubuntu installation
- Target computer for children's use
- Internet connection (for initial setup)
- Another computer to create installation media

## Step 1: Create Ubuntu Installation Media

### Download Ubuntu
```bash
# Download Ubuntu 24.04 LTS Desktop
# Visit: https://ubuntu.com/download/desktop
# Or use wget:
wget https://releases.ubuntu.com/24.04/ubuntu-24.04-desktop-amd64.iso
```

### Create Bootable USB
**On macOS:**
```bash
# Find USB device
diskutil list

# Unmount the USB (replace N with your disk number)
diskutil unmountDisk /dev/diskN

# Write image to USB
sudo dd if=ubuntu-24.04-desktop-amd64.iso of=/dev/rdiskN bs=1m

# Eject
diskutil eject /dev/diskN
```

**On Linux:**
```bash
# Find USB device
lsblk

# Write image (replace sdX with your device)
sudo dd if=ubuntu-24.04-desktop-amd64.iso of=/dev/sdX bs=4M status=progress
sync
```

## Step 2: Install Ubuntu Base System

1. Boot from USB drive
2. Select "Install Ubuntu"
3. Choose minimal installation (less bloat)
4. Do NOT download updates during installation (faster)
5. Create initial admin account:
   - Username: `parent`
   - Password: [Choose strong password]
   - Computer name: `safe-os-pc`

## Step 3: Initial System Configuration

### Update System
```bash
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y
```

### Install Essential Packages
```bash
sudo apt install -y \
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
    xdotool
```

### Create Child User Account
```bash
# Create user without admin privileges
sudo adduser child
# When prompted, set a simple password (or none)
# You can use: sudo passwd -d child  # to remove password requirement

# Restrict user permissions
sudo deluser child sudo
sudo deluser child adm
```

## Step 4: Configure Openbox for Child User

### Create Openbox Configuration
```bash
# Switch to child user to set up their environment
sudo su - child

# Create config directories
mkdir -p ~/.config/openbox
mkdir -p ~/.config/plank

# Copy default configs
cp /etc/xdg/openbox/rc.xml ~/.config/openbox/
cp /etc/xdg/openbox/menu.xml ~/.config/openbox/
cp /etc/xdg/openbox/autostart ~/.config/openbox/

# Exit child user
exit
```

### Lockdown Openbox Keybindings
Copy the restrictive Openbox config:
```bash
sudo cp configs/openbox-rc.xml /home/child/.config/openbox/rc.xml
sudo chown child:child /home/child/.config/openbox/rc.xml
```

### Configure Openbox Autostart
```bash
sudo tee /home/child/.config/openbox/autostart << 'EOF'
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

sudo chown child:child /home/child/.config/openbox/autostart
sudo chmod +x /home/child/.config/openbox/autostart
```

## Step 5: Configure LightDM for Autologin

### Edit LightDM Configuration
```bash
sudo tee /etc/lightdm/lightdm.conf.d/50-autologin.conf << 'EOF'
[Seat:*]
autologin-user=child
autologin-user-timeout=0
user-session=openbox
EOF
```

### Create Openbox Session File
```bash
sudo tee /usr/share/xsessions/openbox.desktop << 'EOF'
[Desktop Entry]
Name=Openbox
Comment=Lightweight Window Manager
Exec=openbox-session
Type=Application
EOF
```

## Step 6: Set Up Application Directory

### Create Application Scripts Directory
```bash
sudo mkdir -p /opt/safe-os/apps
sudo mkdir -p /opt/safe-os/bin
sudo cp -r scripts/* /opt/safe-os/
sudo chmod +x /opt/safe-os/bin/*
```

### Create Desktop Files for Dock
```bash
sudo mkdir -p /home/child/.local/share/applications
sudo cp desktop-files/*.desktop /home/child/.local/share/applications/
sudo chown -R child:child /home/child/.local
```

## Step 7: Install Applications

### Install Scratch
```bash
# Download Scratch Desktop
wget https://downloads.scratch.mit.edu/desktop/Scratch%20Desktop-3.29.1.deb -O /tmp/scratch.deb
sudo dpkg -i /tmp/scratch.deb
sudo apt install -f -y
```

### Install Minecraft (if needed)
```bash
# Option 1: Download from minecraft.net
# Option 2: Use minecraft-launcher package
# This requires manual download and installation
```

## Step 8: Configure Plank Dock

### Set Up Plank Dockitems
```bash
# Configure Plank to show specific applications
sudo tee /home/child/.config/plank/dock1/launchers/scratch.dockitem << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///home/child/.local/share/applications/scratch.desktop
EOF

# Repeat for other applications (pbskids, minecraft, etc.)
sudo chown -R child:child /home/child/.config/plank
```

### Lock Plank Settings
```bash
# Configure Plank preferences (run as child user)
sudo su - child
plank --preferences
# In GUI: Set icon size, position, behavior
# Then lock the preferences file from modification
exit

sudo chmod 444 /home/child/.config/plank/dock1/settings
```

## Step 9: System Lockdown

### Remove Dangerous Applications
```bash
# Remove terminal emulators
sudo apt remove -y gnome-terminal xterm konsole

# Remove file managers (optional - you might want to keep but restrict)
# sudo apt remove -y nautilus

# Remove system tools
sudo apt remove -y gnome-control-center
```

### Disable Virtual Terminals (Ctrl+Alt+F1-F6)
```bash
# Disable virtual terminals for child user
sudo tee -a /etc/security/limits.conf << 'EOF'
child    hard    maxlogins    1
EOF

# Lock down console switching
sudo chmod 600 /etc/X11/xorg.conf
```

### Configure Sudoers
```bash
# Ensure child user cannot use sudo
sudo visudo
# Verify child is NOT in sudo group
```

## Step 10: Implement Parent Escape Hatch

### Method 1: Hidden Keybinding
```bash
# Add to parent user's .bashrc for documentation
echo "# Parent Escape Hatch: Ctrl+Alt+Shift+P" >> /home/parent/.bashrc
```

This is configured in the Openbox config file (already included).

### Method 2: Boot Menu
```bash
# Add GRUB entry for parent session
sudo tee -a /etc/grub.d/40_custom << 'EOF'
menuentry "Parent Mode (Admin)" {
    set root=(hd0,1)
    linux /boot/vmlinuz root=/dev/sda1 systemd.unit=graphical.target
    initrd /boot/initrd.img
}
EOF

sudo update-grub
```

## Step 11: Final Steps

### Test the Setup
1. Reboot system
2. Should autologin as `child`
3. Test that keybindings are disabled
4. Test that applications launch correctly
5. Test escape hatch (Ctrl+Alt+Shift+P)

### Create Backup
```bash
# Backup important configs
sudo tar -czf safe-os-backup-$(date +%Y%m%d).tar.gz \
    /home/child/.config \
    /opt/safe-os \
    /etc/lightdm \
    /usr/share/xsessions
```

### Documentation
1. Document parent account password securely
2. Keep Ubuntu USB for recovery
3. Print or save escape hatch instructions

## Troubleshooting

### Child User Can't Login
- Check LightDM logs: `sudo cat /var/log/lightdm/lightdm.log`
- Verify Openbox session file exists
- Try manual login from TTY

### Applications Don't Launch
- Check .desktop file paths
- Verify script permissions
- Check logs: `~/.xsession-errors`

### Escape Hatch Not Working
- Verify Openbox keybinding configuration
- Test from parent account first
- Check PolicyKit agent is running

## Next Steps
After installation, refer to:
- `CONFIGURATION.md` for fine-tuning
- `scripts/` directory for application wrappers
- `MAINTENANCE.md` for ongoing management
