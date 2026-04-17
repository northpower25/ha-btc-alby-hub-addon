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
- `external_access_enabled`: Bindet bei `true` an `0.0.0.0`; nur mit geeigneter Firewall nutzen
- `backup_passphrase`: Aktiviert verschlüsselte Backups
- `hub_unlock_password`: Aktiviert Auto-Unlock im Expert-Modus
- `lnd_*`, `cln_*`, `phoenixd_*`: Nur für das jeweilige Backend nötig

## Erstes Setup (Kurzfassung)

1. Add-on installieren und starten
2. Cloud-Modus: NWC-String eintragen  
   Expert-Modus: Hub über Ingress öffnen, initial entsperren, NWC-Verbindung in `Apps` erzeugen
3. Danach Home-Assistant-Integration mit dem NWC-String verbinden

## Fehlerbilder

- `missing required 'relay' query parameter`: NWC-String ohne Relay-Parameter
- `missing required 'secret' query parameter`: NWC-String ohne Secret-Parameter
- `Relay not reachable right now`: Relay-Verbindungscheck ist fehlgeschlagen; Netzwerk/Firewall prüfen. Das Add-on startet trotzdem weiter und zeigt nur eine Warnung.
