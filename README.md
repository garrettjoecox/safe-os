# safe-os

Locked-down Ubuntu kiosk for kids. Autologins a `kid` user into an Openbox session with a fixed dock (PBS Kids, Minecraft, Scratch, Notepad, Paint) and strips every system keybinding except a parent escape hatch.

See `CLAUDE.md` for architecture, privilege model, and caveats.

## Requirements

- Fresh Ubuntu desktop install, 24.04 or newer (developed on 24.04, tested on 25.10)
- Sudo user (the "parent" account) already created by the Ubuntu installer
- Target hardware: bare-metal x86_64 (tested on Beelink Intel mini-PC)

## Install

From the parent account:

```sh
git clone <this repo> safe-os
cd safe-os
sudo ./install.sh
```

Then:

1. Set the parent password (used for the escape hatch):
   ```sh
   sudo ./bin/set-parent-password
   ```
2. Launch Prism Launcher once as the parent and sign into Microsoft so Minecraft auth tokens cache.
3. Reboot. The `kid` user autologins into the locked session.

## Escape hatch

From the kid session: `Ctrl+Alt+Shift+P` → enter parent password → choose switch-to-greeter, reboot, or shutdown.

## Iterating

Edit files under `config/` or `launchers/` and re-run `sudo ./install.sh`. All steps are idempotent. Log out and back in as `kid` to pick up WM/dock changes.

## Uninstall

From the parent account:

```sh
sudo ./uninstall.sh              # remove kiosk, keep /home/kid
sudo ./uninstall.sh --purge-kid  # also delete the kid user and home
```

Reverses LightDM autologin, all lockdown configs, sudoers drop-ins, Chromium/Prism installs, and kid-session files. Apt packages installed in step 02 are left in place (they may have been present before install) — remove manually with `apt purge` if desired. Reboot afterward so display-manager and sysctl changes take full effect.
