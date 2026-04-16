# TODO – Alby Hub Home Assistant Add-on & Integration

> Aktuelle Phase: **Phase 1 – MVP**  
> Stand: April 2026

---

## Legende

| Symbol | Bedeutung |
|---|---|
| ✅ | Erledigt |
| 🔄 | In Bearbeitung |
| ⬜ | Offen |
| 🚫 | Blockiert |
| ⭐ | Hohe Priorität |

---

## Phase 1 – MVP

### A) Add-on (Core Runtime)

- ✅ `alby-hub-addon/config.yaml` – Add-on-Manifest erstellen
- ✅ `alby-hub-addon/build.yaml` – Docker-Build-Konfiguration
- ✅ `alby-hub-addon/Dockerfile` – Container-Definition
- ✅ `alby-hub-addon/run.sh` – Startskript (bashio-basiert)
- ✅ Dual-Modus: Cloud-Modus (NWC-String von albyhub.com) + Expert-Modus (lokaler Hub) in `config.yaml`
- ✅ Dual-Modus: NWC-Validierung + Fehlerhinweise mit korrekten URLs in `run.sh`
- ✅ Cloud-Modus: `alby_api_key` (falsch) → `nwc_connection_string` (korrekt) ersetzt
- ✅ Expert-Modus: Phoenixd-Backend ergänzt (offiziell unterstützt laut Alby Hub README)
- ✅ Expert-Modus: `AUTO_UNLOCK_PASSWORD` via `hub_unlock_password` konfigurierbar
- ✅ Expert-Modus: Lokaler NWC-Relay (`ws://localhost:7447/v1`) als primärer Relay
- ⬜ ⭐ `alby-hub-addon/DOCS.md` – Benutzer-Dokumentation mit NWC-Setup-Anleitung
- ⬜ `alby-hub-addon/CHANGELOG.md` – Changelog anlegen
- ⬜ `alby-hub-addon/nostr-relay/start.sh` – NOSTR-Relay-Startskript
- ⬜ ⭐ GitHub Actions Workflow für automatischen Container-Build (`.github/workflows/build.yml`)
- ⬜ Container-Images auf GHCR publizieren (`ghcr.io/northpower25/ha-alby-hub`)
- ⬜ Healthcheck-Endpoint testen und verfeinern
- ⬜ Persistente Datenpfade verifizieren (Upgrade-Test)

### B) HACS Custom Integration

- ⬜ ⭐ `custom_components/alby_hub/__init__.py` – Entry Point & Setup
- ⬜ ⭐ `custom_components/alby_hub/manifest.json` – HACS-Manifest
- ⬜ ⭐ `custom_components/alby_hub/const.py` – Konstanten (inkl. NWC-Scopes)
- ⬜ ⭐ `custom_components/alby_hub/nwc_client.py` – NWC-Client (Nostr Wallet Connect via WebSocket)
- ⬜ ⭐ `custom_components/alby_hub/api.py` – Alby Hub lokale HTTP REST API (Expert-Mode)
- ⬜ ⭐ `custom_components/alby_hub/coordinator.py` – DataUpdateCoordinator (NWC + REST)
- ⬜ ⭐ `custom_components/alby_hub/config_flow.py` – Setup-Wizard (NWC-String eingeben + validieren)
- ⬜ ⭐ `custom_components/alby_hub/sensor.py` – Sensoren (Balance, Kanäle, Preise)
- ⬜ `custom_components/alby_hub/binary_sensor.py` – Node-Online, Synced, NOSTR
- ⬜ `custom_components/alby_hub/switch.py` – NOSTR Relay, Safe Mode
- ⬜ `custom_components/alby_hub/services.yaml` – Service-Definitionen
- ⬜ `custom_components/alby_hub/strings.json` – UI-Texte (Englisch)
- ⬜ `custom_components/alby_hub/translations/en.json` – Englische Übersetzung
- ⬜ `custom_components/alby_hub/translations/de.json` – Deutsche Übersetzung
- ⬜ NWC-Services via NWC-Client: `make_invoice`, `pay_invoice`, `lookup_invoice`
- ⬜ NWC-Subscriptions: eingehende Payments als HA-Events (`alby_hub_payment_received`)
- ⬜ Webhook-Empfänger für HA-Events (`payment_received`, `invoice_paid`, etc.)
- ⬜ BTC-Preis-Feed (EUR/USD) als Sensor (Quelle: Mempool.space)

### C) Dashboard

- ⬜ ⭐ `dashboards/alby_hub.yaml` – Lovelace-Dashboard YAML
- ⬜ Auto-Provisioning des Dashboards beim ersten Setup in `__init__.py`
- ⬜ Node-Status-Karte (online/offline, Peers, Channels)
- ⬜ Balance-Karte (Lightning + On-Chain + BTC-Preis)
- ⬜ Kanal-Liquiditätsbalken (inbound/outbound)
- ⬜ Live-Zahlungsliste (letzte 10 Transaktionen)
- ⬜ Quick-Actions-Buttons (Rechnung erstellen, Testzahlung, Backup)
- ⬜ NOSTR-Status-Karte

### Repository & Meta-Dateien

- ⬜ ⭐ `hacs.json` – HACS Repository-Konfiguration
- ⬜ `repository.json` – Add-on Repository-Konfiguration
- ⬜ ⭐ `README.md` – Projektbeschreibung mit Installationsanleitung
- ⬜ `LICENSE` – MIT-Lizenz hinzufügen
- ⬜ `.github/ISSUE_TEMPLATE/bug_report.md` – Bug-Report-Template
- ⬜ `.github/ISSUE_TEMPLATE/feature_request.md` – Feature-Request-Template
- ⬜ `.github/workflows/validate.yml` – HACS-Validierung CI

