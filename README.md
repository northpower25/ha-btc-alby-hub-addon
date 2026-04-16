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
