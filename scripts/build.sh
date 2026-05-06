#!/usr/bin/env bash
set -euo pipefail
PLATFORM="${1:-linux}"
MODE="${2:-debug}"
echo "[build] platform=${PLATFORM} mode=${MODE}"
# TODO: replace with real Godot export preset command
# godot --headless --path . --export-${MODE} "${PLATFORM}" "build/${PLATFORM}/game"
