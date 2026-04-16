#!/usr/bin/env bashio
set -e

# ──────────────────────────────────────────────
# Read add-on options (injected by HA Supervisor)
# ──────────────────────────────────────────────
NODE_MODE=$(bashio::config 'node_mode')
LOG_LEVEL=$(bashio::config 'log_level')
NOSTR_RELAY_ENABLED=$(bashio::config 'nostr_relay_enabled')
BACKUP_PASSPHRASE=$(bashio::config 'backup_passphrase')
EXTERNAL_ACCESS_ENABLED=$(bashio::config 'external_access_enabled')

bashio::log.info "Starting Alby Hub add-on..."
bashio::log.info "  Mode      : ${NODE_MODE}"
bashio::log.info "  NOSTR     : ${NOSTR_RELAY_ENABLED}"
bashio::log.info "  External  : ${EXTERNAL_ACCESS_ENABLED}"

# ──────────────────────────────────────────────
# Persistent data directory (survives restarts)
# ──────────────────────────────────────────────
DATA_DIR="/addon_configs/$(bashio::addon.slug)"
mkdir -p "${DATA_DIR}/hub" "${DATA_DIR}/nostr" "${DATA_DIR}/backups"

# ──────────────────────────────────────────────
# Common Alby Hub environment
# ──────────────────────────────────────────────
export WORK_DIR="${DATA_DIR}/hub"
export PORT=8080
export LOG_LEVEL="${LOG_LEVEL}"

# Bind to all interfaces only when external access is requested
if bashio::var.true "${EXTERNAL_ACCESS_ENABLED}"; then
    export BIND_ADDRESS="0.0.0.0"
    bashio::log.warning "External access is ENABLED – ensure your firewall is configured!"
else
    export BIND_ADDRESS="127.0.0.1"
fi

# Encrypt backups when a passphrase is set
if [ -n "${BACKUP_PASSPHRASE}" ]; then
    export BACKUP_ENCRYPTION_KEY="${BACKUP_PASSPHRASE}"
    bashio::log.info "Backup encryption is ENABLED"
fi

# ──────────────────────────────────────────────
# Mode: CLOUD (getAlby account, no own node)
# ──────────────────────────────────────────────
if [ "${NODE_MODE}" = "cloud" ]; then
    bashio::log.info "Running in CLOUD MODE (getAlby account)"
    bashio::log.info "  → No own Lightning node required."
    bashio::log.info "  → Funds are held with getAlby (non-self-custodial)."

    ALBY_API_KEY=$(bashio::config 'alby_api_key')
    if [ -z "${ALBY_API_KEY}" ]; then
        bashio::log.error "Cloud mode requires 'alby_api_key' to be set!"
        bashio::log.error "Get your API key at: https://www.getalby.com/account"
        exit 1
    fi

    export LN_BACKEND_TYPE="AlbyHub"
    export ALBY_OAUTH_TOKEN="${ALBY_API_KEY}"

# ──────────────────────────────────────────────
# Mode: EXPERT (own node – full self-custody)
# ──────────────────────────────────────────────
elif [ "${NODE_MODE}" = "expert" ]; then
    NODE_BACKEND=$(bashio::config 'node_backend')
    BITCOIN_NETWORK=$(bashio::config 'bitcoin_network')

    bashio::log.info "Running in EXPERT MODE (own Lightning node)"
    bashio::log.info "  Backend   : ${NODE_BACKEND}"
    bashio::log.info "  Network   : ${BITCOIN_NETWORK}"

    export BITCOIN_NETWORK="${BITCOIN_NETWORK}"
    export LN_BACKEND_TYPE="${NODE_BACKEND}"

    case "${NODE_BACKEND}" in
      LND)
        LND_REST_URL=$(bashio::config 'lnd_rest_url')
        LND_MACAROON_HEX=$(bashio::config 'lnd_macaroon_hex')
        LND_TLS_CERT=$(bashio::config 'lnd_tls_cert')
        if [ -z "${LND_REST_URL}" ] || [ -z "${LND_MACAROON_HEX}" ]; then
            bashio::log.error "LND backend requires 'lnd_rest_url' and 'lnd_macaroon_hex'!"
            exit 1
        fi
        export LND_ADDRESS="${LND_REST_URL}"
        export LND_MACAROON_HEX="${LND_MACAROON_HEX}"
        [ -n "${LND_TLS_CERT}" ] && export LND_TLS_CERT_HEX="${LND_TLS_CERT}"
        bashio::log.info "  LND URL   : ${LND_REST_URL}"
        ;;
      CLN)
        CLN_REST_URL=$(bashio::config 'cln_rest_url')
        CLN_RUNE=$(bashio::config 'cln_rune')
        if [ -z "${CLN_REST_URL}" ] || [ -z "${CLN_RUNE}" ]; then
            bashio::log.error "CLN backend requires 'cln_rest_url' and 'cln_rune'!"
            exit 1
        fi
        export CLN_ADDRESS="${CLN_REST_URL}"
        export CLN_RUNE="${CLN_RUNE}"
        bashio::log.info "  CLN URL   : ${CLN_REST_URL}"
        ;;
      LDK)
        bashio::log.info "  Using embedded LDK backend (no external node required)."
        ;;
      Breez)
        bashio::log.info "  Using Breez SDK backend."
        ;;
      Greenlight)
        bashio::log.info "  Using Blockstream Greenlight backend."
        ;;
      *)
        bashio::log.error "Unknown node_backend: '${NODE_BACKEND}'"
        exit 1
        ;;
    esac

else
    bashio::log.error "Unknown node_mode: '${NODE_MODE}'. Must be 'cloud' or 'expert'."
    exit 1
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
/app/hub &
HUB_PID=$!

wait_for_hub

bashio::log.info "Alby Hub is running (PID ${HUB_PID})"

# Keep the container alive; forward signals cleanly
wait "${HUB_PID}"
