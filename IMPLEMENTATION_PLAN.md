# Safe OS Implementation Plan

## Overview
Create a locked-down Ubuntu-based computing environment for children with restricted system access, curated applications, and parent controls.

## Technical Architecture

### Base System
- **OS**: Ubuntu 24.04 LTS (or 22.04 LTS for longer support)
- **Desktop Environment**: Openbox (lightweight, highly customizable)
- **Display Manager**: LightDM with autologin to child user
- **Session Manager**: Custom session configuration

### Key Components

#### 1. Desktop Environment Lockdown
- **Openbox** - Minimal window manager that's easy to configure
  - Disable all default keybindings via `~/.config/openbox/rc.xml`
  - Remove right-click menu functionality
  - Hide window decorations for immersive experience
  - Lock down Alt+Tab, Alt+F4, etc.

#### 2. User Account Structure
- **child-user**: Restricted account with minimal permissions
- **parent-user**: Administrative account for system management
- Use `sudo` and group permissions to control access

#### 3. Application Launcher
- **Plank Dock** or **Cairo-Dock** - Visual, icon-based launcher
- Custom `.desktop` files that launch wrapper scripts
- Scripts handle application-specific restrictions (network, file access)

#### 4. Parent Escape Hatch
- **Option A**: Hidden keyboard shortcut (e.g., Ctrl+Alt+Shift+P)
  - Launches `gksu` or `pkexec` password prompt
  - Opens full desktop environment or settings panel
- **Option B**: Boot menu entry
  - GRUB menu option to boot into unrestricted session
  - Password-protect GRUB entries

#### 5. Application Wrappers

##### Kiosk Browser (PBS Kids)
- Use Chromium with kiosk mode flags
- Content filtering via hosts file or proxy
- Disable navigation, address bar, context menus

##### Minecraft
- Launch with `--offline` flag
- Use `unshare` to create network namespace without internet
- Or use firewall rules (iptables/nftables) per-user

##### Scratch
- Install Scratch Desktop (offline version)
- Or use browser-based version in kiosk mode

##### Other Apps
- Standard applications: GIMP (paint), gedit (notepad)
- Launch via wrapper scripts that set environment variables

## Implementation Steps

### Phase 1: Base System Setup
1. Install Ubuntu Desktop (minimal installation)
2. Create user accounts (child, parent)
3. Update system and install required packages
4. Install Openbox and required dependencies

### Phase 2: Desktop Environment Configuration
1. Configure Openbox for child user
2. Disable all dangerous keybindings
3. Set up autologin for child user
4. Install and configure dock (Plank/Cairo-Dock)

### Phase 3: Application Setup
1. Install applications (Minecraft, Scratch, GIMP, gedit)
2. Create wrapper scripts for each application
3. Create custom .desktop files
4. Configure dock with application icons

### Phase 4: Security Lockdown
1. Disable access to terminal emulators
2. Disable access to file managers (or restrict heavily)
3. Remove/hide system applications from menus
4. Configure AppArmor profiles (optional, advanced)
5. Set up firewall rules for network restrictions

### Phase 5: Parent Controls
1. Implement escape hatch mechanism
2. Test password protection
3. Document parent access procedures
4. Create backup/recovery procedures

### Phase 6: Testing & Refinement
1. Test all applications and restrictions
2. Look for bypass methods (close loopholes)
3. Test escape hatch functionality
4. Performance tuning

## Required Packages

```bash
# Base desktop environment
openbox obconf tint2 nitrogen

# Dock options
plank  # or cairo-dock

# Applications
scratch gimp gedit chromium-browser

# Utilities
gksu zenity unshare
```

## Security Considerations

### What Gets Locked Down
- Terminal access (remove all terminal emulators)
- File manager (remove or heavily restrict)
- System settings
- Package managers
- Browser outside kiosk mode
- Network configuration tools
- Virtual terminals (Ctrl+Alt+F1-F6)

### What Stays Accessible
- Curated application list
- Parent escape hatch (password protected)
- Safe shutdown/restart (maybe)

## Backup & Recovery
- Keep bootable USB with full Ubuntu for recovery
- Document parent account password securely
- Regular backups of configuration files
- Test recovery procedures

## Future Enhancements
- Time limits per application
- Usage logging/monitoring
- Screen time limits
- Content filtering for web browser
- Multiple child profiles
- Parental dashboard for monitoring
