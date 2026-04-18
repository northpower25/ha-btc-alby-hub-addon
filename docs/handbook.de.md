# Handbuch (DE) – Alby Hub Home Assistant Add-on & Integration

## ⚠️ Beta-, Sicherheits- und Risikohinweis

- Add-on und Integration sind aktuell **Beta-Software**.
- Es können unter bestimmten Bedingungen **finanzielle Verluste** auftreten.
- Verwende zum Testen **keine größeren Geldbeträge**; starte mit sehr kleinen Testbeträgen.
- Typische Benutzerfehler:
  - falscher oder unvollständiger NWC-Connection-String
  - zu breite oder unpassende Scopes/Berechtigungen
  - falsches Netzwerk (z. B. Mainnet statt Testnet)
  - unsicher freigegebener externer Zugriff
  - unzureichende Backup-/Secret-Verwaltung
- Mögliche systemische Risiken:
  - Ausfälle externer Services/Relays oder Upstream-Komponenten
  - Netzwerkunterbrechungen/Instabilität
  - inkonsistente Zustände bei Restart/Recovery
  - unerwartete Kosten durch Routing-/Fee-Dynamik
- Du bist selbst für die **verantwortungsvolle Nutzung** des Add-ons und der zugehörigen Integration verantwortlich.

## Update-Sicherheit: Was du **vor jedem Update** sichern musst

Vor jedem Add-on-Update gilt: erst sichern, dann aktualisieren.

### Pflicht-Checkliste vor Update

- Vollständiges Home-Assistant-Backup erstellen (inkl. Add-on-Daten und Add-on-Konfiguration).
- Sicherstellen, dass folgende Werte dokumentiert und wieder verfügbar sind:
  - `node_mode`, `node_backend`, `bitcoin_network`
  - `nwc_connection_string` (Cloud-Modus bzw. erzeugte App-Verbindung)
  - `backup_passphrase` (falls gesetzt)
  - `hub_unlock_password` (falls gesetzt)
  - Backend-Zugangsdaten (`lnd_*`, `cln_*`, `phoenixd_*`) falls genutzt
- Bei externen Backends zusätzlich deren eigene Wallet-/Node-Backups prüfen (z. B. LND/CLN/Phoenixd/Cashu nach Hersteller-/Node-Doku).
- Nach Backup kurz verifizieren, dass Restore-Dateien und Passwörter tatsächlich lesbar/verfügbar sind.

Wenn diese Daten nicht verfügbar sind, kann eine Wiederherstellung nach fehlgeschlagenem Update oder Neuinstallation scheitern.

## Wo liegen die Funds? (szenarioabhängig)

### Cloud-Modus (`node_mode: cloud`)

- Funds liegen **nicht** im Add-on, sondern im externen Alby Hub Konto/Wallet.
- Kritisch für Recovery: Zugriff auf externes Hub-Konto und NWC-Verbindung/Secrets.

### Expert-Modus mit lokalem LDK

- Funds/Wallet-Zustand werden lokal durch Alby Hub im persistenten Add-on-Datenbereich gehalten.
- Kritisch für Recovery: funktionierendes HA-Backup inkl. Add-on-Daten + bekannte Passphrasen/Unlock-Daten.

### Expert-Modus mit externem Backend (LND, CLN, Phoenixd, Cashu)

- Funds liegen primär im jeweiligen Backend-System.
- Das Add-on hält vor allem Verbindungsdaten/Secrets.
- Kritisch für Recovery: Node-Backups des Backends + Add-on-Config/Credentials.

## Recovery nach fehlgeschlagenem Update oder Neuinstallation

1. Add-on neu installieren (gleiche/kompatible Version wählen).
2. Gesicherte Add-on-Daten und Add-on-Konfiguration wiederherstellen.
3. Betriebsmodus korrekt setzen (`cloud` oder `expert`) und alle Secrets/Credentials eintragen.
4. Cloud-Modus: NWC-Verbindung prüfen/neu erzeugen.  
   Expert-Modus: Backend-Verbindung und Unlock prüfen.
5. In der Integration Verbindungstest und Saldo/Info-Prüfung durchführen.

Wenn Funds nach Recovery nicht sichtbar sind:

- Cloud-Modus: zuerst externes Alby Hub Konto prüfen.
- Expert + externes Backend: zuerst im Backend-System prüfen.
- Expert + LDK lokal: Restore-Stand und Passphrase/Unlock-Daten prüfen.

## Zielversion und Kompatibilität

- Minimale unterstützte Home-Assistant-Version (2026.x): **2026.1**
- Gilt für Add-on und geplante HACS-Integration im MVP.

## Add-on vs. Integration (kurz erklärt)

- **Add-on (`ha-btc-alby-hub-addon`)**: Stellt den Alby Hub Dienst bereit (lokal im Add-on oder als Cloud-Bridge via NWC). Dafür ist ein HA-System mit Supervisor/Add-on-Support nötig.
- **Integration (`ha-btc-alby-hub-integration`)**: Bindet Alby Hub in Home Assistant ein (Entities, Services, Automationen, Dashboard).
- Empfehlung: Bei HA OS/Supervised meist **Add-on + Integration** gemeinsam nutzen; bei HA Container primär die **Integration** mit externem Hub.

## Installation und Konfiguration in Home Assistant (HACS + manuell)

### Voraussetzungen

- Home Assistant **2026.1+** (freigegeben für **2026.x**)
- Für Add-on-Nutzung: Home Assistant mit **Supervisor/Add-on-Support** (HA OS oder Supervised)
- Netzwerkzugriff auf:
  - Add-on-Repository: `https://github.com/northpower25/ha-btc-alby-hub-addon`
  - Integration: `https://github.com/northpower25/ha-btc-alby-hub-integration`

