## What is this?

This project compiles my list of notes and scripts for curating a safe, sandboxed computing environment for my children.

## Features

- ✅ Boot straight into a limited desktop environment, without access to Terminal, Settings, an App Store, or other system-level features
- ✅ Typical keybindings disabled (no Alt+Tab, Ctrl+Alt+Del, virtual terminals, etc.)
- ✅ Right-click context menus disabled
- ✅ Password-protected parent escape hatch (Ctrl+Alt+Shift+P)
- ✅ Curated application dock with:
  - Minecraft (offline mode with network disabled)
  - Scratch Desktop
  - Notepad (gedit)
  - Paint (GIMP)
  - PBS Kids (kiosk-mode web browser locked to pbskids.org)

## Technologies Used

- **Base OS**: Ubuntu 24.04 LTS
- **Desktop Environment**: Openbox (lightweight, highly configurable window manager)
- **Display Manager**: LightDM with autologin
- **Application Dock**: Plank
- **Browser**: Chromium in kiosk mode
- **Security**: User permissions, AppArmor, firewall rules

## Quick Start

### Prerequisites
- USB drive (4GB+) for Ubuntu installation
- Target computer for the safe environment
- Basic command line familiarity

### Installation Steps

1. **Download and create Ubuntu installation media**
   - See [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md) for detailed instructions

2. **Install Ubuntu on target computer**
   - Use minimal installation
   - Create parent admin account

3. **Run the automated setup script**
   ```bash
   sudo ./scripts/setup.sh
   ```

4. **Reboot and test**
   ```bash
   sudo reboot
   ```

The system will automatically log in as the `child` user with restricted access.

## Documentation

- **[IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md)** - Technical architecture and component overview
- **[INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md)** - Step-by-step installation instructions
- **[ADVANCED_CONFIG.md](ADVANCED_CONFIG.md)** - Advanced configuration, troubleshooting, and enhancements

## Project Structure

```
safe-os/
├── README.md                    # This file
├── IMPLEMENTATION_PLAN.md       # Technical architecture
├── INSTALLATION_GUIDE.md        # Installation instructions
├── ADVANCED_CONFIG.md          # Advanced configuration
├── configs/
│   ├── openbox-rc.xml          # Openbox window manager config (locked down)
│   └── openbox-menu.xml        # Disabled right-click menu
├── desktop-files/
│   ├── pbskids.desktop         # PBS Kids launcher
│   ├── minecraft.desktop       # Minecraft launcher
│   ├── scratch.desktop         # Scratch launcher
│   ├── paint.desktop           # Paint (GIMP) launcher
│   └── notepad.desktop         # Notepad (gedit) launcher
└── scripts/
    ├── setup.sh                # Automated installation script
    └── bin/
        ├── launch-pbskids.sh   # Kiosk browser for PBS Kids
        ├── launch-minecraft.sh # Minecraft offline launcher
        ├── launch-scratch.sh   # Scratch launcher
        ├── launch-paint.sh     # Paint launcher
        ├── launch-notepad.sh   # Notepad launcher
        ├── parent-escape.sh    # Parent access trigger
        └── parent-menu.sh      # Parent control panel
```

## Parent Access

### Escape Hatch
Press **Ctrl+Alt+Shift+P** from the child environment to open the parent control menu (requires password).

From the parent menu you can:
- Open system settings
- Open file manager
- Open terminal
- Install software
- Switch to parent account
- Shutdown/restart computer

## Security Features

- No terminal access
- No file manager (or heavily restricted)
- No system settings access
- Disabled keyboard shortcuts (Alt+Tab, Ctrl+Alt+F1-F6, etc.)
- No right-click menus
- Network restrictions for specific apps
- Separate user accounts with minimal permissions

## Customization

### Adding New Applications

1. Create launcher script in `scripts/bin/`
2. Create .desktop file in `desktop-files/`
3. Copy to system during setup
4. Add icon to Plank dock

### Modifying Restrictions

Edit `configs/openbox-rc.xml` to:
- Add/remove keyboard shortcuts
- Enable/disable specific features
- Adjust window behavior

## Contributing

This is a personal project, but suggestions and improvements are welcome! Feel free to:
- Report issues
- Suggest enhancements
- Share your configurations

## License

This project is provided as-is for personal use. Modify and adapt as needed for your family's requirements.

## Disclaimer

While this system provides a restricted environment, no security solution is perfect. Adult supervision is always recommended when children use computers. Test thoroughly and adjust based on your specific needs and your children's technical abilities.
