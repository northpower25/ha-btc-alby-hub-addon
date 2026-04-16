# TODO für die Home-Assistant-Integration (wichtig aus Add-on-Umsetzung)

1. **NWC-Scope-Prüfung im Config-Flow verbindlich implementieren**  
   Das Add-on kann nur Syntax/Relay prüfen. Die tatsächlichen Berechtigungen (`get_info`, `get_balance`, `list_transactions`, `make_invoice`, optional `pay_invoice`) müssen im Integration-Setup aktiv validiert werden.

2. **„Continue with warning“-Verhalten im Wizard umsetzen**  
   Bei fehlgeschlagenen Pflichtchecks soll MVP-konform mit klarer Warnung fortgesetzt werden können.

3. **Cloud-Modus ohne lokale API berücksichtigen**  
   Im Cloud-Modus läuft bewusst kein lokaler Hub-API-Server im Add-on. Die Integration muss dort vollständig über NWC arbeiten.

4. **Expert-Modus duale Datenpfade nutzen**  
   In Expert-Modus kann Integration NWC + lokale HTTP-API kombinieren (z. B. schnellere Statusabfragen über REST, Zahlungen/Events über NWC).

5. **Lokales Relay als Standard im Expert-Modus bevorzugen**  
   Das Add-on stellt optional einen Relay-Proxy auf `ws://<ha-host>:3334` bereit (Weiterleitung auf lokalen Hub-Relay). Integration sollte dieses Relay priorisieren, wenn verfügbar.

6. **Kontextbezogene Hilfetexte und Handbook-Links im Flow einbauen (DE/EN)**  
   Die im Konzept definierten kurzen Erklärtexte (1–2 Sätze) und „Mehr erfahren“-Links sollten in jedem relevanten Setup-Schritt vorhanden sein.
