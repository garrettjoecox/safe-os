#!/usr/bin/env bash
set -euo pipefail

# Xorg: kill VT switching and the Ctrl+Alt+Backspace zap.
install -d -m 0755 /etc/X11/xorg.conf.d
install -m 0644 "$REPO_DIR/config/xorg/10-no-vt-switch.conf" /etc/X11/xorg.conf.d/10-no-vt-switch.conf

# Magic SysRq off.
install -m 0644 "$REPO_DIR/config/sysctl/99-no-sysrq.conf" /etc/sysctl.d/99-no-sysrq.conf
sysctl --system >/dev/null

# Ctrl+Alt+Del should not reboot.
systemctl mask ctrl-alt-del.target >/dev/null

# Disable spare gettys so even if VT switching ever leaks, there's no shell waiting.
for tty in tty2 tty3 tty4 tty5 tty6; do
  systemctl mask "getty@${tty}.service" >/dev/null
done

# Block automounting of removable media for the kid user.
install -d -m 0755 /etc/dconf/profile /etc/dconf/db/kid.d
install -m 0644 "$REPO_DIR/config/openbox/dconf-profile-user" /etc/dconf/profile/user
install -m 0644 "$REPO_DIR/config/openbox/dconf-no-automount" /etc/dconf/db/kid.d/00-no-automount
dconf update
