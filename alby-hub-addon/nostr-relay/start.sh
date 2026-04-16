#!/usr/bin/env bash
set -euo pipefail

TARGET_WS="${1:-ws://127.0.0.1:7447/v1}"
LISTEN_PORT="${2:-3334}"
LISTEN_HOST="${NOSTR_LISTEN_HOST:-0.0.0.0}"

if ! command -v websocat >/dev/null 2>&1; then
  echo "ERROR: websocat is required but not installed."
  exit 1
fi

echo "Starting NOSTR relay proxy on ${LISTEN_HOST}:${LISTEN_PORT} -> ${TARGET_WS}"
exec websocat -E -s "${LISTEN_HOST}:${LISTEN_PORT}" "${TARGET_WS}"
