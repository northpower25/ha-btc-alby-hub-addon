# Home Assistant Add-on: Alby Hub (Bitcoin Lightning)

Dieses Repository stellt ein Home Assistant Add-on bereit, mit dem du **Bitcoin-Lightning-Funktionen** über **Alby Hub** in dein Smart Home integrieren kannst.

## ⚠️ Wichtiger Beta- und Risikohinweis

- Dieses Add-on und die zugehörige Integration befinden sich in einer **Beta-Phase**.
- Es können unter bestimmten Bedingungen **finanzielle Verluste** entstehen (z. B. durch Fehlkonfiguration, Bedienfehler, fehlerhafte Berechtigungen, Verbindungsprobleme oder Software-/Netzwerkfehler).
- Bitte verwende zum Testen **keine größeren Geldbeträge** und arbeite zuerst mit sehr kleinen Testbeträgen.
- Typische Benutzerfehler sind u. a. falsche NWC-Strings/Scopes, falsches Netzwerk (Mainnet/Testnet), unsichere Freigaben von externem Zugriff oder unzureichende Backup-/Secret-Verwaltung.
- Mögliche systemische Risiken sind u. a. Ausfälle externer Dienste/Relays, Netzwerkpartitionen, Routing-/Mempool-Schwankungen, inkonsistente Zustände bei Restarts sowie Upstream-Änderungen.
- Du bist selbst für die **verantwortungsvolle Verwendung** des Add-ons und der Integration verantwortlich, einschließlich Sicherheitskonfiguration, Teststrategie und eingesetzter Beträge.

## Was das Add-on bereitstellt

- **Cloud-Modus**  
  Verbindung zu einem externen Alby Hub über NWC (Nostr Wallet Connect), ohne lokalen Lightning-Node.
- **Expert-Modus**  
  Lokaler Betrieb von Alby Hub mit eigenem Backend (z. B. LDK, LND, CLN, Phoenixd).
- **Home Assistant Ingress UI**  
  Zugriff auf die Hub-Oberfläche direkt in Home Assistant.
- **Optionale Nostr-Relay-Funktion**  
  Aktivierbar für fortgeschrittene Setups.
- **Konfigurierbare Betriebsoptionen**  
  Netzwerk, Logging, Backups, externe Erreichbarkeit und Backend-spezifische Parameter.

## Zugehörige Repositories

