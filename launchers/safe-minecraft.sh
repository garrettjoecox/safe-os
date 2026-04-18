#!/usr/bin/env bash
# Prism Launcher with the network namespace severed. Auth tokens cached during
# parent's first online launch keep working, but no new traffic — including
# multiplayer servers, telemetry, or skin downloads — can leave the sandbox.
set -euo pipefail

exec firejail \
  --quiet \
  --noprofile \
  --net=none \
  --dns=127.0.0.1 \
  -- prismlauncher
