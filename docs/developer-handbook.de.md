# Developer Handbuch (DE) – Alby Hub Home Assistant Add-on

## Ziel

Dieses Handbuch beschreibt, wie das Add-on verantwortungsvoll weiterentwickelt wird, ohne vermeidbare Risiken für Anwender:innen und Funds zu erzeugen.

## Grundprinzipien für Weiterentwicklung

- **Safety first:** Änderungen mit potenziellem Einfluss auf Funds, Secrets, Backups oder Recovery haben immer höchste Priorität.
- **Explizite Kommunikation:** Jede Release Note muss klar benennen:
  - welche Risiken bestehen,
  - welche Daten vor dem Update zwingend gesichert werden müssen,
  - welche manuellen Schritte Anwender:innen vor/nach dem Update ausführen müssen.
- **Keine stillen Breaking Changes:** Konfigurations- und Datenänderungen dürfen nicht überraschend sein.
- **Rollback-fähig planen:** Änderungen an persistenten Daten nur mit dokumentierter Rückfallstrategie.

## Persistente Daten und Verantwortungsgrenzen

Das Add-on nutzt persistente Daten unter:

- `/addon_configs/alby_hub/hub`
- `/addon_configs/alby_hub/nostr`
- `/addon_configs/alby_hub/backups`

Zusätzlich werden kritische Optionen über den Supervisor verwaltet (z. B. `nwc_connection_string`, `backup_passphrase`, `hub_unlock_password`, Backend-Credentials).

## Funds-Lage je Betriebsmodus (für Entwicklung und Kommunikation)

### 1) Cloud-Modus (`node_mode: cloud`)

- Das Add-on hält **keine lokalen Wallet-Funds**.
- Funds liegen im **externen Alby Hub Konto/Wallet**, das per NWC verbunden ist.
- Hauptrisiko im Add-on: Verlust oder Fehlrotation von NWC-Secrets/Scopes.

### 2) Expert-Modus mit lokalem LDK

- Funds und Wallet-Zustand werden lokal im Alby-Hub-Datenbestand verwaltet (persistenter Add-on-Datenpfad).
- Änderungen an Datenformat, Backup-Mechanik oder Unlock-/Encryption-Flows sind hochkritisch.

### 3) Expert-Modus mit externem Backend (LND, CLN, Phoenixd, Cashu)

- Funds liegen primär im **jeweiligen Backend-System**.
- Im Add-on liegen vor allem Verbindungsparameter und Secrets.
- Risiko: Backend-Credentials verlieren oder inkompatibel migrieren.

## Pflichtanforderungen für Releases

Vor jedem Release müssen Maintainer:innen mindestens prüfen und dokumentieren:

1. **Upgrade-Auswirkung**
   - Ändert sich Datenformat, Verzeichnisstruktur oder Konfigurationsschema?
2. **Backup-Anforderung**
   - Welche Dateien/Secrets müssen vor Update gesichert werden?
3. **Recovery-Weg**
   - Wie kommen Anwender:innen nach fehlgeschlagenem Update/Neuinstallation wieder an Funds?
4. **Sicherheitswirkung**
   - Neue offene Ports, geänderte Defaults, neue Berechtigungen, geänderte Secret-Verwendung.
5. **Kompatibilität**
   - Unterstützte HA-Versionen, Modus-spezifische Einschränkungen, bekannte Upgrade-Pfade.

## Verbindliche Update-Kommunikation (Release Notes / DOCS)

Jedes Release mit potenzieller Auswirkung auf Betrieb oder Daten enthält einen Abschnitt:

- **„Vor Update sichern“** (konkret, als Checkliste)
- **„Nach Update prüfen“** (Smoke Tests)
- **„Recovery bei Fehlschlag“** (kurzer, belastbarer Pfad)

Fehlt diese Information, gilt das Release als nicht veröffentlichungsreif.

## Minimale Test-Matrix vor Veröffentlichung

- Cloud-Modus: Start, NWC-Validierung (`relay`/`secret`), Integration verbindet
- Expert-Modus (LDK): Start, Unlock, NWC-Erstellung, Restart-Verhalten
- Expert-Modus (mind. ein externes Backend): Verbindungsaufbau + Basisfunktionen
- Update-Simulation mit vorhandenen Daten (kein Fresh-Install-only Test)

## Security- und Risiko-Checkliste für Änderungen

- Werden neue Secrets eingeführt oder anders gespeichert?
- Ändern sich Netzwerkflächen (`external_access_enabled`, Ports)?
- Können Nutzer:innen durch Standardwerte unsicher betrieben werden?
- Können Daten bei Upgrade ohne Vorwarnung unbrauchbar werden?
- Ist klar dokumentiert, was Anwender:innen vor dem Update sichern müssen?

## Definition of Done für riskante Änderungen

Eine Änderung ist erst fertig, wenn:

- technische Umsetzung abgeschlossen ist,
- Anwenderdoku mit Backup-/Recovery-Hinweisen aktualisiert ist,
- Release Notes Upgrade-Risiken klar benennen,
- ein realistischer Wiederanlauf nach Fehlupdate beschrieben ist.
