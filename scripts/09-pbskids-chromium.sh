#!/usr/bin/env bash
set -euo pipefail

# Install Chromium via Flathub. On 25.10 the apt chromium-browser is a snap
# transitional package and the snap sandbox ignores /etc/chromium/policies/managed,
# which would silently void the PBS Kids URL allowlist. The Flathub build reads
# managed policies at startup as long as it can see the host directory.
flatpak install --system --noninteractive --or-update flathub org.chromium.Chromium

# Grant read access to the host-side managed-policy dir so Chromium picks it up.
flatpak override --system --filesystem=/etc/chromium:ro org.chromium.Chromium

# Chromium reads managed policy JSON from this directory at startup. Owned by
# root, kid can't override. We also still write the legacy /etc/chromium-browser
# path for any apt-chromium hosts (24.04) that coexist.
for d in /etc/chromium/policies/managed /etc/chromium-browser/policies/managed; do
  install -d -m 0755 "$d"
  install -m 0644 "$REPO_DIR/config/chromium/pbskids-policy.json" "$d/pbskids.json"
done
