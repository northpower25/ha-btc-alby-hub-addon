# Handbook (EN) – Alby Hub Home Assistant Add-on & Integration

## ⚠️ Beta, Safety, and Risk Notice

- The add-on and integration are currently **beta software**.
- Under certain conditions, **financial losses** can occur.
- Do **not** use large amounts for testing; start with very small test amounts only.
- Common user mistakes:
  - invalid or incomplete NWC connection strings
  - overly broad or missing scopes/permissions
  - wrong network selection (for example mainnet vs testnet)
  - insecure external access configuration
  - weak backup/secret handling
- Potential systemic risks:
  - outages of external services/relays or upstream components
  - network interruptions/instability
  - inconsistent states during restart/recovery
  - unexpected costs caused by routing/fee dynamics
- You are solely responsible for the **safe and responsible use** of the add-on and the related integration.

## Update Safety: What you must back up **before every update**

For every add-on update: back up first, update second.

### Mandatory pre-update checklist

- Create a full Home Assistant backup (including add-on data and add-on configuration).
- Ensure the following values are documented and available:
  - `node_mode`, `node_backend`, `bitcoin_network`
  - `nwc_connection_string` (cloud mode and/or generated app connection)
  - `backup_passphrase` (if set)
  - `hub_unlock_password` (if set)
  - Backend credentials (`lnd_*`, `cln_*`, `phoenixd_*`) if used
- For external backends, also verify their own wallet/node backups (for example LND/CLN/Phoenixd/Cashu per backend documentation).
- After backup, quickly verify restore files and passphrases are actually readable/available.

If this data is missing, recovery after a failed update or reinstallation may fail.

## Where are your funds? (depends on scenario)

### Cloud mode (`node_mode: cloud`)

- Funds are **not** stored in the add-on; they are in the external Alby Hub account/wallet.
- Recovery-critical: access to the external hub account and NWC connection/secrets.

### Expert mode with local LDK

- Funds/wallet state are managed locally by Alby Hub in the persistent add-on data area.
- Recovery-critical: working HA backup including add-on data + known passphrase/unlock data.

### Expert mode with external backend (LND, CLN, Phoenixd, Cashu)

- Funds are primarily in the respective backend system.
- The add-on mainly stores connection data and secrets.
- Recovery-critical: backend node backups + add-on config/credentials.

## Recovery after failed update or reinstallation

1. Reinstall the add-on (use the same/compatible version).
2. Restore backed-up add-on data and add-on configuration.
3. Set the correct operating mode (`cloud` or `expert`) and re-apply all secrets/credentials.
4. Cloud mode: verify/recreate NWC connection.  
   Expert mode: verify backend connection and unlock flow.
5. In the integration, run connectivity checks and verify balance/info.

If funds are not visible after recovery:

- Cloud mode: check the external Alby Hub account first.
- Expert + external backend: check the backend system first.
- Expert + local LDK: check restore state and passphrase/unlock data.

## Target Version and Compatibility

- Minimum supported Home Assistant version (2026.x): **2026.1**
- Applies to the add-on and planned HACS integration in the MVP.

## Add-on vs Integration (quick overview)

- **Add-on (`ha-btc-alby-hub-addon`)**: Provides the Alby Hub service (local add-on runtime or cloud bridge via NWC). This requires Home Assistant with Supervisor/add-on support.
- **Integration (`ha-btc-alby-hub-integration`)**: Connects Alby Hub to Home Assistant (entities, services, automations, dashboard).
- Recommendation: On HA OS/Supervised, usually use **add-on + integration** together; on HA Container, primarily use the **integration** with an external hub.

## Installation and Configuration in Home Assistant (HACS + manual)

### Prerequisites

- Home Assistant **2026.1+** (approved for **2026.x**)
- For add-on usage: Home Assistant with **Supervisor/add-on support** (HA OS or Supervised)
- Network access to:
  - Add-on repository: `https://github.com/northpower25/ha-btc-alby-hub-addon`
  - Integration repository: `https://github.com/northpower25/ha-btc-alby-hub-integration`

