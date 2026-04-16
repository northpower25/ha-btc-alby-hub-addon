ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install additional utilities for the HA add-on wrapper
RUN apk add --no-cache \
    bash \
    curl \
    jq \
    openssl \
    ca-certificates \
    websocat \
    && rm -rf /var/cache/apk/*

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
