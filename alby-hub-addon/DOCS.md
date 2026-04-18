# Alby Hub (Bitcoin Lightning)

Dieses Add-on stellt Alby Hub für Home Assistant bereit.

## ⚠️ Wichtiger Beta- und Risikohinweis

- Dieses Add-on und die zugehörige Integration sind **Beta-Software**.
- Unter bestimmten Bedingungen können **Verluste** entstehen, z. B. durch Fehlkonfiguration, falsche Berechtigungen, Bedienfehler, Ausfälle externer Komponenten oder Software-/Netzwerkprobleme.
- Nutze zum Testen **keine größeren Geldbeträge**; starte nur mit kleinen Testbeträgen.
- Typische Benutzerfehler: falscher NWC-String, fehlende/zu breite Scopes, falsches Bitcoin-Netzwerk, unsicherer externer Zugriff, unzureichende Backups.
- Systemische Risiken: Relay-/Dienst-Ausfälle, Netzwerkstörungen, Zustandsprobleme bei Neustarts, Änderungen in abhängigen Upstream-Komponenten.
- Für eine sichere und verantwortungsvolle Nutzung von Add-on und Integration bist du selbst verantwortlich.

## Wofür dieses Add-on ist – und wofür die Integration

- **Dieses Add-on** ist für den Betrieb bzw. die Bereitstellung von Alby Hub in Home Assistant gedacht (lokal im Expert-Modus oder als Cloud-Bridge im Cloud-Modus).
- **Die Integration** ([`ha-btc-alby-hub-integration`](https://github.com/northpower25/ha-btc-alby-hub-integration)) ist für die Home-Assistant-Anbindung gedacht: Entities, Services, Automationen und Dashboards über NWC.
- Kurz gesagt: **Add-on = Hub bereitstellen**, **Integration = Hub in HA nutzbar machen**.

## Modi

### Cloud-Modus (`node_mode: cloud`)

- Kein lokaler Lightning-Node im Add-on
- Verbindung über `nwc_connection_string` (von `https://albyhub.com` oder eigenem Hub)
- Das Add-on validiert NWC-Schema, `relay` und `secret` beim Start

### Expert-Modus (`node_mode: expert`)

- Lokaler Alby Hub läuft im Add-on (Ingress/Port 8080)
- Unterstützte Backends: `LDK`, `LND`, `CLN`, `Phoenixd`, `Cashu`
- Optionales NOSTR-Relay-Proxy auf Port `3334` (`nostr_relay_enabled: true`)

## Konfigurationshinweise

- `nwc_connection_string`: Nur im Cloud-Modus erforderlich (`nostr+walletconnect://...`)
- `tor_enabled`: Aktiviert ausgehende Kommunikation über Proxy/Tor
- `tor_socks5_url`: Tor/SOCKS-Proxy-URL (z. B. `socks5h://127.0.0.1:9050`), nur bei `tor_enabled: true`
- `external_access_enabled`: Bindet bei `true` an `0.0.0.0`; nur mit geeigneter Firewall nutzen
- `backup_passphrase`: Aktiviert verschlüsselte Backups
- `hub_unlock_password`: Aktiviert Auto-Unlock im Expert-Modus
- `lnd_*`, `cln_*`, `phoenixd_*`: Nur für das jeweilige Backend nötig

## Erstes Setup (Kurzfassung)

1. Add-on installieren und starten
2. Cloud-Modus: NWC-String eintragen  
   Expert-Modus: Hub über Ingress öffnen, initial entsperren, NWC-Verbindung in `Apps` erzeugen
3. Danach Home-Assistant-Integration mit dem NWC-String verbinden

## Cloud-Modus: Mit Alby Account per NWC verbinden (Schritt für Schritt)

Für diese Cloud-Variante ist ein Alby Account erforderlich: `https://getalby.com`  
Alby Hub: `https://albyhub.com`  
Modelle/Pläne: `https://getalby.com/pricing`

### Welche Account-/Betriebsvariante für welchen Zweck?

| Modell | Geeignet für |
|---|---|
| **Alby Hub Cloud** (gehostet) | Einsteiger, schneller Start, kein eigener Node-Betrieb |
| **Self-Hosted Alby Hub** | Fortgeschrittene Self-Custody-Setups mit eigener Infrastruktur |
| **Eigenes externes Backend/Wallet (BYOW/BYON)** | Bestehende LND/CLN/Phoenixd/Cashu-Umgebungen |

### Schritte

1. Alby Account unter `https://getalby.com` erstellen oder anmelden.
2. In Alby Hub (`https://albyhub.com`) die passende Variante nutzen (für einfachen Cloud-Start: **Alby Hub Cloud**).
3. In Alby Hub eine NWC-Verbindung erzeugen: `Apps` → `Add Connection`.
4. Berechtigungen knapp halten (nur benötigte Scopes) und Verbindung speichern.
5. NWC-String kopieren (`nostr+walletconnect://...` inkl. `relay` und `secret`).
6. Im Add-on setzen: `node_mode: cloud` und `nwc_connection_string`.
7. Add-on speichern/neustarten und Logs prüfen.
8. Danach die Home-Assistant-Integration mit demselben NWC-String verbinden.

## Update- und Backup-Pflicht vor jedem Update

- Erstelle vor jedem Update ein vollständiges Home-Assistant-Backup.
- Stelle sicher, dass Modus- und Zugangsdaten verfügbar sind (`node_mode`, `node_backend`, `bitcoin_network`, `nwc_connection_string`, `backup_passphrase`, `hub_unlock_password`, ggf. `lnd_*`/`cln_*`/`phoenixd_*`).
- Bei externen Backends (LND/CLN/Phoenixd/Cashu) zusätzlich immer die jeweiligen Node-/Wallet-Backups prüfen.
- Erst updaten, wenn du sicher bist, dass du im Fehlerfall neu installieren und wiederherstellen kannst.

## Wo liegen deine Funds?

- **Cloud-Modus:** Funds liegen im externen Alby Hub Konto/Wallet (nicht im Add-on).
- **Expert + LDK lokal:** Funds liegen im lokalen, persistenten Add-on-Datenbestand von Alby Hub.
- **Expert + externes Backend:** Funds liegen primär im jeweiligen Backend-System; Add-on hält vor allem Verbindungsdaten/Secrets.

Wenn ein Update fehlschlägt: Add-on neu installieren, Backups wiederherstellen, Modus/Credentials korrekt setzen, Verbindung testen.

## Fehlerbilder

- `missing required 'relay' query parameter`: NWC-String ohne Relay-Parameter
- `missing required 'secret' query parameter`: NWC-String ohne Secret-Parameter
- `Relay not reachable right now`: Relay-Verbindungscheck ist fehlgeschlagen; Netzwerk/Firewall prüfen. Das Add-on startet trotzdem weiter und zeigt nur eine Warnung.