---

## Phase 2 – NFC & Automationen

### Blueprints

- ⬜ ⭐ `blueprints/automation/alby_hub/nfc_payment_trigger.yaml` – NFC → Invoice → Gerät steuern
- ⬜ `blueprints/automation/alby_hub/paywall_switch.yaml` – Gerät hinter Bezahlschranke
- ⬜ `blueprints/automation/alby_hub/donation_button.yaml` – Spendenbutton (LNURL)
- ⬜ `blueprints/automation/alby_hub/btc_price_alert.yaml` – BTC-Preisalarm
- ⬜ `blueprints/automation/alby_hub/payment_notification.yaml` – Push-Benachrichtigung bei Eingang

### Integration – Erweiterte Features

- ⬜ Safe-Mode implementieren (max. Betrag, Tages-/Monatslimit)
- ⬜ Simulationsmodus (Automationen ohne echte Zahlung testen)
- ⬜ Erweiterte Metriken: Routing-Fees (24h/7d/30d), Fehlerrate
- ⬜ Service: `lightning.pay_lnurl` (LNURL-Pay)
- ⬜ Service: `lightning.create_backup` (Manuelles Backup auslösen)
- ⬜ Lightning-Address `user@ha.local` einrichten
- ⬜ Mempool-Gebühren als HA-Sensor

### Dashboard – Erweiterungen Phase 2

- ⬜ NFC-Bereich mit letztem Scan und Quick-Blueprint-Buttons
- ⬜ Routing-Fee-Chart (24h)
- ⬜ Safe-Mode-Status-Anzeige
- ⬜ Automations-Protokoll (letzte ausgelöste Payment-Automationen)

---

## Phase 3 – NOSTR & Security

### NOSTR Relay

- ⬜ ⭐ NOSTR-Relay vollständig in Add-on integrieren (strfry oder Go-Relay)
- ⬜ HA-Entities für Relay-Monitoring (Clients, Events, Storage)
- ⬜ Rate-Limiting konfigurierbar (Events/Minute/Pubkey)
- ⬜ Moderation: Gebannte Pubkeys, Wortfilter
- ⬜ NIP-05 Verifikation (`user@homeassistant.local`)
- ⬜ NOSTR-Event empfangen → HA-Automation auslösen
- ⬜ Blueprint: NOSTR-Event → Gerät steuern

### Security & Policy

- ⬜ API-Token-Rollen (read_only / invoice_only / full_access) in Config Flow
- ⬜ Audit-Log für alle Zahlungen und Automationen
- ⬜ Audit-Log-Viewer im Dashboard
- ⬜ Whitelist für Payment-Ziele konfigurierbar
- ⬜ Zeitfenster-Beschränkung für ausgehende Zahlungen
- ⬜ Recovery-Test-Workflow dokumentieren und automatisieren

### Multi-Node-Unterstützung

- ⬜ Mainnet + Testnet Instanzen parallel möglich
- ⬜ HA-Integration wählt zwischen mehreren Hub-Instanzen

---

## Phase 4 – UX-Polish & Community

### UI & UX

- ⬜ Animierte Charts (Balance-Historie, Fee-Historie)
- ⬜ Responsives Dashboard-Layout (Mobile + Desktop)
- ⬜ Diagnostik-Seite (Connectivity, Fee-Estimator, Channel-Warnungen)
- ⬜ Onboarding-Wizard direkt im Dashboard (Schritt-für-Schritt)

### Community & Dokumentation

- ⬜ Vollständige englische Dokumentation (Wiki oder docs/)
- ⬜ Deutsche Dokumentation
- ⬜ Video-Tutorial: Installation und Erstkonfiguration
- ⬜ Community-Blueprint-Collection (Spendenbox, Pay-to-WiFi, Türöffner)
- ⬜ Forum-Post / Reddit-Announcement
- ⬜ HACS Default Store Einreichung

### DevOps & CI/CD

- ⬜ Automatisierter Test-Suite für Integration (pytest + pytest-homeassistant-custom-component)
- ⬜ Container-Build-Pipeline für amd64 + aarch64
- ⬜ Automatisches Release-Tagging bei Merge in `main`
- ⬜ Dependency-Update-Workflow (Renovate oder Dependabot)
- ⬜ Codecov-Integration für Testabdeckung

---

## Bugs & bekannte Einschränkungen

| # | Beschreibung | Status |
|---|---|---|
| – | Keine bekannten Bugs (Projektstart) | – |

---

## Nächste Aktionen (Sprint 1)

1. ⬜ `custom_components/alby_hub/manifest.json` und `__init__.py` erstellen
2. ⬜ `custom_components/alby_hub/api.py` – Alby Hub REST Client implementieren
3. ⬜ `custom_components/alby_hub/config_flow.py` – Setup-Wizard
4. ⬜ `custom_components/alby_hub/sensor.py` – Balance + Status Sensoren
5. ⬜ `dashboards/alby_hub.yaml` – MVP Dashboard
6. ⬜ `hacs.json` + `README.md` finalisieren
7. ⬜ GitHub Actions für HACS-Validierung einrichten

---

*Dieses Dokument wird nach jedem Sprint aktualisiert.*
