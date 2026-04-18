#!/usr/bin/env bash
# safe-os-2 installer. Run as root on a fresh Ubuntu 24.04 desktop install.
#   sudo ./install.sh
# Idempotent: re-running fixes drift instead of clobbering state.
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Must run as root (use sudo)." >&2
  exit 1
fi

. /etc/os-release
if [[ "${VERSION_ID:-}" != "24.04" ]]; then
  echo "Designed for Ubuntu 24.04 (got ${PRETTY_NAME:-unknown}). Aborting." >&2
  exit 1
fi

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export REPO_DIR

for step in "$REPO_DIR"/scripts/[0-9]*.sh; do
  echo
  echo "==> $(basename "$step")"
  bash "$step"
done

echo
echo "Install complete."
echo "Next:"
echo "  1. Set the parent password:   sudo $REPO_DIR/bin/set-parent-password"
echo "  2. As yourself, run Prism Launcher once and sign into Microsoft so Minecraft auth caches."
echo "  3. Reboot. The 'kid' user will autologin into the locked session."
