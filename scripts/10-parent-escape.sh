#!/usr/bin/env bash
set -euo pipefail

install -d -m 0755 /etc/safe-os
install -d -m 0755 /var/lib/safe-os
chown root:root /etc/safe-os /var/lib/safe-os

install -m 0755 "$REPO_DIR/bin/parent-mode"          /usr/local/bin/parent-mode
install -m 0755 "$REPO_DIR/bin/set-parent-password"  /usr/local/bin/set-parent-password
install -m 0755 "$REPO_DIR/bin/safe-os-priv"         /usr/local/sbin/safe-os-priv

# Permit kid -> safe-os-priv only. Filename sorts after 10-no-kid so this
# more-specific allow rule wins per sudoers last-match semantics.
install -m 0440 /dev/stdin /etc/sudoers.d/20-safe-os-priv <<'EOF'
kid ALL=(root) NOPASSWD: /usr/local/sbin/safe-os-priv
Defaults!/usr/local/sbin/safe-os-priv !requiretty
EOF
visudo -cf /etc/sudoers.d/20-safe-os-priv >/dev/null

# parent-mode reads the hash file (root-owned, mode 600 — kid can never read it).
if [[ ! -f /etc/safe-os/parent.hash ]]; then
  echo "WARN: /etc/safe-os/parent.hash missing. Run set-parent-password before reboot."
fi
