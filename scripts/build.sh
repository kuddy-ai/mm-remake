#!/usr/bin/env bash
set -euo pipefail
PLATFORM="${1:-linux}"
MODE="${2:-debug}"
echo "[build] platform=${PLATFORM} mode=${MODE}"

case "${PLATFORM}" in
  windows|win|win64)
    PRESET="Windows Desktop"
    OUTPUT_DIR="build/windows"
    EXE_OUTPUT="${OUTPUT_DIR}/mm-remake.exe"
    PCK_OUTPUT="${OUTPUT_DIR}/mm-remake.pck"
    SMB_CONTAINER="${SMB_CONTAINER:-samba}"
    SMB_OUTPUT_DIR="${SMB_OUTPUT_DIR:-/share/mm-remake/windows}"
    ;;
  *)
    echo "Unsupported platform: ${PLATFORM}" >&2
    echo "Supported platforms: windows" >&2
    exit 1
    ;;
esac

mkdir -p "${OUTPUT_DIR}"

GODOT_BIN="${GODOT_BIN:-godot}"
if ! command -v "${GODOT_BIN}" >/dev/null 2>&1 && [[ -x "/tmp/godot-build/godot-linux/Godot_v4.6.2-stable_linux.x86_64" ]]; then
  GODOT_BIN="/tmp/godot-build/godot-linux/Godot_v4.6.2-stable_linux.x86_64"
fi

GODOT_HOME="${GODOT_HOME:-/tmp}"

if [[ ! -f "${EXE_OUTPUT}" ]]; then
  if [[ "${MODE}" == "release" ]]; then
    env HOME="${GODOT_HOME}" "${GODOT_BIN}" --headless --path . --export-release "${PRESET}" "${EXE_OUTPUT}"
  else
    env HOME="${GODOT_HOME}" "${GODOT_BIN}" --headless --path . --export-debug "${PRESET}" "${EXE_OUTPUT}"
  fi
else
  echo "[build] reusing ${EXE_OUTPUT}"
fi

env HOME="${GODOT_HOME}" "${GODOT_BIN}" --headless --path . --export-pack "${PRESET}" "${PCK_OUTPUT}"

docker exec "${SMB_CONTAINER}" sh -lc "mkdir -p '${SMB_OUTPUT_DIR}'"
docker cp "${EXE_OUTPUT}" "${SMB_CONTAINER}:${SMB_OUTPUT_DIR}/mm-remake.exe"
docker cp "${PCK_OUTPUT}" "${SMB_CONTAINER}:${SMB_OUTPUT_DIR}/mm-remake.pck"
docker exec "${SMB_CONTAINER}" sh -lc "chown -R ${SMB_USER:-smbuser}:${SMB_GROUP:-smb} '${SMB_OUTPUT_DIR}' && chmod -R ug+rwX '${SMB_OUTPUT_DIR}'"

echo "[build] wrote ${EXE_OUTPUT}"
echo "[build] wrote ${PCK_OUTPUT}"
echo "[build] copied to ${SMB_CONTAINER}:${SMB_OUTPUT_DIR}"