| Repository | Zweck |
|---|---|
| [`ha-btc-alby-hub-addon`](https://github.com/northpower25/ha-btc-alby-hub-addon) *(dieses Repo)* | Home Assistant Add-on (Supervisor-basiert) |
| [`ha-btc-alby-hub-integration`](https://github.com/northpower25/ha-btc-alby-hub-integration) | HACS Custom Integration für HA Container / alle HA-Typen |

## Wann brauchst du Add-on und wann die Integration?

- **Add-on (`ha-btc-alby-hub-addon`)** brauchst du, wenn du in Home Assistant einen **Alby-Hub-Dienst bereitstellen** willst:
  - lokal im Expert-Modus (Hub läuft im HA-Add-on-Container), oder
  - als Cloud-Bridge mit NWC im Cloud-Modus.
  - Voraussetzung: Home Assistant mit **Supervisor/Add-on-Support** (z. B. HA OS, Supervised).
- **Integration (`ha-btc-alby-hub-integration`)** brauchst du für die **Einbindung in Home Assistant** (Entities, Services, Automationen, Dashboards via NWC).
  - Sie ist auf **allen HA-Installationsarten** relevant (inkl. HA Container).
  - Bei HA Container ist sie der primäre Weg; der Hub läuft dann extern (nicht als HA-Add-on).

## Enthaltene Komponenten

- `alby-hub-addon/` – Home Assistant Add-on (Dockerfile, Add-on-Konfiguration, Startlogik)
- `docs/` – Anwenderhandbuch (DE/EN)
- `CONCEPT.md` – Konzept und Zielbild

## Für wen ist das Projekt?

- Home-Assistant-Nutzer:innen mit Interesse an Bitcoin/Lightning
- Maker:innen und Self-Hosting-Enthusiast:innen
- Nutzer:innen, die Lightning-Zahlungen in Automationen oder Dashboards integrieren möchten

## Dokumentation

- Schnellstart Installation (DE): [README-Kurzanleitung](#schnellstart-installation-in-home-assistant)
- Detaillierte Installation & Konfiguration (DE): [docs/handbook.de.md#installation-und-konfiguration-in-home-assistant-hacs--manuell](docs/handbook.de.md#installation-und-konfiguration-in-home-assistant-hacs--manuell)
- Detailed Installation & Configuration (EN): [docs/handbook.en.md#installation-and-configuration-in-home-assistant-hacs--manual](docs/handbook.en.md#installation-and-configuration-in-home-assistant-hacs--manual)
- Konzept: [CONCEPT.md](CONCEPT.md)
- Developer Handbuch (DE): [docs/developer-handbook.de.md](docs/developer-handbook.de.md)
- Handbuch (DE): [docs/handbook.de.md](docs/handbook.de.md)
- Handbook (EN): [docs/handbook.en.md](docs/handbook.en.md)

## Schnellstart: Installation in Home Assistant (Add-on zuerst, dann Integration)

**Freigegeben für Home Assistant 2026.x (mindestens 2026.1).**

### 1) Add-on installieren

1. **Add-on-Repository hinzufügen**  
   In Home Assistant 2026.x: **Einstellungen → Add-ons → Add-on-Store** öffnen.  
   Dann oben rechts auf **⋮ (Menü)** → **Repositories**.
2. **Repository in der Maske eintragen**  
   Im Dialog **Repositories**:
   - Feld **Repository URL**: `https://github.com/northpower25/ha-btc-alby-hub-addon`
   - Typ/Kategorie: **Add-on repository**
   - Mit **Hinzufügen** bestätigen.
3. **Prüfen, dass das Repository gelistet ist**  
   Das Repository muss anschließend in der Repositories-Liste sichtbar sein; Dialog schließen.
4. **Add-on „Alby Hub“ installieren und starten**  
   Beim ersten Installationslauf kann der Supervisor einige Minuten benötigen, da das Add-on-Image lokal aus dem Repository gebaut wird.
5. **Add-on konfigurieren**  
   - `node_mode: cloud` mit `nwc_connection_string`, oder  
   - `node_mode: expert` mit lokalem/externem Backend
6. **NWC-Verbindung im Hub bereitstellen**  
   Im Expert-Modus nach der initialen Hub-Einrichtung den NWC-String erzeugen.

### 2) Integration installieren und verbinden

1. **Integration per HACS installieren**  
   Repository: [`ha-btc-alby-hub-integration`](https://github.com/northpower25/ha-btc-alby-hub-integration)
2. **Integration mit dem NWC-String verbinden**

## Schritt-für-Schritt: Add-on mit Alby Account per NWC verbinden (Cloud-Modus)

> Für diese Variante brauchst du einen **Alby Account**:  
> `https://getalby.com`  
> Alby Hub: `https://albyhub.com`  
> Aktuelle Modelle/Pläne: `https://getalby.com/pricing`

### Welches Alby-Modell passt zu welchem Einsatzzweck?

| Modell | Geeignet für | Empfehlung |
|---|---|---|
| **Alby Hub Cloud** (gehostet) | Schnellstart ohne eigenen Server/Node, möglichst wenig Betriebsaufwand | Beste Wahl für Einsteiger und schnelle Inbetriebnahme |
| **Self-Hosted Alby Hub** (eigener Betrieb) | Volle Self-Custody, eigener Stack, mehr Kontrolle | Für fortgeschrittene Nutzer mit eigener Infrastruktur |
| **Externes eigenes Backend/Wallet (BYOW/BYON)** | Du betreibst bereits LND/CLN/Phoenixd/Cashu und willst Alby nur als Verbindungs-/App-Schicht nutzen | Für bestehende Node-Setups und Integrationsszenarien |

### Verbindung in Home Assistant einrichten

1. **Alby Account erstellen/anmelden** auf `https://getalby.com`.
2. **Passendes Modell wählen** (oben):  
   Für den einfachen Cloud-Einstieg in diesem Add-on: **Alby Hub Cloud**.
3. **NWC-Verbindung in Alby Hub erstellen**:  
   `Apps` → `Add Connection` (Berechtigungen/Scopes möglichst minimal setzen).
4. **NWC-Connection-String kopieren** (`nostr+walletconnect://...` mit `relay` und `secret`).
5. **Im Add-on konfigurieren**:
   - `node_mode: cloud`
   - `nwc_connection_string: "<dein kopierter NWC-String>"`
6. **Add-on speichern und neu starten**, danach Logs prüfen.
7. **Integration installieren/öffnen** und denselben NWC-String einfügen.
8. **Verbindung testen** (Status/Entitäten sichtbar = erfolgreich).

Vollständige Schritt-für-Schritt-Anleitungen:
- DE: [Handbuch](docs/handbook.de.md#installation-und-konfiguration-in-home-assistant-hacs--manuell)
- EN: [Handbook](docs/handbook.en.md#installation-and-configuration-in-home-assistant-hacs--manual)
