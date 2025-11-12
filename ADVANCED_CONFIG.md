# Safe OS - Additional Documentation

## Network Restriction for Minecraft

Since blocking network access for specific applications requires either root privileges or kernel capabilities, here are three approaches:

### Option 1: Firewall Rules (Recommended)
Create a script that parents run once to set up user-based firewall rules:

```bash
#!/bin/bash
# /opt/safekids/bin/setup-minecraft-firewall.sh
# Run once as root to set up firewall rules

# Block all outgoing connections for minecraft-launcher when run by child user
iptables -A OUTPUT -m owner --uid-owner child -m string --string "minecraft" --algo bm -j DROP
# Or use nftables for newer systems
```

### Option 2: Network Namespace (Advanced)
Requires setting up network namespaces without internet:

```bash
# Create isolated network namespace
sudo ip netns add minecraft-offline
# Don't add any network interfaces - completely isolated
# Run Minecraft in this namespace
sudo ip netns exec minecraft-offline sudo -u child minecraft-launcher
```

### Option 3: Manual Offline Mode
Simply disconnect from WiFi before playing, or configure Minecraft to use offline mode by default.

## Plank Dock Configuration

### Initial Setup
1. Start Plank: `plank &`
2. Hold Ctrl and right-click on Plank to access preferences
3. Configure:
   - Theme: Default
   - Icon Size: 48-64px
   - Position: Bottom center
   - Hide: Never
   - Zoom: Enabled

### Adding Applications
Drag .desktop files from `/home/child/.local/share/applications/` onto the dock.

### Locking Configuration
```bash
# After setup, make settings read-only
chmod 444 /home/child/.config/plank/dock1/settings
```

## Security Hardening Checklist

- [ ] Disable virtual terminal switching (Ctrl+Alt+F1-F6)
- [ ] Remove terminal emulators
- [ ] Remove/restrict file managers
- [ ] Disable sudo for child user
- [ ] Set up AppArmor profiles (optional)
- [ ] Configure PAM limits
- [ ] Disable shutdown/reboot for child user
- [ ] Test escape hatch password prompt
- [ ] Verify no system settings accessible
- [ ] Test all application launchers
- [ ] Verify network restrictions work
- [ ] Test that keybindings are disabled

## Troubleshooting Common Issues

### Plank doesn't start
```bash
# Check if process is running
pgrep plank
# Kill and restart
pkill plank && plank &
```

### Openbox keybindings not working
```bash
# Verify config syntax
openbox --reconfigure
# Check config file location
ls -la ~/.config/openbox/rc.xml
```

### Parent escape hatch not responding
```bash
# Verify PolicyKit agent is running
pgrep polkit-gnome-au
# Test pkexec directly
pkexec whoami
```

### Applications don't appear in dock
```bash
# Verify .desktop files exist
ls -la ~/.local/share/applications/
# Check permissions
chmod +x /opt/safekids/bin/*.sh
```

## Maintenance Tasks

### Weekly
- Check for system updates (parent account)
- Review child account activity (if logging enabled)

### Monthly
- Backup configuration files
- Test escape hatch functionality
- Update application list as needed

### As Needed
- Install new educational applications
- Update Minecraft/Scratch versions
- Adjust time limits (if implemented)

## Future Enhancement Ideas

### Time Limits
Use systemd timers or cron jobs to automatically log out child user after X hours:

```bash
# /etc/cron.d/child-time-limit
0 20 * * * root pkill -KILL -u child
```

### Usage Logging
Track application usage:

```bash
# In each launcher script, add:
echo "$(date): Launched $APP" >> /var/log/child-activity.log
```

### Parental Dashboard
Create a simple web interface for parents to:
- View usage statistics
- Adjust time limits
- Add/remove applications
- View activity logs

### Content Filtering
For the PBS Kids browser, enhance filtering:
- Install `squid` proxy with whitelist
- Use `/etc/hosts` to block unwanted domains
- Consider DNS-level filtering (Pi-hole)

## Resources

- [Openbox Documentation](http://openbox.org/wiki/Help:Contents)
- [Ubuntu Desktop Customization](https://help.ubuntu.com/community/Openbox)
- [Plank Dock](https://launchpad.net/plank)
- [Chromium Kiosk Mode](https://www.chromium.org/administrators/policy-list-3)
- [Linux User Management](https://www.debian.org/doc/manuals/debian-reference/ch04.en.html)
