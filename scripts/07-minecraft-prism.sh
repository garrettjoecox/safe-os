#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get install -y --no-install-recommends ca-certificates curl gpg openjdk-21-jre

# Prism Launcher's community apt repo. The URL picks the right pool using
# the running system's codename (noble on 24.04, questing on 25.10, etc).
install -d -m 0755 /usr/share/keyrings
if [[ ! -f /usr/share/keyrings/prismlauncher-archive-keyring.gpg ]]; then
  curl -fsSL --output /usr/share/keyrings/prismlauncher-archive-keyring.gpg \
    https://prism-launcher-for-debian.github.io/repo/prismlauncher.gpg
fi

codename="$(. /etc/os-release; echo "${UBUNTU_CODENAME:-${DEBIAN_CODENAME:-${VERSION_CODENAME}}}")"
echo "deb [signed-by=/usr/share/keyrings/prismlauncher-archive-keyring.gpg] https://prism-launcher-for-debian.github.io/repo ${codename} main" \
  > /etc/apt/sources.list.d/prismlauncher.list

# Clean up the old apt.prismlauncher.org layout if it was left by a previous run.
rm -f /etc/apt/keyrings/prismlauncher-archive-keyring.gpg \
      /etc/apt/sources.list.d/prismlauncher.sources

apt-get update
apt-get install -y --no-install-recommends prismlauncher
