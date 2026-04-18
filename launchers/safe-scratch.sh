#!/usr/bin/env bash
# Scratch Desktop is fully offline by design; flatpak sandbox already isolates it.
set -euo pipefail
exec flatpak run edu.mit.Scratch
