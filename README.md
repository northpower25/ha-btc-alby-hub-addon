# Home Assistant Add-on: Alby Hub (Bitcoin Lightning)

Dieses Repository stellt ein Home Assistant Add-on bereit, mit dem du **Bitcoin-Lightning-Funktionen** über **Alby Hub** in dein Smart Home integrieren kannst.

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

- Konzept: [CONCEPT.md](CONCEPT.md)
- Handbuch (DE): [docs/handbook.de.md](docs/handbook.de.md)
- Handbook (EN): [docs/handbook.en.md](docs/handbook.en.md)
