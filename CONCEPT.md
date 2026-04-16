# Alby Hub – Home Assistant Add-on & Integration: Konzeptdokument

> Version 1.0 · Stand: April 2026  
> Repository: [northpower25/ha-btc-lightning-node-addon](https://github.com/northpower25/ha-btc-lightning-node-addon)

---

## Inhaltsverzeichnis

1. [Projektziel](#1-projektziel)
2. [Für Einsteiger: Begriffe & Konzepte einfach erklärt](#2-für-einsteiger-begriffe--konzepte-einfach-erklärt)
3. [Architektur-Überblick](#3-architektur-überblick)
4. [Modul A – Add-on (Core Runtime)](#4-modul-a--add-on-core-runtime)
5. [Betriebsmodi & Vollständiges Onboarding](#5-betriebsmodi--vollständiges-onboarding)
6. [Modul B – HACS Custom Integration](#6-modul-b--hacs-custom-integration)
7. [Modul C – Dashboard](#7-modul-c--dashboard)
8. [Modul D – NFC & M2M Payment Layer](#8-modul-d--nfc--m2m-payment-layer)
9. [Modul E – NOSTR Relay](#9-modul-e--nostr-relay)
10. [Sicherheits- und Betriebskonzept](#10-sicherheits--und-betriebskonzept)
11. [Umsetzungsphasen](#11-umsetzungsphasen)
12. [Zusätzliche Feature-Ideen](#12-zusätzliche-feature-ideen)
13. [Technische Abhängigkeiten](#13-technische-abhängigkeiten)

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

## 2. Für Einsteiger: Begriffe & Konzepte einfach erklärt

> Dieses Kapitel richtet sich an Menschen **ohne Vorkenntnisse** in Bitcoin, Lightning oder
> Nostr. Du musst diese Konzepte **nicht im Detail verstehen**, um das Add-on zu nutzen –
> aber eine kurze Erklärung hilft, keine falschen Entscheidungen zu treffen.
>
> **Wenn du bereits weißt was Bitcoin, Lightning und NWC ist → direkt zu [Kapitel 5](#5-betriebsmodi--vollständiges-onboarding) springen.**

---

### 2.1 Bitcoin – Digitales Geld ohne Bank

Bitcoin ist digitales Geld, das ohne Bank oder Staat funktioniert. Es gehört niemandem
und jeder kann es nutzen. Es gibt davon weltweit nur 21 Millionen.

| Begriff | Einfache Erklärung |
|---|---|
| **Bitcoin (BTC)** | Die Währung selbst – wie „Euro" oder „Dollar" |
| **Satoshi (sat)** | Die kleinste Einheit: 1 Bitcoin = 100.000.000 Satoshi. 1 sat ≈ 0,001 Cent (je nach Kurs) |
| **On-Chain** | Transaktionen direkt auf der Bitcoin-Blockchain – sicher, aber langsam (Minuten bis Stunden) und mit Gebühren |
| **Self-Custody** | Du hältst deine eigenen Schlüssel → keine Bank, die dein Geld sperren kann |
| **Seed-Phrase / Recovery Phrase** | 12–24 Wörter, mit denen du dein Wallet wiederherstellen kannst. **Niemals digital speichern, niemals teilen!** |

> 💡 **1.000 sat** entsprechen bei einem BTC-Kurs von 80.000 € ungefähr **0,80 €** –
> klein genug für Kaffee, Trinkgeld oder einen NFC-Türöffner.

---

### 2.2 Lightning Network – Bitcoin schnell und günstig

Das Lightning Network ist eine **zweite Schicht** über Bitcoin. Es ermöglicht sofortige
Zahlungen (< 1 Sekunde) für winzige Gebühren (oft < 1 sat).

```
Du                    Empfänger
 │                        │
 │  Lightning Payment     │
 │─────────────────────►  │
 │  ⚡ sofort / < 1 sat   │
```

| Was du brauchst | Was du NICHT brauchst |
|---|---|
| Eine Lightning-Wallet (Alby Hub) | Eigenes technisches Wissen |
| Einen Internetzugang | Eine Bank |
| Optional: Etwas Bitcoin zum Testen | Teure Hardware (Cloud-Modus) |

> 💡 **Im Cloud-Modus** übernimmt Alby das gesamte technische Lightning-Management
> für dich. Du musst nichts über Channels, Liquidität oder Routing wissen.

---

### 2.3 Alby Hub – Dein persönlicher Lightning-Knotenpunkt

Alby Hub ist eine **kostenlose Open-Source-Software**, die als dein persönlicher
Lightning-Assistent fungiert. Er:

- hält deine Bitcoin sicher
- ermöglicht schnelle Zahlungen
- stellt eine **Lightning-Adresse** bereit (z.B. `du@alby.me`) – wie eine E-Mail-Adresse,
  aber zum Geldempfangen
- verbindet sich mit Apps wie Home Assistant über eine sichere Schnittstelle

Alby Hub kann **von Alby gehostet** (einfach, Cloud-Modus) oder **bei dir zuhause**
auf dem Home-Assistant-Server betrieben werden (Expert-Modus, volle Kontrolle).

---

### 2.4 Nostr – Nur kurz erklärt (du brauchst es nicht selbst einrichten!)

> ⚠️ **Wichtig vorab:** Im Cloud-Modus mit albyhub.com brauchst du **keinen eigenen
> Nostr-Account zu erstellen**. Alby Hub erstellt automatisch einen internen Nostr-Schlüssel
> für die sichere Kommunikation. Du siehst davon nichts und musst nichts tun.

Nostr ist ein offenes Kommunikationsprotokoll – ähnlich wie E-Mail, aber dezentral.
Alby Hub nutzt Nostr intern für die **NWC-Verschlüsselung** (siehe nächster Abschnitt),
nicht als soziales Netzwerk.

**Was du wissen musst:** Nichts. Alby Hub kümmert sich um alles.

---

### 2.5 NWC – Die sichere Fernsteuerung deines Wallets

NWC (Nostr Wallet Connect) ist die **sichere Verbindung** zwischen deinem Alby Hub
und Home Assistant. Stell dir NWC vor wie einen **individuellen Haustürschlüssel**
für HA – du entscheidest, was HA darf (Guthaben lesen, Rechnungen erstellen, zahlen).

```
NWC Connection String (Beispiel):
nostr+walletconnect://abc123...?relay=wss://relay.getalby.com/v1&secret=xyz789...
```

Dieser String sieht kompliziert aus, ist aber einfach ein **langes Passwort mit
eingebetteter Server-Adresse**. Du kopierst ihn einmal aus dem Alby Hub Dashboard
und fügst ihn in Home Assistant ein. Das war's.

**Was du wissen musst:** Diesen String wie ein Passwort behandeln. Nicht teilen.

---

### 2.6 Was du brauchst – Checkliste vor dem Start

#### Für den Cloud-Modus (Empfehlung für Einsteiger)

- [x] **Home Assistant** läuft (mit Supervisor / Add-on-Support)
- [x] **E-Mail-Adresse** (für Account auf albyhub.com)
- [x] **Sicheres Passwort** (min. 12 Zeichen, z.B. aus einem Passwort-Manager)
- [x] **Stift & Papier** (für die Backup-Recovery-Phrase!)
- [ ] Optional: Kreditkarte / SEPA-Konto (wenn du Bitcoin kaufen möchtest)

#### Was du NICHT brauchst

- ❌ Eigene Hardware für einen Lightning-Node
- ❌ Kenntnisse über Lightning-Channels oder On-Chain-Transaktionen
- ❌ Einen Nostr-Account (wird automatisch erstellt)
- ❌ Bitcoin-Vorwissen
- ❌ Technisches Hintergrundwissen über Kryptographie

---

## 3. Architektur-Überblick

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

## 4. Modul A – Add-on (Core Runtime)

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

## 5. Betriebsmodi & Vollständiges Onboarding

Das Add-on unterstützt zwei klar getrennte Betriebsmodi, die beim ersten Start ausgewählt werden.

> **Wichtiger Hinweis zur Terminologie:** Alby Hub verwendet als primäres API-Protokoll
> **NWC (Nostr Wallet Connect)** – keinen klassischen REST-API-Key. Der "API-Schlüssel"
> ist ein **NWC-Connection-String** (URI-Format: `nostr+walletconnect://…`), der im
> Alby Hub Web UI unter **Apps → Neue Verbindung** erzeugt wird.

---

### Modus 1: Cloud-Modus – Externer Hub via NWC (Einsteiger)

In diesem Modus läuft **kein eigener Lightning-Node** auf dem HA-Server. Der Nutzer
verbindet das HA-Add-on mit einem **extern gehosteten Alby Hub** über eine NWC-Verbindung.

```
Home Assistant (nur Integration, kein lokaler Hub-Container)
        │
        │  NWC (Nostr Wallet Connect) via WebSocket-Relay
        ▼
  Alby Hub (extern)
  ┌──────────────────────────────────────────┐
  │  albyhub.com (gehosted von Alby)         │  ← Einsteiger
  │  ODER eigener Server / Homelab-Hub       │  ← Fortgeschrittene
  └──────────────────────────────────────────┘
        │
        ▼
  Lightning Network
```

---

#### 5a. Vollständige Einsteiger-Anleitung: Von Null zu Home Assistant + Lightning

> Diese Anleitung begleitet dich Schritt für Schritt – auch wenn du noch **keine
> Erfahrung mit Bitcoin, Lightning oder Nostr** hast.

---

##### Schritt 1 – Alby Hub Account erstellen

1. Browser öffnen → **[https://albyhub.com](https://albyhub.com)**
2. Klicke auf **„Get Alby Hub"** oder **„Start for Free"**
3. Wähle **„Alby Cloud"** (gehostet, einfachste Option für Einsteiger)
4. **E-Mail-Adresse** eingeben und ein **starkes Passwort** wählen
   - Empfehlung: mindestens 16 Zeichen, z.B. aus einem Passwort-Manager
   - Alternativ: Sign-in mit Google-Account möglich
5. **E-Mail bestätigen** (Link im Posteingang klicken)
6. Der Hub wird automatisch eingerichtet – das dauert ca. 1–2 Minuten

> 💡 **Kein Nostr-Account nötig!** Alby Hub erstellt intern automatisch einen
> Nostr-Schlüssel für die verschlüsselte NWC-Kommunikation. Du siehst davon nichts
> und musst nichts manuell einrichten.

##### Sonderfall – Du hast bereits einen Alby-Account (ehemals getAlby)

Wenn du bereits einen bestehenden getAlby-/Alby-Hub-Account hast, musst du **keinen neuen Account** erstellen:

1. Direkt auf **[https://albyhub.com](https://albyhub.com)** einloggen.
2. Prüfen, ob dein Hub bereits vollständig initialisiert ist:
   - Unlock-Passwort gesetzt
   - Backup-Phrase sicher gesichert
   - Lightning Address aktiv (optional, aber empfohlen)
3. Falls alles vorhanden ist, direkt mit **[Schritt 4 – NWC-Verbindung für Home Assistant erstellen](#schritt-4--nwc-verbindung-für-home-assistant-erstellen)** weitermachen.
4. Falls noch kein NWC-Zugang für HA existiert:
   - `Apps` → `Add Connection`
   - Name: `Home Assistant`
   - Scopes: `get_info`, `get_balance`, `list_transactions`, `make_invoice` (+ optional `pay_invoice`)
   - NWC-String kopieren und im Add-on/Config-Flow eintragen

---

##### Schritt 2 – Alby Hub beim ersten Start einrichten (Onboarding Wizard)

Nach dem Login begrüßt dich der **Alby Hub Onboarding Wizard**:

```
Willkommen-Seite
      │
      ▼
Unlock-Passwort setzen
  → WICHTIG: Dies ist NICHT dein Login-Passwort
  → Dieses Passwort entschlüsselt deinen Wallet auf dem Server
  → Mind. 12 Zeichen, am besten anders als dein Account-Passwort
  → ⚠ Wenn du es verlierst, verlierst du Zugang zu deinem Wallet!
      │
      ▼
Lightning Address wählen
  → Du bekommst eine Adresse wie: deinname@alby.me
  → Damit kannst du genauso einfach Bitcoin empfangen wie E-Mails empfangen
  → Wähle einen Namen, der dir gehört (prüfen ob verfügbar)
      │
      ▼
Backup-Phrase aufschreiben (KRITISCH!)
  → 12 englische Wörter werden angezeigt
  → Diese aufschreiben auf Papier (NICHT digital speichern, NICHT fotografieren)
  → Mit diesen Wörtern kannst du dein Wallet auf jedem Gerät wiederherstellen
  → Ohne Backup-Phrase kein Zugriff auf Gelder bei Datenverlust!
      │
      ▼
Backup-Phrase bestätigen
  → Die Wörter in der richtigen Reihenfolge eingeben
      │
      ▼
Hub ist bereit ✓
```

> ⚠️ **Die Backup-Phrase (12 Wörter) ist dein wichtigstes Gut.**
> Bewahre sie physisch sicher auf – z.B. in einem verschlossenen Umschlag,
> einem Safe oder auf einer Metallplatte. Niemals als Screenshot oder in der Cloud.

---

##### Schritt 3 – (Optional) Erste Bitcoin kaufen

Wenn du noch keine Bitcoin besitzt, kannst du direkt im Alby Hub kleine Beträge kaufen.

> 👉 Sieh dazu den vollständigen Guide in **[Abschnitt 5b – Erste Bitcoin kaufen](#5b-erste-bitcoin-kaufen)**

---

##### Schritt 4 – NWC-Verbindung für Home Assistant erstellen

Jetzt erstellen wir den Schlüssel, den Home Assistant für die Verbindung braucht:

```
Hub-Dashboard (https://hub.getalby.com)
      │
      ▼
Linkes Menü: „Apps" klicken
      │
      ▼
„Add Connection" (oder „Neue App verbinden") klicken
      │
      ▼
App-Name eintragen:  Home Assistant
      │
      ▼
Berechtigungen auswählen:
  ✓ get_info          → Hub-Status anzeigen
  ✓ get_balance       → Guthaben als HA-Sensor
  ✓ list_transactions → Zahlungshistorie als HA-Sensor
  ✓ make_invoice      → Rechnungen aus HA erstellen
  ✓ pay_invoice       → Zahlungen aus HA senden (Achtung: Ausgaben möglich!)

  Empfehlung für Einsteiger:
  → Erst NUR die ersten 4 (lesen + Rechnungen erstellen)
  → pay_invoice erst aktivieren wenn du weißt was du tust
  → Optional: Monatsbudget setzen z.B. 50.000 sat/Monat
      │
      ▼
„Verbindung erstellen" klicken
      │
      ▼
NWC-Connection-String wird angezeigt:
  nostr+walletconnect://abc123...?relay=wss://relay.getalby.com/v1&secret=xyz...

  → DIESEN STRING KOPIEREN und sicher aufbewahren
  → Wie ein Passwort behandeln: Nicht teilen, nicht in Chat/E-Mail schicken
      │
      ▼
String im HA-Add-on unter „nwc_connection_string" eintragen
```

---

##### Schritt 5 – Home Assistant Add-on installieren & konfigurieren

```
HA → Einstellungen → Add-ons → Add-on Store
      │
      ▼
Repository hinzufügen:
  https://github.com/northpower25/ha-btc-lightning-node-addon
      │
      ▼
„Alby Hub" installieren
      │
      ▼
Add-on Konfiguration:
  node_mode: cloud
  nwc_connection_string: "nostr+walletconnect://..."  ← hier einfügen
      │
      ▼
Add-on starten → Integration einrichten
  (HA → Einstellungen → Geräte & Dienste → + Integration → „Alby Hub")
      │
      ▼
Verbindungstest → Entities werden angelegt ✓
Dashboard wird automatisch erstellt ✓
```

---

##### Schritt 6 – Alles testen

Empfohlene erste Tests nach der Installation:

| Test | Wie | Erwartetes Ergebnis |
|---|---|---|
| **Guthaben-Sensor** | HA Dashboard öffnen | Zeigt aktuelles Lightning-Guthaben in sat |
| **Erste Rechnung** | Service `lightning.create_invoice` aufrufen (1 sat) | QR-Code + Invoice-String erscheint |
| **Testzahlung empfangen** | Invoice mit einer anderen Wallet einscannen & zahlen | HA-Event `alby_hub_payment_received` wird ausgelöst |
| **Mobile Wallet** | Alby Go App installieren, per NWC mit Hub verbinden | Zahlungen auch unterwegs möglich |

---

#### 5b. Erste Bitcoin kaufen

> Dieser Abschnitt gilt für **alle, die noch keine Bitcoin besitzen** oder
> ihr Wallet aufladen möchten.

---

##### Option A: Direkt in Alby Hub kaufen (einfachste Methode)

Alby Hub integriert **MoonPay** als Zahlungsdienstleister für den Direktkauf:

```
Hub-Dashboard → „Top Up" → „Card or Bank Transfer"
      │
      ▼
MoonPay auswählen
      │
      ▼
Betrag eingeben (Empfehlung zum Testen: 10–20 €)
  → Dein Wallet als Empfänger ist bereits vorausgefüllt
      │
      ▼
Zahlungsmethode wählen:
  ○ Kreditkarte / Debitkarte (sofort, höhere Gebühren)
  ○ Banküberweisung SEPA (günstiger, 1–2 Tage)
  ○ Apple Pay / Google Pay
      │
      ▼
Identitätsverifizierung (KYC) – einmalig:
  → Ausweisfoto + Selfie (wie beim Bankkonto)
  → Dauert 5–15 Minuten
  → Wird nur beim ersten Kauf benötigt
      │
      ▼
Zahlung bestätigen → Bitcoin landen in deinem Hub-Wallet
  (bei Karte: sofort · bei Banküberweisung: wenige Stunden)
```

> ℹ️ **Gebühren bei MoonPay:** ca. 1–4 % je nach Methode. Für einen ersten Test
> mit 10 € erhältst du ca. 9,00–9,80 € Gegenwert in sat.

---

##### Option B: EU SEPA-Überweisung über Pocket (günstiger, EU)

Pocket ist ein EU-regulierter Bitcoin-Dienst für SEPA-Überweisungen:

```
1. https://pocketbitcoin.com aufrufen
2. „Bitcoin kaufen" → deine Lightning-Adresse eintragen
   (z.B. deinname@alby.me)
3. Einen IBAN-Code + Betrag anzeigen
4. Normale SEPA-Überweisung von deiner Bank senden
5. Bitcoin werden direkt an dein Alby Hub Wallet geschickt
   (typisch: wenige Minuten bis 2 Stunden)
```

**Gebühren:** ca. 1 % · Minimum ca. 25 CHF/EUR · Erreichbar aus: DE, AT, CH, EU

---

##### Option C: Strike – Kaufen, Verkaufen & direkt auf Lightning/On-Chain auszahlen

**[Strike](https://strike.me)** ist eine Bitcoin-App mit besonders tiefer Lightning-Integration.
Bitcoin wird dort **direkt auf deine Alby-Lightning-Adresse** (z.B. `deinname@alby.me`)
**oder eine On-Chain-Adresse** ausgezahlt – ohne Umwege über andere Wallets.

###### Verfügbare Einzahlungsmethoden bei Strike (Stand 2025)

| Zahlungsmethode | Verfügbar (Europa) | Details |
|---|---|---|
| **SEPA Banküberweisung** | ✅ Ja | Kostenlos, sofort oder 1–2 Werktage je nach Bank |
| **Instant SEPA** | ✅ Ja | Echtzeit, falls deine Bank es unterstützt |
| **Kreditkarte / Debitkarte** | ❌ Nein | In Europa aktuell nicht verfügbar |
| **PayPal** | ❌ Nein | Nicht verfügbar |
| **Apple Pay / Google Pay** | ❌ Nein | Nicht verfügbar |

> ℹ️ **Länder:** Strike ist für alle **36+ SEPA-Länder** verfügbar, darunter alle EU-Staaten
> sowie Schweiz, Norwegen, Island, Liechtenstein und das Vereinigte Königreich.
> Aktuelle Länderliste: [strike.me](https://strike.me)

###### Bitcoin kaufen mit Strike

```
1. https://strike.me aufrufen → App herunterladen (iOS / Android)
         │
         ▼
2. Account erstellen: E-Mail + Passwort + KYC (Ausweisfoto einmalig)
         │
         ▼
3. Euro einzahlen: Strike-App → „Add Money" → SEPA
   → Deine persönliche IBAN-Referenz wird angezeigt
   → Normale Banküberweisung senden (kostenlos)
         │
         ▼
4. Bitcoin kaufen: „Buy" → Betrag in EUR eingeben → Bestätigen
   → Keine Gebühren auf den Kauf selbst (Strike verdient am Spread)
         │
         ▼
5. Bitcoin auszahlen an Alby Hub:
   ┌──────────────────────────────────────────────────────────────┐
   │  Option A: Lightning (sofort, empfohlen)                     │
   │  Strike → „Send" → „Lightning" → Lightning-Adresse eingeben  │
   │  → deinname@alby.me eintragen → Betrag → Senden             │
   │  → Ankunft in Alby Hub: sofort (< 1 Sekunde)               │
   ├──────────────────────────────────────────────────────────────┤
   │  Option B: On-Chain (langsamer, für größere Beträge)         │
   │  Alby Hub → „Receive" → „On-Chain" → Bitcoin-Adresse kopieren│
   │  Strike → „Send" → „Bitcoin" → Adresse einfügen → Senden    │
   │  → Ankunft: ca. 30–60 Minuten (1 Bestätigung)              │
   └──────────────────────────────────────────────────────────────┘
```

> ✅ **Besonderer Vorteil:** Strike unterstützt **Lightning Addresses** direkt.
> Du musst keine Invoice erstellen – einfach `deinname@alby.me` eingeben,
> der Rest passiert automatisch.

###### Bitcoin verkaufen mit Strike (Fiat Offramp)

Strike ermöglicht auch den **Rückweg**: Bitcoin zurück in Euro auf dein Bankkonto.

```
Strike → „Sell" → Betrag in BTC oder EUR eingeben → Bestätigen
       │
       ▼
„Withdraw to Bank" → IBAN eintragen → Abheben
   → Ankunft: sofort oder 1–2 Werktage (SEPA)
```

> 💡 **Strike als vollständiges Ökosystem:** Kaufen, Halten, Senden, Empfangen
> und Verkaufen – alles in einer App, mit nativer Lightning-Unterstützung.

---

##### Option D: Exchange → Lightning (für Nutzer mit Exchange-Account)

Wenn du bereits Bitcoin auf einer Exchange (z.B. Kraken, Binance) besitzt:

```
Exchange → Abheben → Lightning Network wählen
      │
      ▼
Invoice erstellen in Alby Hub:
  lightning.create_invoice  (Betrag: gewünschte sat)
      │
      ▼
Invoice-String in Exchange einfügen → Bestätigen
  → Ankunft in Alby Hub: sofort
```

> 💡 Nicht alle Exchanges unterstützen Lightning-Auszahlungen.
> Kraken, River, Bitfinex unterstützen es. Binance: nur On-Chain.
> Bei On-Chain-Auszahlung: In Alby Hub → „Receive" → „On-Chain-Adresse" nutzen,
> dann warten (ca. 30–60 Min für On-Chain-Bestätigung).

---

##### Empfehlungs-Tabelle für Bitcoin-Erstkäufer

| Methode | Einzahlung | Abheben | Gebühren | KYC | Empfehlung |
|---|---|---|---|---|---|
| MoonPay (in Alby Hub) | Karte, SEPA, Apple Pay | Lightning / On-Chain | ~2–4 % | Ja | ⭐⭐⭐ Einfachste Option |
| Pocket (EU SEPA) | SEPA | Lightning-Adresse / On-Chain | ~1 % | Ja | ⭐⭐⭐ Günstigste EU-Option |
| **Strike** | **SEPA (kostenlos)** | **Lightning-Adresse ✅ · On-Chain ✅** | **~0–1 %** | **Ja** | **⭐⭐⭐ Beste Lightning-Integration** |
| Kraken → Lightning | Karte, SEPA | Lightning / On-Chain | ~0,2–1,5 % | Ja | ⭐⭐ Für Exchange-Nutzer |
| Bitcoin.de (DE) | SEPA (P2P) | On-Chain | variabel | Ja | ⭐ P2P, mehr Aufwand |

> ⚠️ **Rechtlicher Hinweis:** Der Kauf von Bitcoin ist in Deutschland und Österreich
> legal. Bei Gewinnen aus dem Verkauf (nach weniger als einem Jahr Haltedauer) kann
> Einkommensteuer anfallen. Bei kleinen Beträgen (< 600 € Gewinn pro Jahr) ist dies
> in Deutschland steuerfrei.

---

- **Voraussetzung:** Account auf [albyhub.com](https://albyhub.com) (kostenlos für Basisplan)
- **Vorteile:** Kein Channel-Management, keine Hardware, sofort einsatzbereit
- **Nachteile:** Nicht vollständig self-custodial bei albyhub.com (Alby hält Infrastruktur)
- **Geeignet für:** Einsteiger, Test-Setups, Nutzer ohne dedizierte Hardware

> **Datenschutz-Hinweis:** Beim Cloud-Modus mit albyhub.com verarbeitet Alby Transaktionsdaten.
> Für vollständige Privatsphäre → Expert-Modus mit eigenem LDK/LND wählen.

---

### Modus 2: Expert-Modus – Lokaler Hub mit eigener Node (vollständige Self-Custody)

> ⚠️ **Für Einsteiger nicht empfohlen.** Dieser Modus erfordert grundlegendes Verständnis
> von Lightning-Channels und On-Chain-Bitcoin. **Starte immer zuerst mit dem Cloud-Modus**
> und wechsle erst dann hierher, wenn du dich vertraut gemacht hast.

In diesem Modus läuft **Alby Hub vollständig lokal** im HA-Add-on-Container. Der Nutzer
hat die Wahl des Lightning-Backends.

```
Home Assistant Add-on (Alby Hub Container läuft lokal)
        │
        │  NWC lokal ODER direkte lokale HTTP-API
        ▼
  Lightning Backend (lokal auf dem HA-Host)
  ┌─────────────────────────────────────────┐
  │  LDK (embedded) ← Standard, empfohlen  │  kein Extra-Setup
  │  LND (extern)   ← eigene LND-Node      │  REST + Macaroon
  │  CLN (Core LN)  ← eigene CLN-Node      │  REST + Rune
  │  Phoenixd       ← Phoenix-Node         │  lokale API
  │  Cashu          ← Cashu Ecash Mint     │  experimentell
  └─────────────────────────────────────────┘
        │
        ▼
  Lightning Network  (direkte Peer-Verbindungen)
```

#### Für Fortgeschrittene mit bestehender eigener Lightning Node

Wenn du bereits eine eigene Lightning Node betreibst (z.B. LND, CLN oder Phoenixd), ist der empfohlene Ablauf:

1. Add-on auf `node_mode: expert` setzen und starten.
2. Im lokalen Alby-Hub-UI das passende Backend auswählen (`lnd`, `cln` oder `phoenixd`).
3. Node-Zugangsdaten hinterlegen:
   - **LND:** REST-URL + TLS + Admin/Invoice-Macaroon
   - **CLN:** REST-URL + Rune
   - **Phoenixd:** lokale API-Zugangsdaten
4. Verbindung im Hub testen (Info/Balance abrufen).
5. Danach erst die HA-Integration per NWC verbinden (`Apps` → `Add Connection`).
6. Für Sicherheit pro Verbindung enge Scopes und ein Ausgabenbudget setzen.

> Empfehlung: Für Automationen einen separaten NWC-Zugang mit limitierter Berechtigung anlegen
> (z.B. nur `make_invoice`, kein `pay_invoice`), damit mobile/automatische Flows sauber getrennt sind.

#### NWC-String beim lokalen Hub erzeugen

Der Ablauf ist identisch zum Cloud-Modus, aber das Hub-Dashboard ist unter
`http://homeassistant.local:8080` (oder via HA-Ingress) erreichbar:

```
1. HA-Ingress-Panel „Alby Hub" öffnen  →  http://homeassistant.local:8080
        │
        ▼
2. Alby Hub mit Unlock-Passwort entsperren (beim Erststart setzen)
        │
        ▼
3. „Apps" → „Add Connection" → Name: „HA Integration"
   Berechtigungen + optionales Budget setzen
        │
        ▼
4. NWC-Connection-String kopieren:
   nostr+walletconnect://<lokale-pubkey>?relay=ws://localhost:7447/v1&secret=<geheimnis>
   ODER mit dem Alby-Cloud-Relay:
   nostr+walletconnect://<pubkey>?relay=wss://relay.getalby.com/v1&secret=<geheimnis>
        │
        ▼
5. String als „nwc_connection_string" im HA-Integration-Config-Flow eintragen
```

- **Voraussetzung:** Laufende Lightning-Node oder LDK (embedded – kein Extra-Setup)
- **Vorteile:** Vollständige Self-Custody, alle Daten lokal, keine Drittpartei
- **Nachteile:** Channel-Management erforderlich, On-chain-Kapital für LN-Channels nötig
- **Geeignet für:** Fortgeschrittene, Selbst-Hoster, Nutzer mit eigener Node

#### Erste Bitcoin in den lokalen Hub laden (Expert-Modus)

Beim lokalen LDK-Backend brauchst du On-Chain-Bitcoin, um Lightning-Channels zu öffnen:

```
Methode 1: Receive → On-Chain-Adresse
  Hub-Dashboard → „Receive" → „On-Chain"
  → Bitcoin-Adresse erscheint (bc1q...)
  → Von Exchange oder anderem Wallet senden
  → Nach 1–3 Bestätigungen (~30 Min) erscheinen sie im Hub
  → Alby Hub öffnet automatisch einen Lightning-Channel

Methode 2: Boltz Submarine Swap (Lightning → On-Chain → Channel)
  → Wenn du bereits Lightning-Bitcoin hast
  → Hub-Dashboard → „Swap" → von Lightning zu On-Chain
```

> 💡 **LDK empfohlen:** Das eingebettete LDK-Backend öffnet automatisch
> Lightning-Channels und kümmert sich um Channel-Management. Kein eigener
> Node-Betrieb nötig.

---

### Modus-Vergleichstabelle

| Eigenschaft | Cloud-Modus (albyhub.com) | Expert-Modus (lokal/LDK) |
|---|---|---|
| Self-Custody | ⚠️ Eingeschränkt (Alby Infrastruktur) | ✅ vollständig |
| Setup-Aufwand | ⭐ minimal (15 Min, inkl. Bitcoin-Kauf) | ⭐⭐⭐ mittel-hoch |
| Vorwissen nötig | ❌ keins | ⚠️ Lightning-Grundlagen |
| Channel-Management | automatisch von Alby | automatisch via LDK |
| Kapital erforderlich | nein | ja (für LN-Channels, mind. ~50.000 sat) |
| Offline-Betrieb | eingeschränkt | vollständig |
| Datenschutz | eingeschränkt | vollständig |
| HA-Hardware-Anforderungen | minimal | mittel (mind. 4 GB RAM) |
| Bitcoin kaufen | ✅ direkt in Alby Hub (MoonPay) | ⚠️ über Exchange + On-Chain |
| **Empfehlung** | **Einsteiger / Testen** | **Fortgeschrittene** |

---

### 5c. NWC – Nostr Wallet Connect: Technischer Hintergrund

NWC ist das primäre API-Protokoll von Alby Hub. Es ist ein offenes Protokoll
([nwc.dev](https://nwc.dev)) zum sicheren Steuern von Lightning-Wallets.

#### NWC Connection String – Aufbau

```
nostr+walletconnect://<wallet-pubkey>
  ?relay=wss://relay.getalby.com/v1
  &secret=<client-secret-hex>
  &lud16=user@albyhub.com        ← optional: Lightning Address
```

| Bestandteil | Bedeutung |
|---|---|
| `wallet-pubkey` | Nostr-Public-Key des Alby Hub (Empfänger) |
| `relay` | WebSocket-Relay-URL für die NWC-Kommunikation |
| `secret` | Geheimer Schlüssel des HA-Clients (32 Byte hex) |
| `lud16` | Optional: Lightning Address des Wallets |

#### NWC-Berechtigungs-Scopes

Beim Erzeugen des NWC-Connection-Strings lassen sich Berechtigungen granular setzen:

| Scope | Beschreibung | Benötigt für |
|---|---|---|
| `get_info` | Node-Infos abrufen | Status-Sensoren |
| `get_balance` | Wallet-Guthaben abrufen | Balance-Sensoren |
| `list_transactions` | Zahlungshistorie abrufen | Payment-Sensoren |
| `make_invoice` | BOLT11-Rechnungen erstellen | `lightning.create_invoice` |
| `pay_invoice` | BOLT11-Rechnungen bezahlen | `lightning.send_payment` |
| `lookup_invoice` | Rechnungsstatus abfragen | Invoice-Tracking |
| `get_budget` | Budget-Limits abfragen | Safe-Mode-Überwachung |
| `sign_message` | Nachrichten signieren | Authentifizierung |

#### NWC-Protokoll: Request/Response-Ablauf

```
HA Integration (NWC Client)              Alby Hub (NWC Server)
        │                                        │
        │  1. Verschlüsselte Nostr-Nachricht      │
        │     (NIP-04 Encryption)                │
        │─────────────────────────────────────► │
        │     Event Kind: 23194                  │
        │                                        │
        │  2. Hub verarbeitet Request            │
        │                                        │
        │  3. Verschlüsselte Antwort             │
        │◄──────────────────────────────────── │
        │     Event Kind: 23195                  │
        │                                        │
```

**Alle NWC-Requests laufen über das Nostr-Relay** (WebSocket).
Bei lokalem Hub kann `ws://localhost:7447/v1` als Relay verwendet werden
(integrierter lokaler Relay im Alby Hub), um Internet-Unabhängigkeit zu erreichen.

---

### 5d. Lokale HTTP REST API (nur Expert-Modus / lokaler Hub)

Zusätzlich zu NWC bietet der lokale Alby Hub eine **direkte REST API** am Port 8080.
Diese ermöglicht der HA-Integration schnellere Abfragen ohne Nostr-Relay-Latenz.

**Authentifizierung:** Session-basiert (Unlock-Passwort beim Erststart gesetzt).
Für automatisierte Abfragen sollte über die REST API eine App-Session erzeugt werden.

#### Wichtige REST-Endpoints

| Methode | Endpoint | Beschreibung |
|---|---|---|
| `GET` | `/api/info` | Node-Info (Pubkey, Version, Backend-Typ) |
| `GET` | `/api/wallet/balance` | Wallet-Balance (Lightning + On-Chain) |
| `GET` | `/api/transactions` | Zahlungshistorie |
| `POST` | `/api/invoices` | BOLT11-Invoice erstellen |
| `POST` | `/api/payments` | Invoice bezahlen |
| `GET` | `/api/apps` | Verbundene Apps auflisten |
| `POST` | `/api/apps` | Neue NWC-App/Verbindung erstellen |
| `GET` | `/api/channels` | Lightning-Kanäle |
| `GET` | `/api/peers` | Verbundene Peers |
| `GET` | `/api/health` | Health-Check (kein Auth nötig) |

#### Beispiel: Invoice erstellen

```http
POST http://localhost:8080/api/invoices
Content-Type: application/json
Cookie: session=<session-token>

{
  "amount": 1000,
  "description": "Kaffeezahlung",
  "expiry": 3600
}
```

**Response:**
```json
{
  "payment_request": "lnbc10n1pj...",
  "payment_hash": "abc123...",
  "expires_at": "2026-04-16T16:00:00Z"
}
```

#### Beispiel: Payment senden

```http
POST http://localhost:8080/api/payments
Content-Type: application/json
Cookie: session=<session-token>

{
  "invoice": "lnbc10n1pj...",
  "amount": 1000
}
```

**Response:**
```json
{
  "payment_hash": "abc123...",
  "fee": 1,
  "preimage": "def456..."
}
```

---

### Konfigurationsoptionen (Add-on)

```yaml
# Gemeinsam für beide Modi
node_mode: cloud            # cloud | expert
log_level: info
nostr_relay_enabled: false
backup_passphrase: ""
external_access_enabled: false

# ── Cloud-Modus (NWC Connection String von albyhub.com) ────────────
# 1. Account erstellen: https://albyhub.com
# 2. Hub-Dashboard → Apps → Add Connection → Berechtigungen setzen
# 3. NWC-String kopieren und hier eintragen
nwc_connection_string: ""   # nostr+walletconnect://...

# ── Expert-Modus (lokaler Alby Hub) ────────────────────────────────
# Der NWC-String wird nach dem ersten Start im lokalen Hub-Dashboard
# (http://homeassistant.local:8080 / HA-Ingress) erzeugt.
# Zusätzlich wird die lokale HTTP-API direkt genutzt.
bitcoin_network: mainnet    # mainnet | testnet | signet | mutinynet
node_backend: LDK           # LDK | LND | CLN | Phoenixd | Cashu
hub_unlock_password: ""     # Wird beim Erststart im Hub gesetzt
lnd_rest_url: ""
lnd_macaroon_hex: ""
lnd_tls_cert: ""
cln_rest_url: ""
cln_rune: ""
```

---

## 6. Modul B – HACS Custom Integration

Die Integration koppelt Home Assistant direkt an die Alby Hub API und stellt Entities, Services und Events bereit.

### Config Flow

Der Setup-Wizard führt auch absolute Einsteiger durch die Verbindung:

```
Benutzer öffnet "Integration hinzufügen" → „Alby Hub" suchen
    │
    ▼
Schritt 1: Verbindungstyp wählen
           ○ Cloud-Modus (NWC Connection String von albyhub.com)
           ○ Expert-Modus (Lokaler Hub, URL eingeben)
    │
    ├── Cloud-Modus:
    │   ▼
    │   NWC Connection String eingeben
    │   (aus albyhub.com → Apps → Add Connection → String kopieren)
    │   → Direkt-Link zur Anleitung: [Wie bekomme ich meinen NWC-String?]
    │
    └── Expert-Modus:
        ▼
        Hub-URL eingeben (Standard: http://localhost:8080)
        Verbindungstest
    │
    ▼
Verbindungstest → Wallet-Infos werden abgerufen
    │
    ▼
Bestätigung: Guthaben, Lightning-Adresse, Hub-Version anzeigen
    │
    ▼
Entities werden angelegt → Dashboard wird automatisch erstellt ✓
```

> 💡 **Einsteiger-Hilfe im Config Flow:** Für Nutzer ohne NWC-Erfahrung wird
> eine inline-Anleitung mit direktem Link zu albyhub.com angezeigt.

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

## 7. Modul C – Dashboard

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

### Praxisbeispiele: HA Integration + Add-on im Alltag nutzen

Beispiele für den direkten Nutzen im Home Assistant:

- **Tür-/Schalter-Freigabe nach Zahlung:** Automation reagiert auf `alby_hub_payment_received` und öffnet z.B. ein Smart Lock.
- **Spendenmodus im Dashboard:** Besucher scannen einen QR-Code, bezahlen sofort per Lightning.
- **Pay-per-Use-Geräte:** Waschmaschine, 3D-Drucker oder Ladepunkt startet erst nach erfolgreicher Zahlung.
- **Companion App als Wallet-Frontend:** Benutzer erstellt in Home Assistant Rechnungen, zeigt QR-Codes an und kann Zahlungen direkt aus der Home Assistant App initiieren; für QR-Scan ist je nach Plattform (iOS/Android) ggf. eine eigene Shortcut/Intent-Integration nötig.

> Damit kann die **Home Assistant Companion App** praktisch als Wallet-Oberfläche genutzt werden:
> Rechnung erstellen/anzeigen (Empfangen) und Ziel-Rechnungen bzw. Lightning-Adressen eingeben (Bezahlen).

### Lovelace Card Beispiel 1 – Rechnung erstellen (BOLT12 oder klassische Lightning-Rechnung)

```yaml
type: vertical-stack
cards:
  - type: entities
    title: "⚡ Lightning Rechnung erstellen"
    show_header_toggle: false
    entities:
      - entity: input_number.lightning_amount
        name: Betrag
      - entity: input_select.lightning_amount_unit
        name: Einheit
      - entity: input_select.lightning_currency
        name: Fiat-Währung (bei EUR/USD)
      - entity: input_text.lightning_memo
        name: Beschreibung
      - entity: input_select.lightning_invoice_type
        name: Rechnungstyp
  - type: button
    name: Rechnung erzeugen
    icon: mdi:lightning-bolt
    tap_action:
      action: call-service
      service: script.alby_create_receive_request
  - type: markdown
    content: |
      Ergebnis:
      - Bei `invoice_type: bolt12_offer` wird ein BOLT12 Offer angezeigt.
      - Bei `invoice_type: bolt11` wird eine klassische Lightning-Rechnung angezeigt.
      - `script.alby_create_receive_request` konvertiert bei Bedarf EUR/USD → sat/BTC über den BTC-Preis-Sensor.
```

Empfohlene Helper-Entities:

- `input_number.lightning_amount`
- `input_select.lightning_amount_unit` (`EUR`, `USD`, `SAT`, `BTC`)
- `input_select.lightning_currency` (`EUR`, `USD`)
- `input_select.lightning_invoice_type` (`bolt12_offer`, `bolt11`)
- `input_text.lightning_memo`

### Lovelace Card Beispiel 2 – Bezahlen (QR-Scan + Invoice/Lightning Address)

```yaml
type: vertical-stack
cards:
  - type: entities
    title: "⚡ Lightning bezahlen"
    show_header_toggle: false
    entities:
      - entity: input_text.lightning_payment_target
        name: Rechnung / Lightning-Adresse / LNURL
      - entity: input_number.lightning_pay_amount
        name: Betrag (optional bei Lightning-Adresse)
      - entity: input_select.lightning_pay_amount_unit
        name: Einheit (sat/BTC/EUR/USD)
      - entity: input_select.lightning_pay_currency
        name: Fiat-Währung
  - type: horizontal-stack
    cards:
      - type: button
        name: QR scannen (Companion App)
        icon: mdi:qrcode-scan
        tap_action:
          action: call-service
          service: script.alby_scan_qr_to_target
      - type: button
        name: Jetzt bezahlen
        icon: mdi:send
        tap_action:
          action: call-service
          service: script.alby_pay_request
  - type: markdown
    content: |
      `script.alby_pay_request` entscheidet automatisch:
      - BOLT11-Rechnung → `lightning.send_payment`
      - Lightning-Adresse/LNURL → `lightning.pay_lnurl` bzw. Address-Resolve + Zahlung
      - Betrag in EUR/USD wird vor dem Senden in sat/BTC umgerechnet.
```

#### Hinweis zur Umsetzung der Beispiel-Skripte

Die in den Karten referenzierten Skripte sind **Beispielnamen**, die in der HA-Integration
als eigene Scripts/Automationen angelegt werden:

- `script.alby_create_receive_request`: Liest Betrag + Einheit, rechnet bei Bedarf (EUR/USD → sat/BTC)
  und erstellt abhängig von `input_select.lightning_invoice_type` entweder BOLT12 Offer oder BOLT11 Invoice.
- `script.alby_scan_qr_to_target`: **Konzeptionelles Beispiel** für mobile QR-Erfassung; benötigt eine
  eigene App-Umsetzung (z.B. App-Aktion/Deep-Link/Intent oder Shortcut), die den Scan-Text als Service-Daten
  in `input_text.lightning_payment_target` schreibt.
- `script.alby_pay_request`: Prüft das Ziel-Format (`lnbc...`/`lntb...` = BOLT11, `name@domain` = Lightning Address,
  `lnurl...` = LNURL) und ruft den passenden Service auf (`lightning.send_payment` oder `lightning.pay_lnurl`).

---

## 8. Modul D – NFC & M2M Payment Layer

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

## 9. Modul E – NOSTR Relay

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

## 10. Sicherheits- und Betriebskonzept

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

## 11. Umsetzungsphasen

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

## 12. Zusätzliche Feature-Ideen

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

## 13. Technische Abhängigkeiten

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