### Option A: Install with HACS (recommended for the integration)

#### A1) Install the add-on (first)

1. **Add the add-on repository**  
   In Home Assistant 2026.x:  
   **Settings → Add-ons → Add-on Store → menu (⋮) → Repositories**.
2. **Fill out the repository dialog**  
   In the **Repositories** dialog:
   - **Repository URL**: `https://github.com/northpower25/ha-btc-alby-hub-addon`
   - Type/Category: **Add-on repository**
   - Confirm with **Add**.
3. **Verify the repository entry**  
   Ensure the repository appears in the list, then close the dialog.
4. **Install/start the add-on**  
   Open “Alby Hub (Bitcoin Lightning)”, install, and start it.  
   On first installation, Supervisor may need a few minutes because the add-on image is built locally from this repository.
5. **Configure the add-on**  
   Then complete the section “Configure the add-on (step by step)”.

#### A2) Install the integration (afterwards)

1. **Install HACS** (if not already installed) and restart Home Assistant.
2. **Add the integration repository**  
   In HACS, add a custom repository:  
   `https://github.com/northpower25/ha-btc-alby-hub-integration` (Category: Integration)
3. **Install the integration** and restart Home Assistant.
4. **Set up the integration**  
   Settings → Devices & Services → Add Integration → select Alby Hub integration.

### Option B: Manual installation (without HACS)

#### B1) Install the add-on manually (first)

1. **Provide the add-on**
   - Either add the add-on repository in Add-on Store (same as Option A, A1), or
   - for local development, copy the add-on folder to  
     `/addons/local/alby-hub-addon/` and reload Supervisor.
2. **Install/start the add-on**  
   Open the add-on in Add-on Store, install, and start it.
3. **Configure the add-on**  
   Then complete the section “Configure the add-on (step by step)”.

#### B2) Install the integration manually (afterwards)

1. **Install the integration manually**
   - Download the `ha-btc-alby-hub-integration` repository ZIP.
   - Extract and copy the custom component folder to  
     `/config/custom_components/`.
   - Restart Home Assistant.
2. **Add the integration in “Devices & Services”**.

### Configure the add-on (step by step)

1. Open the add-on and save configuration.
2. Choose mode:
   - **Cloud mode**: set `node_mode: cloud` and `nwc_connection_string`.
   - **Expert mode**: set `node_mode: expert`, backend (`node_backend`), and backend parameters.
3. Start the add-on and check logs.
4. In expert mode: open ingress, perform initial hub setup/unlock, and create an NWC app connection in “Apps”.
5. In the integration, paste the NWC string and run a connectivity test.

## Add-on settings in detail (with direct links from the configuration UI)

<a id="addon-setting-node-mode-en"></a>
### `node_mode`
- `cloud`: No local hub process in the add-on. Requires `nwc_connection_string`.
- `expert`: Alby Hub runs locally in the add-on. Requires backend settings.

<a id="addon-setting-log-level-en"></a>
### `log_level`
- Controls log verbosity.
- For normal use: `info`.
- For troubleshooting: `debug` or `trace` (more detailed logs).

<a id="addon-setting-tor-enabled-en"></a>
### `tor_enabled`
- Enables outbound communication through a proxy (typically Tor SOCKS5).
- Default: `false`.
- Enable only if a reachable Tor/SOCKS proxy exists in your network.

<a id="addon-setting-tor-socks5-url-en"></a>
### `tor_socks5_url`
- Proxy URL for Tor/SOCKS5, for example `socks5h://127.0.0.1:9050`.
- Used only when `tor_enabled: true`.
- `socks5h://` is recommended so DNS is also resolved through Tor.

<a id="addon-setting-nostr-relay-enabled-en"></a>
### `nostr_relay_enabled`
- Starts an additional local NOSTR relay proxy on port `3334`.
- Relevant in expert mode only.

<a id="addon-setting-backup-passphrase-en"></a>
### `backup_passphrase`
- Enables encrypted add-on backups.
- Store safely; restore may fail without it.

