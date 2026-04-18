#!/usr/bin/env bash
set -euo pipefail
exec firejail --quiet --net=none --private-bin=kolourpaint kolourpaint
