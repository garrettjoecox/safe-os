#!/bin/bash
#
# Diagnostic and Fix Script for Safe OS
# Run this to diagnose and fix common issues
#

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo "=== Safe OS Diagnostic Tool ==="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run this script as root or with sudo"
    exit 1
fi

# 1. Check autologin configuration
print_info "Checking autologin configuration..."
if grep -q "autologin-user=child" /etc/lightdm/lightdm.conf.d/50-autologin.conf 2>/dev/null; then
    print_info "✓ Autologin config exists"
    cat /etc/lightdm/lightdm.conf.d/50-autologin.conf
else
    print_error "✗ Autologin config missing or incorrect"
    echo "Creating correct autologin config..."
    mkdir -p /etc/lightdm/lightdm.conf.d
    cat > /etc/lightdm/lightdm.conf.d/50-autologin.conf << 'EOF'
[Seat:*]
autologin-user=child
autologin-user-timeout=0
autologin-session=openbox
EOF
    print_info "✓ Autologin config created"
fi

# Check autologin group
if groups child | grep -q "autologin"; then
    print_info "✓ Child user in autologin group"
else
    print_warn "✗ Child user not in autologin group - adding..."
    groupadd -f autologin
    usermod -aG autologin child
    print_info "✓ Added to autologin group"
fi

echo ""

# 2. Check script permissions
print_info "Checking script permissions..."
SCRIPTS_OK=true
for script in /opt/safe-os/bin/*.sh; do
    if [ ! -x "$script" ]; then
        print_warn "✗ $script not executable"
        chmod +x "$script"
        SCRIPTS_OK=false
    fi
done
if $SCRIPTS_OK; then
    print_info "✓ All scripts are executable"
else
    print_info "✓ Fixed script permissions"
fi

echo ""

# 3. Check desktop files
print_info "Checking desktop files..."
if [ -d /home/child/.local/share/applications ]; then
    COUNT=$(ls -1 /home/child/.local/share/applications/*.desktop 2>/dev/null | wc -l)
    print_info "✓ Found $COUNT desktop files"
    
    # Verify they're executable
    for desktop in /home/child/.local/share/applications/*.desktop; do
        if [ -f "$desktop" ]; then
            chmod +x "$desktop" 2>/dev/null
        fi
    done
else
    print_error "✗ Desktop files directory missing"
fi

echo ""

# 4. Check Openbox configuration
print_info "Checking Openbox configuration..."
if [ -f /home/child/.config/openbox/rc.xml ]; then
    print_info "✓ Openbox rc.xml exists"
    if [ -f /home/child/.config/openbox/autostart ]; then
        print_info "✓ Openbox autostart exists"
        if [ -x /home/child/.config/openbox/autostart ]; then
            print_info "✓ Openbox autostart is executable"
        else
            print_warn "✗ Openbox autostart not executable - fixing..."
            chmod +x /home/child/.config/openbox/autostart
        fi
    else
        print_error "✗ Openbox autostart missing"
    fi
else
    print_error "✗ Openbox rc.xml missing"
fi

echo ""

# 5. Check AccountsService configuration
print_info "Checking AccountsService configuration..."
if [ ! -f /var/lib/AccountsService/users/child ]; then
    print_warn "✗ AccountsService file missing - creating..."
    mkdir -p /var/lib/AccountsService/users
    cat > /var/lib/AccountsService/users/child << 'EOF'
[User]
Session=openbox
XSession=openbox
SystemAccount=false
EOF
    print_info "✓ Created AccountsService configuration"
else
    print_info "✓ AccountsService configuration exists"
    cat /var/lib/AccountsService/users/child
fi

echo ""

# 6. Check for parent user AccountsService (keep GNOME for parent)
print_info "Checking parent user session..."
PARENT_USER=$(logname 2>/dev/null || echo $SUDO_USER)
if [ -n "$PARENT_USER" ] && [ "$PARENT_USER" != "child" ]; then
    if [ ! -f /var/lib/AccountsService/users/$PARENT_USER ]; then
        print_info "Setting parent user to use GNOME/Ubuntu desktop..."
        cat > /var/lib/AccountsService/users/$PARENT_USER << EOF
[User]
Session=ubuntu
XSession=ubuntu
SystemAccount=false
EOF
        print_info "✓ Parent user will use Ubuntu desktop"
    fi
fi

echo ""

# 7. Check if required applications are installed
print_info "Checking required applications..."
APPS=("chromium-browser" "plank" "openbox" "zenity" "gedit" "gimp")
for app in "${APPS[@]}"; do
    if command -v $app &> /dev/null || dpkg -l | grep -q "^ii.*$app"; then
        print_info "✓ $app installed"
    else
        print_warn "✗ $app not found"
    fi
done

echo ""

# 8. Fix ownership
print_info "Fixing file ownership..."
chown -R child:child /home/child/.config 2>/dev/null
chown -R child:child /home/child/.local 2>/dev/null
print_info "✓ Ownership fixed"

echo ""
print_info "=== Diagnostic Complete ==="
echo ""
print_info "Recommendations:"
echo "1. Reboot the system: sudo reboot"
echo "2. System should autologin as child"
echo "3. If apps don't work, check logs: ~/.xsession-errors"
echo "4. Test parent escape: Ctrl+Alt+Shift+P"
echo ""
print_warn "If autologin still doesn't work, try: sudo systemctl restart lightdm"
