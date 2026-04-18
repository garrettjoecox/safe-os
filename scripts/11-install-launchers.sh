#!/usr/bin/env bash
set -euo pipefail

# Wrapper scripts go to /usr/local/bin so .desktop files can reference them by
# stable absolute paths without a "safe-" prefix collision in PATH.
for s in "$REPO_DIR"/launchers/safe-*.sh; do
  base=$(basename "$s" .sh)
  install -m 0755 "$s" "/usr/local/bin/$base"
done

# .desktop files for tint2 launcher icons. /usr/local/share/applications keeps
# them out of any system app menu we don't control.
install -d -m 0755 /usr/local/share/applications
for d in "$REPO_DIR"/launchers/safe-*.desktop; do
  install -m 0644 "$d" "/usr/local/share/applications/$(basename "$d")"
done

update-desktop-database /usr/local/share/applications 2>/dev/null || true
