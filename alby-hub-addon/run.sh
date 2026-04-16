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
# Mode: CLOUD – Externer Hub via NWC Connection String
#
# Kein lokaler Lightning-Node. Das Add-on verbindet sich über
# Nostr Wallet Connect (NWC) mit einem externen Alby Hub.
#
# NWC-String bekommt man so:
#   1. Account erstellen: https://albyhub.com
#   2. Hub-Dashboard → Apps → "Add Connection"
#   3. Berechtigungen wählen (get_info, get_balance, make_invoice, pay_invoice, …)
#   4. Generierten NWC-String (nostr+walletconnect://...) kopieren
#   5. String als "nwc_connection_string" in den Add-on-Optionen eintragen
# ──────────────────────────────────────────────
if [ "${NODE_MODE}" = "cloud" ]; then
    bashio::log.info "Running in CLOUD MODE (external Alby Hub via NWC)"
    bashio::log.info "  → No local Lightning node is started."
    bashio::log.info "  → The HA integration communicates via the NWC connection string."

    NWC_CONNECTION_STRING=$(bashio::config 'nwc_connection_string')
    if [ -z "${NWC_CONNECTION_STRING}" ]; then
        bashio::log.error "Cloud mode requires 'nwc_connection_string' to be configured!"
        bashio::log.error ""
        bashio::log.error "How to get your NWC connection string:"
        bashio::log.error "  1. Go to https://albyhub.com and create/log in to your account"
        bashio::log.error "  2. Open your Hub dashboard → 'Apps' in the left menu"
        bashio::log.error "  3. Click 'Add Connection', enter name e.g. 'Home Assistant'"
        bashio::log.error "  4. Select permissions: get_info, get_balance, list_transactions,"
        bashio::log.error "     make_invoice, pay_invoice (adjust as needed)"
        bashio::log.error "  5. Copy the connection string: nostr+walletconnect://..."
        bashio::log.error "  6. Paste it into the 'nwc_connection_string' add-on option"
        exit 1
    fi

    # Validate NWC URI scheme
    if ! echo "${NWC_CONNECTION_STRING}" | grep -q "^nostr+walletconnect://"; then
        bashio::log.error "Invalid nwc_connection_string: must start with 'nostr+walletconnect://'"
        bashio::log.error "Example: nostr+walletconnect://<pubkey>?relay=wss://relay.getalby.com/v1&secret=<secret>"
        exit 1
    fi

    # Export for HA integration to pick up via the supervisor API
    export NWC_CONNECTION_STRING="${NWC_CONNECTION_STRING}"

    bashio::log.info "NWC connection string is configured."
    bashio::log.info "The HA integration will use this string to connect to your hub."

    # In cloud mode no local hub process runs.
    # The add-on container stays alive to serve as a configuration/secrets store
    # and to forward the NWC string to the HA integration via the supervisor options API.
    bashio::log.info "Cloud mode: add-on container running as NWC bridge (no local Hub process)."
    while true; do sleep 60; done

# ──────────────────────────────────────────────
# Mode: EXPERT – Lokaler Alby Hub mit eigenem Node
#
# Alby Hub läuft vollständig lokal auf dem HA-Host.
# Das Web-UI ist über HA-Ingress oder localhost:8080 erreichbar.
#
# Ersten NWC-String für die HA-Integration so erzeugen:
#   1. HA-Panel "Alby Hub" öffnen (Ingress) oder http://homeassistant.local:8080
#   2. Unlock-Passwort setzen (Erststart)
#   3. Apps → "Add Connection" → Name: "HA Integration"
#   4. NWC-String kopieren und in der HA-Integration eintragen
# ──────────────────────────────────────────────
elif [ "${NODE_MODE}" = "expert" ]; then
    NODE_BACKEND=$(bashio::config 'node_backend')
    BITCOIN_NETWORK=$(bashio::config 'bitcoin_network')
    HUB_UNLOCK_PASSWORD=$(bashio::config 'hub_unlock_password')

    bashio::log.info "Running in EXPERT MODE (local Alby Hub)"
    bashio::log.info "  Backend   : ${NODE_BACKEND}"
    bashio::log.info "  Network   : ${BITCOIN_NETWORK}"

    export BITCOIN_NETWORK="${BITCOIN_NETWORK}"
    export LN_BACKEND_TYPE="${NODE_BACKEND}"
    export NETWORK="${BITCOIN_NETWORK}"

    # Auto-unlock on restart if password is set
    if [ -n "${HUB_UNLOCK_PASSWORD}" ]; then
        export AUTO_UNLOCK_PASSWORD="${HUB_UNLOCK_PASSWORD}"
        bashio::log.info "Auto-unlock is ENABLED (hub will unlock automatically on start)"
    fi

    case "${NODE_BACKEND}" in
      LDK)
        bashio::log.info "  Using embedded LDK backend (no external node required)."
        ;;
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
      Phoenixd)
        PHOENIXD_URL=$(bashio::config 'phoenixd_url')
        PHOENIXD_PASSWORD=$(bashio::config 'phoenixd_password')
        if [ -z "${PHOENIXD_URL}" ] || [ -z "${PHOENIXD_PASSWORD}" ]; then
            bashio::log.error "Phoenixd backend requires 'phoenixd_url' and 'phoenixd_password'!"
            exit 1
        fi
        export PHOENIXD_ADDRESS="${PHOENIXD_URL}"
        export PHOENIXD_API_PASSWORD="${PHOENIXD_PASSWORD}"
        bashio::log.info "  Phoenixd  : ${PHOENIXD_URL}"
        ;;
      Cashu)
        bashio::log.info "  Using Cashu Ecash backend (experimental)."
        ;;
      *)
        bashio::log.error "Unknown node_backend: '${NODE_BACKEND}'"
        exit 1
        ;;
    esac

    # Use local Nostr relay for NWC (avoids cloud relay dependency)
    export RELAY="ws://localhost:7447/v1,wss://relay.getalby.com/v1"

    # ── Optional NOSTR relay ──
    if bashio::var.true "${NOSTR_RELAY_ENABLED}"; then
        bashio::log.info "Starting NOSTR relay on port 3334..."
        NOSTR_DATA_DIR="${DATA_DIR}/nostr" /opt/nostr-relay/start.sh &
    fi

    # ── Wait-for-API helper ──
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
        bashio::log.error "Alby Hub did not become ready within 60 seconds."
        return 1
    }

    # ── Start Alby Hub ──
    bashio::log.info "Launching Alby Hub (local)..."
    /app/hub &
    HUB_PID=$!

    wait_for_hub

    bashio::log.info "Alby Hub is running (PID ${HUB_PID})"
    bashio::log.info "Web UI available at: http://homeassistant.local:8080 (or via HA Ingress)"
    bashio::log.info "After first unlock: Apps → Add Connection → create NWC string for HA Integration"

    # Keep the container alive; forward signals cleanly
    wait "${HUB_PID}"

else
    bashio::log.error "Unknown node_mode: '${NODE_MODE}'. Must be 'cloud' or 'expert'."
    exit 1
fi
