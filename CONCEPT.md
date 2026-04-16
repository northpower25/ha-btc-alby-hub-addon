# Alby Hub – Home Assistant Add-on & Integration: Konzeptdokument

> Version 1.0 · Stand: April 2026  
> Repository: [northpower25/ha-btc-lightning-node-addon](https://github.com/northpower25/ha-btc-lightning-node-addon)

---

## Inhaltsverzeichnis

1. [Projektziel](#1-projektziel)
2. [Architektur-Überblick](#2-architektur-überblick)
3. [Modul A – Add-on (Core Runtime)](#3-modul-a--add-on-core-runtime)
4. [Betriebsmodi](#4-betriebsmodi)
5. [Modul B – HACS Custom Integration](#5-modul-b--hacs-custom-integration)
6. [Modul C – Dashboard](#6-modul-c--dashboard)
7. [Modul D – NFC & M2M Payment Layer](#7-modul-d--nfc--m2m-payment-layer)
8. [Modul E – NOSTR Relay](#8-modul-e--nostr-relay)
9. [Sicherheits- und Betriebskonzept](#9-sicherheits--und-betriebskonzept)
10. [Umsetzungsphasen](#10-umsetzungsphasen)
11. [Zusätzliche Feature-Ideen](#11-zusätzliche-feature-ideen)
12. [Technische Abhängigkeiten](#12-technische-abhängigkeiten)

---

## 1. Projektziel

Das Ziel dieses Projekts ist es, jedem Home-Assistant-Nutzer mit minimalem Aufwand den Einstieg in das **Bitcoin-Lightning-Self-Custody-Ökosystem** zu ermöglichen. Dazu wird [getAlby Hub](https://github.com/getAlby/hub) als Home-Assistant-Add-on verpackt und durch eine tief integrierte HA-Custom-Integration ergänzt.

### Kernversprechen

| Zielgruppe | Nutzen |
|---|---|
| Einsteiger | 1-Klick-Installation, geführtes Onboarding, kein technisches Vorwissen |
| Fortgeschrittene | Eigene Lightning-Node (LDK/LND/Breez), vollständige Self-Custody |
| Entwickler & Maker | M2M-Payments, NFC-Trigger, Automations-API, NOSTR-Relay |

---

## 2. Architektur-Überblick

```
┌──────────────────────────────────────────────────────────────────┐
│                     Home Assistant Host                          │
│                                                                  │
│  ┌─────────────────────────────────┐  ┌────────────────────────┐ │
│  │   HA Add-on (Supervisor)        │  │  HACS Custom           │ │
│  │   ┌───────────────────────────┐ │  │  Integration           │ │
│  │   │   getAlby Hub Container   │ │  │  ┌──────────────────┐  │ │
│  │   │   ┌─────────────────────┐ │ │  │  │  Entities        │  │ │
│  │   │   │  Lightning Backend  │ │ │  │  │  Services        │  │ │
│  │   │   │  LDK / LND / Cloud  │ │ │◄─┼──│  Config Flow     │  │ │
│  │   │   └─────────────────────┘ │ │  │  │  Webhooks        │  │ │
│  │   │   ┌─────────────────────┐ │ │  │  └──────────────────┘  │ │
│  │   │   │  NOSTR Relay        │ │ │  └────────────────────────┘ │
│  │   │   │  (optional)         │ │ │                              │
│  │   │   └─────────────────────┘ │ │  ┌────────────────────────┐ │
│  │   └───────────────────────────┘ │  │  Lovelace Dashboard    │ │
│  └─────────────────────────────────┘  │  (auto-provisioned)    │ │
│                                        └────────────────────────┘ │
└──────────────────────────────────────────────────────────────────┘
         │ NWC/REST API                 │ Entities / Events
         ▼                              ▼
   Alby Browser Extension         HA Automationen
   Mobile Wallets                  NFC Tags
   M2M Clients                     Blueprints
```

---

## 3. Modul A – Add-on (Core Runtime)

Das Add-on kapselt den **getAlby Hub** in einem Home-Assistant-Supervisor-Container.

### Verzeichnisstruktur

```
alby-hub-addon/
├── config.yaml          # Add-on-Manifest (Ports, Optionen, Schema)
├── build.yaml           # Docker-Build-Konfiguration
├── Dockerfile           # Container-Definition
├── run.sh               # Startskript (bashio-basiert)
├── DOCS.md              # Benutzer-Dokumentation
└── nostr-relay/
    └── start.sh         # NOSTR-Relay-Startskript
```

### Persistente Datenpfade

| Pfad | Inhalt |
|---|---|
| `/addon_configs/alby_hub/hub/` | Alby Hub Daten (Wallet, DB, Config) |
| `/addon_configs/alby_hub/nostr/` | NOSTR Relay Events & Konfiguration |
| `/addon_configs/alby_hub/backups/` | Verschlüsselte Backup-Archive |

### Ports

| Port | Dienst | Sichtbarkeit |
|---|---|---|
| 8080 | Alby Hub Web UI & REST API | Lokal / Ingress |
| 3334 | NOSTR Relay WebSocket | Lokal (opt. extern) |

---

## 4. Betriebsmodi

Das Add-on unterstützt zwei klar getrennte Betriebsmodi, die im Setup-Wizard ausgewählt werden:

### Modus 1: Cloud-Modus (Einsteiger – ohne eigene Node)

```
HA Add-on (Alby Hub Container)
        │
        │  HTTPS/OAuth2
        ▼
  getAlby Cloud API  ◄──── Treuhänderisch bei Alby gehostet
        │
        ▼
  Lightning Network
```

- **Voraussetzung:** Alby-Account (kostenlos)
- **Vorteile:** Kein Channel-Management, sofort einsatzbereit, kein eigenes Kapital nötig
- **Nachteile:** Nicht vollständig self-custodial (Alby hält Schlüssel)
- **Konfiguration:** `node_mode: cloud`, Alby API-Key aus Account-Einstellungen
- **Geeignet für:** Einsteiger, Test-Setups, Nutzer ohne dedizierte Hardware

### Modus 2: Expert-Modus (eigene Node – vollständige Self-Custody)

```
HA Add-on (Alby Hub Container)
        │
        │  Lokale Verbindung
        ▼
  Lightning Backend
  ┌─────────────────┐
  │  LDK (embedded) │ ← Standard, keine externe Node nötig
  │  LND (extern)   │ ← eigene LND-Node via REST+Macaroon
  │  Breez SDK      │ ← Breez-Service-Node
  │  Greenlight     │ ← Blockstream Greenlight
  │  CLN (Core LN)  │ ← Core Lightning via REST
  └─────────────────┘
        │
        ▼
  Lightning Network  (direkte Peer-Verbindungen)
```

- **Voraussetzung:** Laufende Lightning-Node oder LDK (embedded, kein Extra-Setup)
- **Vorteile:** Vollständige Self-Custody, keine Drittpartei, maximale Kontrolle
- **Nachteile:** Channel-Management erforderlich, On-chain-Kapital notwendig
- **Konfiguration:** `node_mode: expert`, Backend-Typ + Verbindungsdetails
- **Geeignet für:** Fortgeschrittene, Selbst-Hoster, Nutzer mit eigener Node

### Modus-Vergleichstabelle

| Eigenschaft | Cloud-Modus | Expert-Modus |
|---|---|---|
| Self-Custody | ❌ (Alby treuhänderisch) | ✅ vollständig |
| Setup-Aufwand | ⭐ minimal | ⭐⭐⭐ mittel-hoch |
| Channel-Management | automatisch | manuell |
| Kapital erforderlich | nein | ja (für Channels) |
| Offline-Betrieb | eingeschränkt | vollständig |
| Empfehlung | Einsteiger | Fortgeschrittene |

### Konfigurationsoptionen (Add-on)

```yaml
# Gemeinsam für beide Modi
node_mode: cloud            # cloud | expert
log_level: info
nostr_relay_enabled: false
backup_passphrase: ""
external_access_enabled: false

# Cloud-Modus
alby_api_key: ""            # API-Key aus alby.com/account

# Expert-Modus
bitcoin_network: mainnet    # mainnet | testnet | signet | mutinynet
node_backend: LDK           # LDK | LND | CLN | Breez | Greenlight
lnd_rest_url: ""
lnd_macaroon_hex: ""
lnd_tls_cert: ""
cln_rest_url: ""
cln_rune: ""
```

---

## 5. Modul B – HACS Custom Integration

Die Integration koppelt Home Assistant direkt an die Alby Hub API und stellt Entities, Services und Events bereit.

### Config Flow

```
Benutzer öffnet "Integration hinzufügen"
    │
    ▼
Schritt 1: Add-on-URL eingeben
           (Standard: http://localhost:8080)
    │
    ▼
Schritt 2: API-Token eingeben
           (aus Alby Hub Web UI unter Einstellungen → API)
    │
    ▼
Schritt 3: Token-Typ wählen
           ○ Read-Only (nur Monitoring)
           ○ Full Access (Payments + Monitoring)
    │
    ▼
Verbindungstest → Entities werden angelegt → Dashboard wird erstellt
```

### Entities

#### Sensoren (`sensor.*`)

| Entity | Beschreibung | Einheit |
|---|---|---|
| `sensor.alby_hub_balance_lightning` | Lightning-Guthaben | Satoshi |
| `sensor.alby_hub_balance_onchain` | On-Chain-Guthaben | Satoshi |
| `sensor.alby_hub_channels_total` | Anzahl Lightning-Kanäle | # |
| `sensor.alby_hub_channels_active` | Aktive Kanäle | # |
| `sensor.alby_hub_inbound_liquidity` | Eingehende Liquidität | Satoshi |
| `sensor.alby_hub_outbound_liquidity` | Ausgehende Liquidität | Satoshi |
| `sensor.alby_hub_peers_total` | Verbundene Peers | # |
| `sensor.alby_hub_last_payment_amount` | Betrag der letzten Zahlung | Satoshi |
| `sensor.alby_hub_last_payment_time` | Zeitstempel letzte Zahlung | Timestamp |
| `sensor.alby_hub_fees_earned_24h` | Routing-Gebühren (24h) | Satoshi |
| `sensor.alby_hub_btc_price_eur` | BTC-Kurs EUR | € |
| `sensor.alby_hub_btc_price_usd` | BTC-Kurs USD | $ |
| `sensor.alby_hub_nostr_relay_clients` | Verbundene NOSTR-Clients | # |
| `sensor.alby_hub_nostr_relay_events` | Gespeicherte NOSTR-Events | # |

#### Binäre Sensoren (`binary_sensor.*`)

| Entity | Beschreibung | State |
|---|---|---|
| `binary_sensor.alby_hub_node_online` | Hub-Verbindung | online/offline |
| `binary_sensor.alby_hub_synced` | Node synchronisiert | synced/syncing |
| `binary_sensor.alby_hub_nostr_relay_running` | NOSTR Relay aktiv | on/off |

#### Schalter (`switch.*`)

| Entity | Beschreibung |
|---|---|
| `switch.alby_hub_nostr_relay` | NOSTR Relay ein/ausschalten |
| `switch.alby_hub_safe_mode` | Safe-Mode (Ausgabelimits) aktivieren |

### Services

```yaml
# Rechnung erstellen
lightning.create_invoice:
  amount_sat: 1000
  memo: "Kaffeezahlung"
  expiry_seconds: 3600

# Zahlung senden
lightning.send_payment:
  payment_request: "lnbc..."   # BOLT11-Invoice
  amount_sat: ~                 # optional, nur bei Keysend

# LNURL bezahlen
lightning.pay_lnurl:
  lnurl: "LNURL1..."
  amount_sat: 500
  comment: "Spende"

# Invoice dekodieren
lightning.decode_invoice:
  payment_request: "lnbc..."

# Manuelles Backup auslösen
lightning.create_backup:
  encrypt: true
```

### Events (Webhooks → HA Events)

| Event | Payload |
|---|---|
| `alby_hub_payment_received` | `{amount_sat, payment_hash, memo, timestamp}` |
| `alby_hub_invoice_paid` | `{amount_sat, payment_hash, memo, fee_sat}` |
| `alby_hub_channel_opened` | `{peer_pubkey, capacity_sat, channel_id}` |
| `alby_hub_channel_closed` | `{peer_pubkey, reason, channel_id}` |
| `alby_hub_nostr_event_received` | `{kind, pubkey, content, tags}` |

---

## 6. Modul C – Dashboard

Das Lovelace-Dashboard wird automatisch beim ersten Verbinden der Integration angelegt.

### Dashboard-Bereiche

```
┌─────────────────────────────────────────────────────────┐
│  ⚡ Alby Hub – Bitcoin Lightning Dashboard               │
├─────────────────────┬───────────────────────────────────┤
│  Node Status        │  Balances                         │
│  ● Online           │  ⚡ Lightning: 250.000 sat         │
│  ✓ Synced           │  ₿  On-Chain:  50.000 sat         │
│  Peers: 5           │  BTC/EUR:   ~€ 42.000             │
│  Channels: 3        │                                   │
├─────────────────────┴───────────────────────────────────┤
│  Kanäle & Liquidität                                    │
│  ▓▓▓▓▓▓░░  Outbound: 180.000 sat                       │
│  ░░░░▓▓▓▓  Inbound:   70.000 sat                       │
├─────────────────────────────────────────────────────────┤
│  Letzte Zahlungen (live)                                │
│  12:04  +1.000 sat  "Kaffee"                           │
│  11:52  -500 sat    "NFC Tür"                          │
│  11:30  +250 sat    Routing-Fee                        │
├─────────────────────┬───────────────────────────────────┤
│  Quick Actions      │  NOSTR Relay                      │
│  [+ Rechnung]       │  ● Aktiv · 12 Clients             │
│  [▶ Testzahlung]    │  Events gespeichert: 4.821        │
│  [⬇ Backup]        │  [Relay ein/aus]                  │
├─────────────────────┴───────────────────────────────────┤
│  NFC & Automationen                                     │
│  Letzter NFC-Scan: "Türöffnung" · vor 3 Min            │
│  [+ NFC Blueprint]  [+ Paywall Blueprint]              │
└─────────────────────────────────────────────────────────┘
```

---

## 7. Modul D – NFC & M2M Payment Layer

### NFC-Workflow

```
NFC-Tag wird gescannt
        │
        ▼
HA NFC-Automation ausgelöst
        │
        ├─► Invoice erzeugen (lightning.create_invoice)
        │          │
        │          ▼
        │   QR-Code / LNURL anzeigen
        │          │
        │          ▼
        │   Zahlung eingeht (alby_hub_invoice_paid)
        │          │
        │          ▼
        │   Gerät steuern (z.B. Türöffner, Schalter)
        │
        └─► Direkt bezahlen (lightning.send_payment)
```

### M2M-Patterns

| Muster | Beispiel | Trigger |
|---|---|---|
| Pay-per-Use | Ladegerät, Drucker, Schloss | Zahlung eingegangen |
| Pay-per-Event | API-Call-Kostenkontrolle | Sensor-Wert-Änderung |
| Paywall | Wlan-Zugangspunkt | Invoice bezahlt |
| Automatische Überweisung | Strom-Verbrauchsabrechnung | Zeitplan |
| Spendenbutton | Dash-Button-Integration | NFC-Scan |

### Rule Engine (Sicherheit)

- Maximaler Zahlungsbetrag pro Transaktion konfigurierbar
- Whitelist von erlaubten Payment-Zielen
- Zeitfenster-Beschränkung (nur werktags, nur bestimmte Stunden)
- Tages-/Monats-Limit für ausgehende Zahlungen
- Audit-Log aller ausgelösten Automationen

---

## 8. Modul E – NOSTR Relay

### Funktionen

- Optional aktivierbares Relay im selben Add-on-Container
- WebSocket-Endpoint: `ws://homeassistant.local:3334`
- Unterstützte NIPs: NIP-01, NIP-02, NIP-04, NIP-09, NIP-11, NIP-17
- Rate-Limiting (Events pro Minute pro Pubkey konfigurierbar)
- Basis-Moderation (gebannte Pubkeys, Wortfilter)
- Persistenz in SQLite (`/addon_configs/alby_hub/nostr/`)
- HA-Entities für Monitoring (Clients, Events, Speicherbelegung)

### NIP-05 Verifikation (Bonus)

Ermöglicht `user@homeassistant.local` als NOSTR-Identität im eigenen Heimnetz.

---

## 9. Sicherheits- und Betriebskonzept

### Secrets-Management

| Geheimnis | Speicherort | Niemals in |
|---|---|---|
| Wallet Seed / Mnemonic | Alby Hub verschlüsselt auf Disk | Logs, Frontend, HA-State |
| API Token | HA Secret Store (Options) | Code, Git |
| Backup-Passphrase | HA Options (verschlüsselt) | Klartext-Logs |
| LND Macaroon | HA Options | Git, Frontend |

### API-Token-Rollen

| Rolle | Erlaubte Aktionen |
|---|---|
| `read_only` | Balances, Node-Status, Transaktionshistorie lesen |
| `invoice_only` | Rechnungen erstellen + `read_only` |
| `full_access` | Alle Services inkl. Zahlungen senden |

### Netzwerk-Sicherheit

- Standardmäßig nur localhost-Binding (127.0.0.1)
- Externe Erreichbarkeit nur bei explizitem `external_access_enabled: true`
- Ingress über HA Supervisor (kein direkter Port-Forwarding nötig)
- TLS via HA SSL-Infrastruktur (Nabu Casa / eigene Zertifikate)

### Backup-Konzept

1. **Automatische Backups** täglich um 03:00 Uhr (konfigurierbar)
2. **Verschlüsselung** mit AES-256 (Backup-Passphrase aus HA Options)
3. **Ablageort:** `/addon_configs/alby_hub/backups/` (Teil der HA-Backups)
4. **Recovery-Test:** Monatlicher Probe-Restore in isolierter Umgebung empfohlen
5. **Export:** Manueller Export via HA Service `lightning.create_backup`

---

## 10. Umsetzungsphasen

### Phase 1 – MVP (Ziel: lauffähiges Produkt)

- Add-on lauffähig für beide Modi (Cloud + Expert/LDK)
- Basis-Integration: Node-Status, Balances, Invoices, Payments
- Einfaches Lovelace-Dashboard (auto-provisioned)
- HACS-konforme Repository-Struktur
- Grundlegende Dokumentation (DOCS.md, README.md)

### Phase 2 – NFC & Automationen

- NFC-Blueprint-Paket (Tür, Paywall, Spendenbutton)
- Event-basierte Automationen über Webhooks
- Erweiterte Payment-Metriken (Routing-Fees, Fehlerrate)
- Safe-Mode mit konfigurierbaren Ausgabelimits
- Simulationsmodus (Automationen ohne echte Zahlung testen)

### Phase 3 – NOSTR & Security

- NOSTR Relay (optional) vollständig integriert
- HA-Entities für Relay-Monitoring
- Fortgeschrittene Policy-Features (Whitelists, Zeitfenster)
- Audit-Log-Viewer im Dashboard
- Multi-Node-Unterstützung (Mainnet + Testnet parallel)

### Phase 4 – UX-Polish & Community

- UI-Verbesserungen, animierte Charts
- Community-Blueprint-Templates
- Companion-App Push-Notifications bei Payment-Events
- Diagnostik-Seite (Connectivity, Fee-Estimator, Channel-Warnungen)
- Vollständige Mehrsprachigkeit (DE, EN, weitere)
- Automatisierte CI/CD-Pipeline (Tests, Build, Publish)

---

## 11. Zusätzliche Feature-Ideen

| Feature | Beschreibung | Phase |
|---|---|---|
| BTC-Preisalarm | Entity → Automation wenn BTC über/unter Schwelle | 2 |
| Lightning-Address | `user@ha.local` Zahlungsadresse | 2 |
| LNURL-Withdraw | QR-Code zum Abheben auf andere Wallet | 2 |
| Pay-to-Wi-Fi | Gäste zahlen für WLAN-Zugang | 3 |
| Auto-Rebalancing | Kanäle automatisch ausbalancieren | 3 |
| On-chain Sweep | Automatisch on-chain Gelder in Channels schieben | 3 |
| BTC-Preisfeed | Entities mit EUR/USD/Sats-Umrechnung | 1 |
| Mempool-Status | Netzwerk-Gebühren als HA-Sensor | 2 |
| Keysend-Push | Spontane Zahlung ohne Invoice | 2 |

---

## 12. Technische Abhängigkeiten

| Komponente | Technologie | Lizenz |
|---|---|---|
| Lightning Backend | [getAlby Hub](https://github.com/getAlby/hub) | GPL-3.0 |
| Add-on Runtime | Home Assistant Supervisor | Apache-2.0 |
| HACS Integration | Python 3.12+, HA Core | MIT |
| NOSTR Relay | strfry / nostr-rs-relay | MIT |
| API-Protokoll | REST + NWC (Nostr Wallet Connect) | Open |
| Dashboard | Lovelace / YAML | MIT |
| Blueprints | HA Blueprint YAML | MIT |
| Container Base | Alpine Linux 3.19 | MIT/GPL |

---

*Dieses Dokument wird mit jeder neuen Phase aktualisiert.*
