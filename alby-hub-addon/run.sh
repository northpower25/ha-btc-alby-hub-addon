#!/usr/bin/env bashio
set -e

# ──────────────────────────────────────────────
# Read add-on options (injected by HA Supervisor)
# ──────────────────────────────────────────────
LOG_LEVEL=$(bashio::config 'log_level')
NOSTR_RELAY_ENABLED=$(bashio::config 'nostr_relay_enabled')
BACKUP_PASSPHRASE=$(bashio::config 'backup_passphrase')
EXTERNAL_ACCESS_ENABLED=$(bashio::config 'external_access_enabled')
BITCOIN_NETWORK=$(bashio::config 'bitcoin_network')
NODE_BACKEND=$(bashio::config 'node_backend')

LND_REST_URL=$(bashio::config 'lnd_rest_url')
LND_MACAROON_HEX=$(bashio::config 'lnd_macaroon_hex')
LND_TLS_CERT=$(bashio::config 'lnd_tls_cert')

bashio::log.info "Starting Alby Hub add-on..."
bashio::log.info "  Network   : ${BITCOIN_NETWORK}"
bashio::log.info "  Backend   : ${NODE_BACKEND}"
bashio::log.info "  NOSTR     : ${NOSTR_RELAY_ENABLED}"
bashio::log.info "  External  : ${EXTERNAL_ACCESS_ENABLED}"

# ──────────────────────────────────────────────
# Persistent data directory (survives restarts)
# ──────────────────────────────────────────────
DATA_DIR="/addon_configs/$(bashio::addon.slug)"
mkdir -p "${DATA_DIR}/hub" "${DATA_DIR}/nostr" "${DATA_DIR}/backups"

# ──────────────────────────────────────────────
# Build Alby Hub environment
# ──────────────────────────────────────────────
export WORK_DIR="${DATA_DIR}/hub"
export PORT=8080
export LOG_LEVEL="${LOG_LEVEL}"
export BITCOIN_NETWORK="${BITCOIN_NETWORK}"
export LN_BACKEND_TYPE="${NODE_BACKEND}"

# Bind to all interfaces only when external access is requested
if bashio::var.true "${EXTERNAL_ACCESS_ENABLED}"; then
    export BIND_ADDRESS="0.0.0.0"
    bashio::log.warning "External access is ENABLED – ensure your firewall is configured!"
else
    export BIND_ADDRESS="127.0.0.1"
fi

# Pass through LND credentials when using LND backend
if [ -n "${LND_REST_URL}" ]; then
    export LND_ADDRESS="${LND_REST_URL}"
fi
if [ -n "${LND_MACAROON_HEX}" ]; then
    export LND_MACAROON_HEX="${LND_MACAROON_HEX}"
fi
if [ -n "${LND_TLS_CERT}" ]; then
    export LND_TLS_CERT_HEX="${LND_TLS_CERT}"
fi

# Encrypt backups when a passphrase is set
if [ -n "${BACKUP_PASSPHRASE}" ]; then
    export BACKUP_ENCRYPTION_KEY="${BACKUP_PASSPHRASE}"
    bashio::log.info "Backup encryption is ENABLED"
fi

# ──────────────────────────────────────────────
# Optional NOSTR relay
# ──────────────────────────────────────────────
if bashio::var.true "${NOSTR_RELAY_ENABLED}"; then
    bashio::log.info "Starting NOSTR relay on port 3334..."
    NOSTR_DATA_DIR="${DATA_DIR}/nostr" /opt/nostr-relay/start.sh &
fi

# ──────────────────────────────────────────────
# Wait-for-API helper used by HA integration probe
# ──────────────────────────────────────────────
wait_for_hub() {
    local retries=30
    local i=0
    while [ $i -lt $retries ]; do
        if curl -sf "http://localhost:8080/api/health" >/dev/null 2>&1; then
            bashio::log.info "Alby Hub API is ready."
            return 0
        fi
        i=$((i + 1))
        sleep 2
    done
    bashio::log.error "Alby Hub did not start within 60 seconds."
    return 1
}

# ──────────────────────────────────────────────
# Start Alby Hub (the base image entrypoint)
# ──────────────────────────────────────────────
bashio::log.info "Launching Alby Hub..."
exec /app/hub &
HUB_PID=$!

wait_for_hub

bashio::log.info "Alby Hub is running (PID ${HUB_PID})"

# Keep the container alive; forward signals cleanly
wait "${HUB_PID}"
