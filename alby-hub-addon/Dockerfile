ARG BUILD_FROM=ghcr.io/getalby/hub:latest
FROM ${BUILD_FROM}
ARG TARGETARCH

# Install additional utilities for the HA add-on wrapper
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        bash \
        curl \
        jq \
        openssl \
        ca-certificates; \
    case "${TARGETARCH}" in \
        amd64) WEBSOCAT_ASSET="websocat.x86_64-unknown-linux-musl" ;; \
        arm64) WEBSOCAT_ASSET="websocat.aarch64-unknown-linux-musl" ;; \
        *) WEBSOCAT_ASSET=""; echo "Warning: unsupported architecture for websocat: ${TARGETARCH}"; ;; \
    esac; \
    if [ -n "${WEBSOCAT_ASSET}" ] && curl -fsSL "https://github.com/vi/websocat/releases/download/v1.14.1/${WEBSOCAT_ASSET}" -o /usr/local/bin/websocat; then \
        chmod +x /usr/local/bin/websocat; \
    else \
        echo "Warning: failed to download websocat binary; Nostr relay checks/proxy require websocat."; \
    fi; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# Install nostr-relay (strfry or lightweight Go relay)
# We ship a minimal Go-based relay binary compiled for both amd64/aarch64
COPY nostr-relay/ /opt/nostr-relay/
RUN chmod +x /opt/nostr-relay/start.sh

# Add-on run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Health-check: verify Alby Hub HTTP API responds
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -sf http://localhost:8080/api/health || exit 1

CMD ["/run.sh"]
