#!/usr/bin/env bash
set -euo pipefail

# System-wide so kid can launch without per-user flatpak overrides.
flatpak install --system --noninteractive --or-update flathub edu.mit.Scratch
