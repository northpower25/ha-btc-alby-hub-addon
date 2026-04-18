# Copilot-Regeln für ha-btc-alby-hub-addon

Diese Datei wird von GitHub Copilot automatisch bei jeder Aufgabe in diesem Repository berücksichtigt.

---

## 1. Versioning & Changelog

- Die **einzige Quelle der Wahrheit für die Versionsnummer** ist `alby-hub-addon/config.yaml` (`version:`-Feld).
- Bei **jeder Änderung, die eine Versionserhöhung rechtfertigt**, muss `alby-hub-addon/CHANGELOG.md` mit dem neuen Versionsabschnitt (`## <version>`) und allen relevanten Änderungen aktualisiert werden.
- Die neueste Versionsüberschrift in `CHANGELOG.md` muss immer mit dem `version:`-Wert in `config.yaml` übereinstimmen.
- Format: `## <SemVer>` (z. B. `## 0.0.7`), darunter Bullet-Points auf Deutsch.

---

## 2. Dokumentation

- **Alle nutzerrelevanten Änderungen** (neue Optionen, Verhaltensänderungen, Bugfixes) werden synchron in folgenden Dateien gepflegt:
  - `alby-hub-addon/DOCS.md` – Kurzreferenz im Add-on (HA Supervisor UI)
  - `README.md` – Projekt-Übersicht / Schnellstart
  - `docs/handbook.de.md` – Deutsches Detailhandbuch
  - `docs/handbook.en.md` – Englisches Detailhandbuch
- **Installationsanweisungen** richten sich immer auf **Home Assistant 2026.x (mindestens 2026.1)**.
- Installationsanleitungen immer so strukturieren: **Add-on-Installation zuerst**, danach Integration.
- **Keine Markdown-Link-Syntax** (`[text](url)`) in `translations/de.yaml` und `translations/en.yaml` – nur plain URLs, damit sie im HA-UI erkannt werden.
- Handbuch-Links in Translation-Dateien immer als Plain-URL im Format:
  `https://github.com/northpower25/ha-btc-alby-hub-addon/blob/HEAD/docs/handbook.de.md#<anchor>`

---

## 3. Add-on-Konfiguration (`alby-hub-addon/config.yaml`)

- **Felder in `options:`** sind immer im HA-Add-on-UI sichtbar.
- **Felder nur in `schema:` mit `?`-Suffix** (und kein Eintrag in `options:`) werden im UI hinter "Nicht verwendete optionale Konfigurationsoptionen einblenden" versteckt.
- Dieses Muster **immer beibehalten** – verpflichtende/Einsteiger-Felder in `options:`, Experten-/optionale Felder nur in `schema:`.
- Kein `image:`-Feld in `config.yaml` – der Supervisor baut immer aus `Dockerfile`/`build.yaml`.

---

## 4. Dockerfile & Packaging

- Das Basis-Image ist **Debian-basiert** (`ghcr.io/getalby/hub:latest`). Daher immer **`apt-get`** für Paketinstallationen verwenden (niemals `apk` oder andere Alpine-Paketmanager).
- `build.yaml` verweist auf `ghcr.io/getalby/hub:latest` für beide Architekturen (`aarch64`, `amd64`).
- Wenn Binaries heruntergeladen werden (z. B. `websocat`), **SHA256-Prüfsumme immer verifizieren** (`sha256sum -c`).

---

## 5. Laufzeit & Datenpfade

- Persistente Daten liegen unter `/addon_configs/<slug>/hub`, `/nostr` und `/backups`.
- `DATA_DIR` wird in `run.sh` via `$(bashio::addon.slug)` gesetzt – dieses Muster immer beibehalten.
- Das Add-on hat **zwei Modi**: `cloud` (NWC-Bridge, kein lokaler Node) und `expert` (lokaler Alby Hub mit eigenem Backend).
- Änderungen an `run.sh` die neue Config-Felder lesen: immer via `bashio::config '<key>' '<default>'` und das Feld auch in `config.yaml` `schema:` und `environment:` eintragen.

---

## 6. Sicherheit

- **Keine Secrets** (Passwörter, Macaroons, NWC-Strings, TLS-Zertifikate) in Logs ausgeben – auch nicht auf `debug`-Level.
- `external_access_enabled: true` bindet auf `0.0.0.0` – immer mit expliziter Warnung in den Logs versehen.
- Neue Felder, die Credentials enthalten, immer als `str?` im Schema und nie in `options:` mit Default-Wert anlegen.

---

## 7. Translations (`alby-hub-addon/translations/`)

- Für jedes neue Feld in `config.yaml` immer **beide** Translation-Dateien aktualisieren: `de.yaml` und `en.yaml`.
- `name:` und `description:` sind Pflicht pro Feld.
- Links in `description:` immer als Plain-URLs (kein Markdown).

---

## 8. Arbeitsweise bei Aufgaben

- Änderungen immer **minimal und chirurgisch** halten – nur die direkt betroffenen Stellen anpassen.
- Vor dem ersten Edit kurz prüfen, ob `config.yaml`-Version und `CHANGELOG.md`-Versionsheader noch synchron sind.
- Wenn eine Aufgabe Auswirkungen auf die Nutzerdokumentation hat, immer `DOCS.md`, `handbook.de.md` und `handbook.en.md` mitaktualisieren.
- Keine neue Linting-, Test- oder Build-Infrastruktur einführen – dieses Projekt hat aktuell keine lokalen automatisierten Tests.