<a id="addon-setting-external-access-enabled-en"></a>
### `external_access_enabled`
- `false`: add-on binds locally only.
- `true`: add-on binds to all interfaces (`0.0.0.0`).
- Enable only with proper firewall/network hardening.

<a id="addon-setting-nwc-connection-string-en"></a>
### `nwc_connection_string`
- Mandatory for cloud mode.
- Must start with `nostr+walletconnect://` and include `relay` + `secret`.
- Create it in Alby Hub → Apps → Add Connection.

<a id="addon-setting-bitcoin-network-en"></a>
### `bitcoin_network`
- Relevant in expert mode only.
- Must match your backend and wallet setup (`mainnet`, `testnet`, `signet`, `mutinynet`).

<a id="addon-setting-node-backend-en"></a>
### `node_backend`
- Relevant in expert mode only.
- `LDK`: embedded (easiest start).
- `LND`, `CLN`, `Phoenixd`, `Cashu`: external/alternative backends with dedicated credentials.

<a id="addon-setting-hub-unlock-password-en"></a>
### `hub_unlock_password`
- Optional in expert mode.
- Enables auto-unlock on startup.
- Treat as a secret.

<a id="addon-setting-lnd-rest-url-en"></a>
### `lnd_rest_url`
- Only for `node_backend: LND`.
- REST URL of your LND instance.

<a id="addon-setting-lnd-macaroon-hex-en"></a>
### `lnd_macaroon_hex`
- Only for `node_backend: LND`.
- Macaroon as HEX string for API access.

<a id="addon-setting-lnd-tls-cert-en"></a>
### `lnd_tls_cert`
- Only for `node_backend: LND`.
- Optional TLS certificate (HEX) if your LND API requires explicit TLS validation.

<a id="addon-setting-cln-rest-url-en"></a>
### `cln_rest_url`
- Only for `node_backend: CLN`.
- REST URL of your CLN instance.

<a id="addon-setting-cln-rune-en"></a>
### `cln_rune`
- Only for `node_backend: CLN`.
- Authentication rune for CLN API access.

<a id="addon-setting-phoenixd-url-en"></a>
### `phoenixd_url`
- Only for `node_backend: Phoenixd`.
- URL of your phoenixd instance.

<a id="addon-setting-phoenixd-password-en"></a>
### `phoenixd_password`
- Only for `node_backend: Phoenixd`.
- API password for phoenixd.

### Post-setup verification

1. Verify entities/status in the integration.
2. Optionally run a very small test payment.
3. Before production use, verify backup/restore readiness.

<a id="support-matrix-en"></a>
## Support Matrix (MVP)

| Installation type | Support status | Limitations |
|---|---|---|
| Home Assistant OS | Supported | Full Supervisor/add-on flow is recommended |
| Home Assistant Supervised | Supported | Add-on behavior depends on a clean Supervisor setup on the host |
| Home Assistant Container | Supported (limited) | No native add-on store/Supervisor; primarily use the HACS integration and external services |

<a id="setup-tests-en"></a>
## Setup Tests in the Wizard

### Required tests
- Connectivity check (Hub/NWC reachable)
- Scope check (required permissions granted)

### Optional test
- 1-sat live test payment (shown as optional, never mandatory)
- Always shown with a short risk/cost explanation

## Behavior on Test Failures

- MVP rule: **Continue with warning** is allowed.
- Optional-step failures do not block setup completion.
- Required-test failures are surfaced clearly; users can still complete setup with warning in MVP.

## Setup UX Texts

- Inline explanations in short mode (1–2 sentences)
- A “Learn more” link per step pointing to the relevant handbook section

## MVP Languages

- Required: **DE + EN** for full config/options flows
- Additional languages (e.g., FR, ES) are planned for later releases

## HACS Release Policy

- Start at version **0.0.0**
- Version format: **x.y.z**
  - `z` = pre-release
  - `y` = release
  - `x` = major release
- Every release includes release notes and a compatibility note
