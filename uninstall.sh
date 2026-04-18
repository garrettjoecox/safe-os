#!/usr/bin/env bash
# safe-os uninstaller. Reverses everything install.sh/scripts/*.sh write to
# the system. Idempotent: re-running is safe and fixes partial state.
#
#   sudo ./uninstall.sh            # keep /home/kid intact
#   sudo ./uninstall.sh --purge-kid  # also delete the kid user and home
#   sudo ./uninstall.sh --yes        # skip the interactive confirmation
#
# What this does NOT do:
#   * Remove apt packages installed in step 02 (xserver-xorg, openbox, tint2,
#     firejail, etc.) — they may have been present before install or wanted
#     independently. Remove manually with apt if desired.
#   * Remove the flathub remote — other flatpaks may depend on it.
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Must run as root (use sudo)." >&2
  exit 1
fi

PURGE_KID=0
ASSUME_YES=0
for arg in "$@"; do
  case "$arg" in
    --purge-kid) PURGE_KID=1 ;;
    --yes|-y)    ASSUME_YES=1 ;;
    -h|--help)
      sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) echo "unknown flag: $arg" >&2; exit 2 ;;
  esac
done

if [[ "$ASSUME_YES" -ne 1 ]]; then
  echo "This will remove safe-os lockdowns, launchers, Chromium/Prism installs,"
  echo "sudoers drop-ins, and kid-session configuration."
  if [[ "$PURGE_KID" -eq 1 ]]; then
    echo "*** --purge-kid: the 'kid' user and /home/kid will be DELETED. ***"
  else
    echo "The 'kid' user and /home/kid will be preserved."
  fi
  read -r -p "Continue? [y/N] " reply
  [[ "$reply" == "y" || "$reply" == "Y" ]] || { echo "Aborted."; exit 1; }
fi

say() { echo; echo "==> $*"; }

say "Removing launchers and desktop entries"
rm -f /usr/local/bin/safe-pbskids \
      /usr/local/bin/safe-minecraft \
      /usr/local/bin/safe-scratch \
      /usr/local/bin/safe-gedit \
      /usr/local/bin/safe-kolourpaint \
      /usr/local/bin/safe-os-session
rm -f /usr/local/share/applications/safe-*.desktop
update-desktop-database /usr/local/share/applications 2>/dev/null || true

say "Removing parent-escape binaries, state, and sudoers rule"
rm -f /usr/local/bin/parent-mode \
      /usr/local/bin/set-parent-password \
      /usr/local/sbin/safe-os-priv \
      /etc/sudoers.d/20-safe-os-priv
rm -rf /etc/safe-os /var/lib/safe-os

say "Removing Chromium managed policies"
rm -f /etc/chromium/policies/managed/pbskids.json \
      /etc/chromium-browser/policies/managed/pbskids.json
# Leave the managed/ dirs themselves — other tools may populate them.

say "Removing Chromium flatpak override and uninstalling the flatpak"
if command -v flatpak >/dev/null 2>&1; then
  flatpak override --system --reset org.chromium.Chromium 2>/dev/null || true
  flatpak uninstall --system --noninteractive --delete-data org.chromium.Chromium 2>/dev/null || true
  flatpak uninstall --system --noninteractive --delete-data edu.mit.Scratch 2>/dev/null || true
fi

say "Removing Prism Launcher package and apt repo"
export DEBIAN_FRONTEND=noninteractive
if dpkg -s prismlauncher >/dev/null 2>&1; then
  apt-get purge -y prismlauncher || true
fi
rm -f /usr/share/keyrings/prismlauncher-archive-keyring.gpg \
      /etc/apt/keyrings/prismlauncher-archive-keyring.gpg \
      /etc/apt/sources.list.d/prismlauncher.list \
      /etc/apt/sources.list.d/prismlauncher.sources
apt-get update -qq || true

say "Restoring dconf automount defaults"
rm -f /etc/dconf/profile/user \
      /etc/dconf/db/kid.d/00-no-automount \
      /etc/dconf/db/kid
rmdir --ignore-fail-on-non-empty /etc/dconf/db/kid.d 2>/dev/null || true
dconf update 2>/dev/null || true

say "Re-enabling VT switching, SysRq, and Ctrl+Alt+Del"
rm -f /etc/X11/xorg.conf.d/10-no-vt-switch.conf
rm -f /etc/sysctl.d/99-no-sysrq.conf
sysctl --system >/dev/null || true
systemctl unmask ctrl-alt-del.target >/dev/null || true
for tty in tty2 tty3 tty4 tty5 tty6; do
  systemctl unmask "getty@${tty}.service" >/dev/null || true
done

say "Removing kid's openbox and tint2 configs"
rm -rf /home/kid/.config/openbox /home/kid/.config/tint2 /home/kid/.config/safe-pbskids

say "Reverting LightDM kiosk config"
rm -f /etc/lightdm/lightdm.conf.d/50-kiosk.conf
rm -f /usr/share/xsessions/openbox-kiosk.desktop
if getent group autologin >/dev/null && id kid >/dev/null 2>&1; then
  gpasswd --delete kid autologin >/dev/null 2>&1 || true
fi

say "Restoring display manager"
# If gdm3 is installed, prefer it (Ubuntu desktop default); otherwise leave
# lightdm alone so the parent isn't locked out of a graphical login.
if dpkg -s gdm3 >/dev/null 2>&1; then
  systemctl disable lightdm >/dev/null 2>&1 || true
  systemctl enable gdm3 >/dev/null 2>&1 || true
  echo "/usr/sbin/gdm3" > /etc/X11/default-display-manager
  DEBIAN_FRONTEND=noninteractive dpkg-reconfigure gdm3 >/dev/null 2>&1 || true
fi

say "Removing sudoers deny rule for kid"
rm -f /etc/sudoers.d/10-no-kid

if [[ "$PURGE_KID" -eq 1 ]]; then
  say "Deleting kid user and home directory"
  if id kid >/dev/null 2>&1; then
    pkill -KILL -u kid 2>/dev/null || true
    userdel -r kid 2>/dev/null || userdel kid 2>/dev/null || true
  fi
  if getent group autologin >/dev/null; then
    # Drop the group only if no members remain.
    if [[ -z "$(getent group autologin | awk -F: '{print $4}')" ]]; then
      groupdel autologin 2>/dev/null || true
    fi
  fi
else
  echo
  echo "Leaving 'kid' user and /home/kid in place. Re-run with --purge-kid to delete."
fi

echo
echo "Uninstall complete. Reboot recommended so display-manager and sysctl changes take full effect."
