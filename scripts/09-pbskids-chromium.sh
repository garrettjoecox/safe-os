#!/usr/bin/env bash
set -euo pipefail

# Chromium reads managed policy JSON from this directory at startup. Owned by
# root, kid can't override. apt-installed chromium also accepts /etc/chromium-browser/.
for d in /etc/chromium/policies/managed /etc/chromium-browser/policies/managed; do
  install -d -m 0755 "$d"
  install -m 0644 "$REPO_DIR/config/chromium/pbskids-policy.json" "$d/pbskids.json"
done
