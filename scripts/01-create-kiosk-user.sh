#!/usr/bin/env bash
set -euo pipefail

KID_USER="kid"

if ! id "$KID_USER" &>/dev/null; then
  useradd --create-home --shell /bin/bash --comment "Kiosk user" "$KID_USER"
fi

# No password login. Autologin via LightDM bypasses PAM auth.
passwd --lock "$KID_USER" >/dev/null

# Strip from groups that grant hardware/admin access.
for grp in sudo adm dialout cdrom plugdev lpadmin sambashare; do
  gpasswd --delete "$KID_USER" "$grp" &>/dev/null || true
done

# Block sudo even if somehow added later.
install -m 0440 /dev/stdin /etc/sudoers.d/10-no-kid <<EOF
$KID_USER ALL=(ALL) !ALL
EOF
visudo -cf /etc/sudoers.d/10-no-kid >/dev/null
