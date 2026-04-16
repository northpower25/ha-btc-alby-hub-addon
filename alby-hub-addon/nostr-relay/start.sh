#!/usr/bin/env bash
set -euo pipefail

TARGET_WS="${1:-ws://127.0.0.1:7447/v1}"
LISTEN_PORT="${2:-3334}"
LISTEN_HOST="${NOSTR_LISTEN_HOST:-0.0.0.0}"

if ! command -v websocat >/dev/null 2>&1; then
  echo "ERROR: websocat is required but not installed."
  exit 1
fi

if ! echo "${TARGET_WS}" | grep -Eq '^wss?://'; then
  echo "ERROR: TARGET_WS must start with ws:// or wss://"
  exit 1
fi

if ! echo "${LISTEN_PORT}" | grep -Eq '^[1-9][0-9]*$'; then
  echo "ERROR: LISTEN_PORT must be a positive number"
  exit 1
fi

if [ "${LISTEN_PORT}" -gt 65535 ]; then
  echo "ERROR: LISTEN_PORT must be <= 65535"
  exit 1
fi

echo "Starting NOSTR relay proxy on ${LISTEN_HOST}:${LISTEN_PORT} -> ${TARGET_WS}"
exec websocat -E -s "${LISTEN_HOST}:${LISTEN_PORT}" "${TARGET_WS}"
