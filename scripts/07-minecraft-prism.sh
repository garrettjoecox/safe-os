#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get install -y --no-install-recommends ca-certificates curl gpg openjdk-21-jre

# Prism Launcher's official apt repo (works on noble).
install -d -m 0755 /etc/apt/keyrings
if [[ ! -f /etc/apt/keyrings/prismlauncher-archive-keyring.gpg ]]; then
  curl -fsSL --output /etc/apt/keyrings/prismlauncher-archive-keyring.gpg \
    https://apt.prismlauncher.org/debian/dists/prismlauncher-archive-keyring.gpg
fi
if [[ ! -f /etc/apt/sources.list.d/prismlauncher.sources ]]; then
  curl -fsSL --output /etc/apt/sources.list.d/prismlauncher.sources \
    https://apt.prismlauncher.org/debian/dists/prismlauncher.sources
fi

apt-get update
apt-get install -y --no-install-recommends prismlauncher