### Option A: Installation mit HACS (empfohlen für die Integration)

#### A1) Add-on installieren (zuerst)

1. **Add-on-Repository hinzufügen**  
   In Home Assistant 2026.x:  
   **Einstellungen → Add-ons → Add-on-Store → Menü (⋮) → Repositories**.
2. **Repository-Maske ausfüllen**  
   Im Dialog **Repositories**:
   - Feld **Repository URL**: `https://github.com/northpower25/ha-btc-alby-hub-addon`
   - Typ/Kategorie: **Add-on repository**
   - Mit **Hinzufügen** bestätigen.
3. **Repository-Eintrag prüfen**  
   Sicherstellen, dass das Repository in der Liste erscheint, dann Dialog schließen.
4. **Add-on installieren/starten**  
   Add-on „Alby Hub (Bitcoin Lightning)“ öffnen, installieren, starten.
5. **Add-on konfigurieren**  
   Anschließend den Abschnitt „Add-on konfigurieren (Schritt für Schritt)“ durchführen.

#### A2) Integration installieren (danach)

1. **HACS installieren** (falls noch nicht vorhanden) und Home Assistant neu starten.
2. **Integration-Repository hinzufügen**  
   In HACS unter „Custom repositories“ hinzufügen:  
   `https://github.com/northpower25/ha-btc-alby-hub-integration` (Kategorie: Integration)
3. **Integration installieren** und Home Assistant neu starten.
4. **Integration einrichten**  
   Einstellungen → Geräte & Dienste → Integration hinzufügen → Alby Hub Integration auswählen.

### Option B: Manuelle Installation (ohne HACS)

#### B1) Add-on manuell installieren (zuerst)

1. **Add-on bereitstellen**
   - Entweder als Repository im Add-on-Store eintragen (wie in Option A, A1), oder
   - für lokale Entwicklung den Add-on-Ordner nach  
     `/addons/local/alby-hub-addon/` kopieren und den Supervisor neu laden.
2. **Add-on installieren/starten**  
   Add-on im Add-on-Store öffnen, installieren, starten.
3. **Add-on konfigurieren**  
   Anschließend den Abschnitt „Add-on konfigurieren (Schritt für Schritt)“ durchführen.

#### B2) Integration manuell installieren (danach)

1. **Integration manuell installieren**
   - Repository `ha-btc-alby-hub-integration` als ZIP herunterladen.
   - Entpacken und den Ordner der Custom Component nach  
     `/config/custom_components/` kopieren.
   - Home Assistant neu starten.
2. **Integration in „Geräte & Dienste“ hinzufügen**.

### Add-on konfigurieren (Schritt für Schritt)

1. Add-on öffnen und Konfiguration speichern.
2. Betriebsmodus wählen:
   - **Cloud-Modus**: `node_mode: cloud` und `nwc_connection_string` setzen.
   - **Expert-Modus**: `node_mode: expert`, Backend (`node_backend`) und Backend-Parameter setzen.
3. Add-on starten und Logs prüfen.
4. Bei Expert-Modus: Ingress öffnen, Hub initial einrichten/unlocken und NWC-Verbindung in „Apps“ erzeugen.
5. In der Integration den NWC-String eintragen und Verbindungstest ausführen.

### Funktionstest nach der Einrichtung

1. In der Integration Entitäten/Status prüfen.
2. Optional einen kleinen Test (z. B. Mini-Zahlung) durchführen.
3. Vor produktiver Nutzung Backup-/Restore-Fähigkeit verifizieren.

<a id="support-matrix-de"></a>
## Support-Matrix (MVP)

| Installationsart | Support-Status | Einschränkungen |
|---|---|---|
| Home Assistant OS | Unterstützt | Voller Supervisor-/Add-on-Flow empfohlen |
| Home Assistant Supervised | Unterstützt | Add-on-Funktion abhängig von sauberem Supervisor-Setup auf dem Host |
| Home Assistant Container | Unterstützt (eingeschränkt) | Kein nativer Add-on-Store/Supervisor; Nutzung primär über HACS-Integration und externe Dienste |

<a id="setup-tests-de"></a>
## Setup-Tests im Wizard

### Pflichttests
- Verbindungscheck (Hub/NWC erreichbar)
- Scope-Check (erforderliche Berechtigungen vorhanden)

### Optionaler Test
- 1-sat Live-Testzahlung (optional sichtbar, nicht verpflichtend)
- Immer mit kurzer Risiko-/Kosten-Erklärung

## Verhalten bei Testfehlern

- MVP-Regel: **Mit Warnung fortfahren** ist erlaubt.
- Fehler in optionalen Schritten blockieren den Abschluss nicht.
- Pflichttest-Fehler werden klar angezeigt; Nutzer kann trotzdem mit Warnhinweis abschließen.

## UX-Texte im Setup

- Inline-Erklärungen im Kurzmodus (1–2 Sätze)
- Pro Schritt ein „Mehr erfahren“-Link auf den passenden Handbuch-Abschnitt

## Sprache im MVP

- Verbindlich: **DE + EN** für Config-/Options-Flow
- Weitere Sprachen (z. B. FR, ES) folgen in späteren Releases

## HACS-Release-Policy

- Start bei Version **0.0.0**
- Versionsschema: **x.y.z**
  - `z` = pre-release
  - `y` = release
  - `x` = major release
- Jede Veröffentlichung mit Release Notes und Kompatibilitätshinweis
