#!/usr/bin/env bash
set -euo pipefail

# Run with Docker (recommended if godot not installed locally)
if ! command -v godot &>/dev/null; then
  echo "Godot not found locally. Running via Docker..."
  docker compose up --build
  exit 0
fi

godot --path .
