# Desktop-System-Konzept: Arch Linux, Hyprland und Quickshell

**Version:** 0.1 – Architektur- und Umsetzungsentwurf  
**Stand:** 19. Oktober 2026  
**Status:** Konzept, keine Implementierungsbehauptung

> **Bestandsgrenze:** Die vorliegende Projektbeschreibung dokumentiert eine Taskbar mit Home-Button, Schnellzugriffen auf Settings/Browser/Files/Terminal, Workspace-Anzeige, Systemindikatoren, Uhr/Datum und Benachrichtigungen sowie ein geplantes Widget-System. Die eigentliche `install.sh` und der erwähnte Screenshot waren nicht als separate Dateien verfügbar. Paketlisten, vorhandene Dateien, genaue Optik und tatsächliche Implementierungsstände müssen deshalb in Phase 0 verifiziert werden.

## 1. Executive Summary

Das Produkt sollte zunächst als **Desktop-Shell für eine bestehende Arch-Linux-Installation** entwickelt werden, nicht sofort als vollständige Distribution. Die Shell erhält eine eigene Identität durch eine dock-inspirierte Taskbar, klare Workspace-Interaktion, ein einheitliches Popup-System, zentrale Settings und ein kontrolliert erweiterbares Widget-Modell.

Die wichtigsten Architekturregeln:

1. **Quickshell/QML ist Präsentations- und Interaktionsschicht.** Es verwaltet keine Netzwerkprotokolle, Authentifizierung oder privilegierten Systemänderungen selbst.
2. **Hyprland bleibt für Fenster, Fokus, Monitore und Workspaces zuständig.** Die Shell liest Zustände über unterstützte Schnittstellen und sendet klar begrenzte Aktionen.
3. **Linux-Dienste bleiben die Quelle der Wahrheit.** Beispiele: NetworkManager oder eine bewusst gewählte Alternative für Netzwerk, PipeWire/WirePlumber für Audio, BlueZ für Bluetooth, UPower/Kernel-Schnittstellen für Energie und ein etablierter Authentifizierungs-/Lock-Mechanismus.
4. **Ein gemeinsames Designsystem und ein gemeinsamer Konfigurationsdienst** versorgen Taskbar, Widgets, Settings, Control Center und OSD.
5. **MVP vor Plugin-Plattform.** Integrierte Widgets zuerst; lokale Erweiterungen danach; ein öffentliches Repository erst, wenn API, Sicherheitsmodell und Updateprozess stabil sind.
6. **Installation muss idempotent, nachvollziehbar und reversibel sein.** Keine unbedingte Überschreibung vorhandener Konfigurationen und keine ungefragte Entfernung von Paketen.

### Produktpositionierung

Ein minimalistischer, schneller und hochwertiger Wayland-Desktop mit macOS-inspirierter visueller Ruhe und Dock-Interaktion sowie Windows-inspirierter Produktivität: Workspaces, Fensterübersicht, Snap-/Tiling-Aktionen, Systemverwaltung und gute Tastaturbedienung. Die Kombination soll eine eigene Designsprache ergeben, keine Kopie bestehender Betriebssysteme.

---

## 2. Statusmodell: Fakten, Empfehlungen und offene Punkte

### Aus der Projektbeschreibung bekannte Ausgangslage

- Arch Linux, Hyprland und Quickshell/QML sind als technische Basis festgelegt.
- Die vorhandene Taskbar ist in linken App-/Home-Bereich, mittlere Workspace-Anzeige und rechten Systembereich gegliedert.
- Der vorhandene Taskbar-Aufbau nennt Home, Settings, Browser, Files, Terminal, Workspaces, Statussymbole, Uhr/Datum und Benachrichtigungen.
- Das Widget-System ist konzeptionell vorgesehen: Katalog, Aktivierung/Deaktivierung, Sortierung und dynamische Anordnung.
- Neomorphism ist die gewählte Stilrichtung.
- Die aktuelle Installationslogik konfiguriert eine bereits vorhandene Arch-Installation. Ein vollständiger OS-Installer wäre ein späteres, getrenntes Produkt.

### Empfehlungen, noch nicht als implementiert zu verstehen

- Zentrale Design-Tokens und Theme-Provider
- Gemeinsamer Konfigurationsdienst mit Schema-Versionierung
- Hardware-/Service-Erkennung über Adapter
- Einheitliches Popup- und OSD-Grundsystem
- Declarative Widget-Manifeste und definierte Slot-Typen
- Settings mit Live-Anwendung und Zurücksetzen
- Logs, Recovery-Modus und automatisierte Smoke-Tests
- Paketierung in getrennte Core- und optionale Funktionspakete

### Phase-0-Fragen

- Welche Pakete installiert `install.sh` aktuell und welche Dienste aktiviert es?
- Welche QML-Dateien, Konfigurationsdateien und Startmechanismen existieren bereits?
- Wie wird Quickshell gestartet und neu gestartet?
- Welche Netzwerk-, Audio-, Bluetooth-, Power-, Notification- und Polkit-Komponenten sind bereits vorgesehen?
- Welche Funktionen werden über Shell-Skripte, QML, D-Bus oder Hyprland IPC umgesetzt?
- Wie wird mit bestehenden Benutzerkonfigurationen, Backups und Deinstallation umgegangen?
- Wie sieht die Taskbar bei verschiedenen Auflösungen, Skalierungen und mehreren Monitoren aus?

---

## 3. Produktprinzipien

### 3.1 Minimalismus ohne Funktionsverlust

- Installiere nur die Kernkomponenten, die für eine brauchbare Sitzung erforderlich sind.
- Optionale Anwendungen und Widgets sind separat auswählbar.
- Vermeide zwei Programme mit identischer Aufgabe, aber entferne keine Bibliothek oder Hintergrunddienste allein deshalb, weil eine eigene GUI deren Bedienoberfläche ersetzt.
- Erweitere die Oberfläche schrittweise. Einstellungen, die selten benötigt werden, gehören in Unterseiten statt in den ersten Bildschirm.
- Stelle wichtige Funktionen auch per Tastatur bereit.

### 3.2 Visuelle Identität

Neomorphism ist ein Akzent, keine Pflicht für jedes Element. Weiche Oberflächen und Schatten funktionieren bei Karten und ruhigen Flächen; wichtige Schaltflächen, Fokusindikatoren und Statuszustände benötigen jedoch klaren Kontrast. Für Lesbarkeit, Tastaturfokus und Zustände haben Kontrast und Eindeutigkeit Vorrang vor Schatteneffekten.

### 3.3 Progressive Komplexität

- **Standard:** klare Taskbar, Launcher, Workspaces, Uhr, Benachrichtigungen und grundlegende Schnellaktionen.
- **Erweitert:** Widget-Verwaltung, Multi-Monitor-Optionen, detaillierte Fensterregeln, individuelle Shortcuts.
- **Optional:** Produktivitätsmodule, Desktop-Widgets, erweiterte Statistiken und Drittanbieter-Erweiterungen.

### 3.4 Stabilität vor Animation

Alle Animationen müssen abschaltbar oder reduzierbar sein. Bei Shell-Neustart, langsamen Diensten, fehlender Hardware und fehlerhaften Modulen muss der Desktop weiterhin bedienbar bleiben.

---

## 4. Zielbild der Taskbar

### 4.1 Empfohlene Grundstruktur

Drei visuell getrennte Zonen in einer gemeinsamen, zurückhaltenden Dock-Fläche:

1. **Links: Systemmenü und App-Dock**
2. **Mitte: Workspaces / optional Fensterübersicht**
3. **Rechts: Statusindikatoren, Benachrichtigungen und Uhr**

Die Taskbar bleibt auf jedem Monitor verfügbar, aber nicht jede Zone muss auf jedem Monitor identisch sein. Die Konfiguration soll zwischen „Primärer Monitor“ und „Alle Monitore“ wählen können. Für MVP genügt eine Taskbar pro Monitor mit lokalem Workspace-Kontext; globale Synchronisierung ist ein späteres Detail.

### 4.2 Linker Bereich

**Beibehalten:** Home/Systemmenü und angeheftete Schnellzugriffe.

**Vorschlag:**
- Home öffnet ein kleines Systemmenü mit Suche, zuletzt verwendeten/angehefteten Apps, Einstellungen, Power-Aktionen und Systeminformationen.
- Apps werden als Dock-Icons dargestellt. Angeheftete Apps bleiben sichtbar; laufende Apps erhalten einen klaren Punkt oder Strich.
- Klick auf eine nicht laufende App startet sie. Klick auf eine laufende App fokussiert ihr Fenster; bei mehreren Fenstern öffnet ein weiterer Klick oder Rechtsklick eine Fensterliste.
- Rechtsklick/alternatives Menü: Starten, Anheften/Lösen, alle Fenster anzeigen, App-Informationen.
- App-Symbole und Startbefehle kommen aus Desktop-Entry-Metadaten, nicht aus fest codierten Pfaden.

**Nicht im MVP:** dynamische Icon-Vergrößerung mit aufwendiger physikalischer Animation. Erst Baseline, Hover, aktiver Zustand und laufender Indikator sauber implementieren.

### 4.3 Mittlerer Bereich: Workspaces

- Workspace-Indikatoren mit klar erkennbarem aktiven Zustand.
- Optional Fensteranzahl oder dezente Aktivitätsanzeige.
- Klick wechselt den Workspace; Mausrad-Steuerung nur optional, um versehentliche Wechsel zu vermeiden.
- Tastatur-Shortcuts bleiben die schnellste Bedienung.
- Ein Overview-Button öffnet eine Fensterübersicht; diese Funktion ist getrennt von der normalen Workspace-Anzeige.
- Pro Monitor muss der Indikator den tatsächlichen Hyprland-Zustand darstellen. Nicht annehmen, dass Workspace-IDs global und auf allen Monitoren gleichartig genutzt werden.
- Benannte Workspaces und Sonder-Workspaces dürfen nicht zu fehlerhaften oder doppelten Einträgen führen.

Hyprland stellt IPC-Sockets für Abfragen/Aktionen und Live-Events bereit. Die Implementierung soll Event-Updates nutzen und bei Start, Reconnect und Konfigurationsreload einen vollständigen Zustand neu abfragen. Sie darf sich nicht allein auf Events verlassen. Siehe [Hyprland IPC-Dokumentation](https://wiki.hypr.land/ipc/).

### 4.4 Rechter Bereich

Empfohlene Reihenfolge:

1. Optionale Statusindikatoren (Netzwerk, Audio, Bluetooth, Akku)
2. Benachrichtigungen / Nicht-stören
3. Uhr und Datum

Die Reihenfolge ist in Settings konfigurierbar. Standardmäßig sichtbare Symbole sollten auf das Wesentliche beschränkt bleiben. Nicht verfügbare Hardware wird ausgeblendet, nicht als defekt dargestellt. Ein Statusindikator öffnet das passende Popup; Klick auf die Uhr öffnet Kalender/Uhr, Klick auf Benachrichtigungen öffnet das Notification Center.

**Konfigurierbare Darstellung:**
- Kompakt: kleine Symbole, Uhrzeit, wenige permanente Statusindikatoren.
- Erweitert: Uhrzeit plus Datum, zusätzliche Indikatoren, optional Medienstatus.
- Pro Indikator: sichtbar/ausgeblendet, Position, Popup aktiv, optional Badge/Text.
- Kritische Informationen wie stummgeschaltetes Mikrofon, Aufnahme-/Screen-Share-Status oder niedriger Akkustand dürfen nicht ausschließlich durch Farbe kommuniziert werden.

### 4.5 Dock- und Popup-Verhalten

- Eine einheitliche Popup-Komponente mit gemeinsamer Geometrie, Rand, Schatten, Fokusregeln, Escape-Verhalten und Öffnungs-/Schließanimation.
- Popups öffnen nahe am auslösenden Element und bleiben innerhalb des verfügbaren Monitorbereichs.
- Nur ein primäres Popup gleichzeitig, außer explizit zusammengehörige Oberflächen benötigen mehrere Fenster.
- Klick außerhalb schließt das Popup, sofern keine laufende Interaktion oder ein Dialog dies verhindert.
- Fokus darf beim Öffnen nicht unvorhersehbar verloren gehen.
- Bei mehreren Monitoren öffnet das Popup auf dem Monitor des auslösenden Elements.
- Im Vollbildmodus darf die Taskbar sich je nach Einstellung automatisch verbergen; ein verlässlicher Weg zum Einblenden bleibt erhalten.

### 4.6 Responsive Regeln

- Mindestbreite je Zone festlegen; bei Platzmangel zuerst optionale Statussymbole und Textlabels reduzieren.
- App-Dock kann in einen horizontal scrollbaren Bereich wechseln oder weitere Apps in ein Overflow-Menü verschieben.
- Workspace-Zone darf nicht von der Uhr überlagert werden.
- Skalierung nicht nur über Pixelwerte fest verdrahten; Layouts müssen bei 100 %, 125 %, 150 % und 200 % getestet werden.
- Touch-Ziele größer dimensionieren, falls Touchscreens unterstützt werden sollen.

---

## 5. Designsystem

Alle Werte sind Startwerte, keine aus dem Screenshot gemessenen Werte. Sie sollten in einer zentralen Theme-Datei definiert werden.

### 5.1 Token-Vorschlag

| Token | Startwert | Zweck |
|---|---:|---|
| `space.1` | 4 px | sehr kleiner Abstand |
| `space.2` | 8 px | Icon-/Textabstand |
| `space.3` | 12 px | kompakte Innenabstände |
| `space.4` | 16 px | Standardabstand |
| `space.6` | 24 px | Gruppenabstand |
| `radius.sm` | 8 px | kleine Controls |
| `radius.md` | 12 px | Buttons/Karten |
| `radius.lg` | 18 px | Popups |
| `radius.pill` | 999 px | Pills/Indikatoren |
| `control.height` | 36–40 px | Standardbedienung |
| `taskbar.height` | 56–68 px | erste Desktop-Baseline |
| `icon.sm` | 16 px | kompakte Statussymbole |
| `icon.md` | 20–24 px | Standard-Icons |
| `icon.lg` | 28–36 px | Dock-Icons |
| `motion.fast` | 100–140 ms | Hover/Fokus |
| `motion.normal` | 160–220 ms | Popup/Toggle |
| `motion.slow` | 240–320 ms | größere Übergänge |

### 5.2 Farben

Definiere semantische Rollen statt Komponenten-spezifischer Farben:

- `surface.base`, `surface.raised`, `surface.sunken`, `surface.overlay`
- `text.primary`, `text.secondary`, `text.disabled`
- `border.subtle`, `border.strong`
- `accent`, `accent.hover`, `accent.pressed`, `onAccent`
- `state.success`, `state.warning`, `state.error`, `state.info`
- `focus.ring`

Dark Mode sollte dunkle Oberflächen mit gut unterscheidbaren Ebenen verwenden; Light Mode helle, leicht getönte Oberflächen. Akzentfarbe ist konfigurierbar. Wallpaper-basierte Farben sind optional und müssen Kontrastprüfungen bestehen. Dynamische Farben dürfen niemals kritische Zustände unlesbar machen.

### 5.3 Neomorphismus mit Maß

- Pro Element maximal eine subtile helle und eine dunkle Schattenrichtung.
- Erhabene Flächen für interaktive Controls, vertiefte Flächen für Eingaben oder aktive Auswahl.
- Schatten bei kleinen Icons reduzieren; keine Schatten auf jedem Textlabel.
- Aktive Zustände zusätzlich durch Form, Border, Icon oder Text ausdrücken.
- Hochkontrast-/reduzierte-Effekte-Modus bereitstellen.
- Blur und Transparenz als optionale Effekte; solide Fallback-Flächen müssen vorhanden sein.

### 5.4 Typografie und Icons

- Eine gut lesbare UI-Schriftfamilie, feste Größenstufen und konsistente Gewichte.
- Ziffern in Uhr, Akku und Statistiken möglichst tabellarisch ausrichten.
- Ein einheitlicher Icon-Satz und eine konsistente Strichstärke; keine Mischung aus Outline-, Filled- und Emoji-Icons ohne klare Regeln.
- Jedes Icon-only-Control erhält Accessible Name/Tooltip und einen sichtbaren Fokuszustand.
- Keine Information ausschließlich über Farbe, Hover oder Animation vermitteln.

### 5.5 Zustandsmodell für Controls

Jede wiederverwendbare Komponente definiert: `default`, `hover`, `pressed`, `focused`, `selected/active`, `disabled`, `loading`, `error` und bei Bedarf `unavailable`. QML-Komponenten sollen diese Zustände über Tokens und gemeinsame Basiskomponenten beziehen.

### 5.6 Komponentenbibliothek

Erste gemeinsame Komponenten:
- `Button`, `IconButton`, `Toggle`, `Slider`, `TextField`, `SearchField`
- `Card`, `SectionHeader`, `Divider`, `Badge`, `Tooltip`
- `PopupSurface`, `Popover`, `ModalDialog`, `Toast`
- `StatusIndicator`, `AppIcon`, `WorkspaceIndicator`
- `EmptyState`, `ErrorState`, `LoadingState`
- `SettingsRow`, `SettingsSection`, `DeviceRow`

---

## 6. Informationsarchitektur und Feature-Katalog

### 6.1 Core Desktop

| Funktion | Priorität | Umsetzung |
|---|---|---|
| Taskbar/Dock | P0 | Quickshell/QML, Hyprland-Integration |
| App Launcher | P0 | Desktop Entries, Suche, Favoriten |
| Home/Systemmenü | P0 | Shell-Modul |
| Workspace-Indikatoren | P0 | Hyprland IPC |
| Power Menu | P0 | geprüfte Systemaktionen, Authentifizierung falls nötig |
| OSD für Lautstärke/Medien | P1 | Systemstatus + Tastatur-Shortcuts |
| Window Switcher | P1 | Hyprland-Zustand, Tastaturbedienung |
| Workspace Overview | P2 | Fensterübersicht; Vorschauen optional |
| System Tray | P1/P2 | standardisierte Tray-Integration nur falls nötig |
| Desktop Context Menu | P2 | bewusst begrenzte Aktionen |
| Drag & Drop | P2 | gezielt definierte Ziele, keine pauschale Shell-weite Implementierung |
| Desktop Widgets | P3 | nach stabilem Widget-Modell |

### 6.2 System UI

- **P0:** Taskbar, Launcher, Popup-Grundsystem, Power Menu, Basiseinstellungen, sichtbare Fehlermeldungen.
- **P1:** Notification Center, Lautstärke-/Helligkeits-OSD, Control Center, Window Switcher.
- **P2:** Welcome Screen, globale Suche, Systemstatus-Overlay, Screensaver.
- **Sicherheitskritisch:** Lock Screen und Authentifizierung nicht als einfache QML-Attrappe bauen. Bestehende, geeignete Wayland-/PAM-/systemd-nahe Mechanismen nutzen und deren Kompatibilität mit der Sitzung prüfen.

### 6.3 Personalisierung

- **P0:** Dark/Light Mode, Akzentfarbe, Taskbar-Dichte, sichtbare Statusindikatoren, Animationen an/aus.
- **P1:** Wallpaper Manager, Icon-/Cursor-Themes, Schriftwahl, Display-Anordnung, Transparenz.
- **P2:** Wallpaper-Farbextraktion, zeitabhängige Themes, automatische Rotation, per-Workspace-Wallpaper.
- Änderungen sollen sofort sichtbar werden, ohne die ganze Shell neu zu starten, soweit die betroffene Schnittstelle dies erlaubt.

### 6.4 Produktivitätswerkzeuge

| Werkzeug | Empfehlung |
|---|---|
| Rechner, Timer, Stoppuhr | kleines Shell-Modul oder eigenständige Mini-App |
| Kalender/Uhr/Weltuhr | Shell-Popup, wenn Umfang klein bleibt |
| Wetter | optionales Modul; externe Datenquelle, Datenschutz und Offline-Zustand beachten |
| Notizen/To-do | eigenständige App oder klar abgegrenztes Modul mit persistenter Speicherung |
| Screenshot | bewährtes Wayland-kompatibles Werkzeug integrieren |
| Clipboard Manager | optionales Modul; sensible Inhalte und Ablaufzeiten beachten |
| Dateisuche | bestehende Suchwerkzeuge/Indexdienste verwenden; kein eigener Indexer im MVP |
| Unit Converter/QR/Color Picker/Emoji/Character Map | optionale kleine Tools; nicht in den Core zwingen |

### 6.5 Medien und Kommunikation

- Mediensteuerung über freigegebene MPRIS-Schnittstellen.
- Audio-Device-Switcher und Mikrofonstatus über PipeWire/WirePlumber bzw. geeignete Desktop-Schnittstellen.
- Bluetooth-Manager über BlueZ oder dessen etablierte Schnittstelle.
- WLAN über den gewählten Netzwerkmanager.
- Notification History und Do Not Disturb als UI über einen definierten Notification-Backend-Vertrag.
- Screen-Sharing-Indikator nur auf Basis verlässlicher verfügbarer Statussignale. Bei unvollständiger Erkennung keine falsche Sicherheitsgarantie behaupten.
- Focus Mode soll zunächst Benachrichtigungen und optional bestimmte Ablenkungen bündeln; keine unklare globale „Produktivitätsautomatik“.

### 6.6 Systemverwaltung

- **P1:** Systeminformationen, Shortcut-Übersicht, Startup-Apps, Fehler-/Crash-Hinweise.
- **P2:** Update Center, Speicherübersicht, Prozessübersicht, Tastatur-/Touchpad-Einstellungen, Standardanwendungen.
- Updates sollten zunächst einen sicheren Einstieg in den nativen Paketmanager bieten, mit verständlicher Anzeige und expliziter Bestätigung. Kein selbstgebauter Paketmanager.
- Für privilegierte Aufgaben einen etablierten Authentifizierungsweg verwenden; niemals `sudo`-Befehle aus beliebigen QML-Strings zusammensetzen.

### 6.7 Fensterverwaltung

- P0: Workspace-Wechsel, Fensterfokus, aktives Fenster.
- P1: Window Switcher, einfache Tiling-/Floating-Aktionen, definierte Fensterregeln.
- P2: Snap-Layouts, PiP-Steuerung, per-Workspace-Wallpaper, Vorschauen.
- Snap-Layouts sind eine UI-Abstraktion über Hyprland-Aktionen/Regeln, keine zweite konkurrierende Fensterverwaltung.
- Fenster-Vorschauen benötigen eine gesonderte technische Prüfung, weil Wayland-Capture, Berechtigungen und Ressourcenverbrauch Grenzen setzen.

### 6.8 Sicherheit und Sitzung

- Lock Screen, Login/Authentifizierung, Suspend/Resume, Logout/Restart/Shutdown, Deckelverhalten, Clipboard Privacy und Privacy Indicators.
- Das UI darf nie suggerieren, dass der Bildschirm gesperrt sei, wenn die eigentliche Sitzung nicht sicher gesperrt wurde.
- Kritische Aktionen mit Bestätigung, klarer Beschriftung und nachvollziehbarem Ergebnis.
- Automatische Sperre und Screensaver sind getrennte Konzepte: Screensaver ist kein Ersatz für Sperren.

### 6.9 Erweiterte Funktionen

- P2: Command Palette, globale Shortcuts, Quick Settings Search, erweiterte Workspace-Animationen.
- P3: Gesten, Hot Corners, per-App-Audio, Zeit-Themes, Erweiterungs-Repository.
- Shell Restart/Recovery ab P1 als interne Betriebsfunktion vorsehen, UI für Recovery bei Bedarf später.
- Redundanz vermeiden: Global Search, App Launcher und Command Palette können eine gemeinsame Such-/Command-Engine verwenden, aber unterschiedliche Ansichten bieten.

---

## 7. Widget- und Erweiterungssystem

### 7.1 Widget-Klassen

1. **Taskbar-Widget:** dauerhaft sichtbare kleine Komponente, z. B. Uhr.
2. **Statusindikator:** kompakter Zustand plus Popup, z. B. Audio oder Netzwerk.
3. **Schnellaktions-Widget:** direkte Aktion, z. B. Nicht-stören.
4. **Popup-Widget:** Inhalt nur bei Öffnen sichtbar, z. B. Kalender.
5. **Desktop-Widget:** frei platzierbare Oberfläche, erst nach MVP.
6. **Eigenständiges Shell-Modul:** Launcher, Settings, Control Center, Notification Center; größerer Lebenszyklus als ein einzelnes Widget.

Nicht jedes Widget darf in jeden Slot. Jedes Modul deklariert erlaubte Slot-Typen, Mindestgröße, optionale Größe, Hardware-/Dienstvoraussetzungen und Berechtigungen.

### 7.2 Erste Widget-Priorisierung

**P0 – Kern:**
- Uhr/Datum
- Workspaces
- Netzwerkstatus
- Audio/Mute
- Benachrichtigungen
- Akku nur bei erkannter Batterie
- Home/App-Dock

**P1 – sinnvolle optionale Module:**
- Bluetooth
- Mediensteuerung
- Kalender
- Mikrofonstatus
- Helligkeit
- Nicht-stören
- CPU/RAM als optionales Monitoring

**P2:**
- Wetter, Clipboard, Systemupdates, Schnellaktionen, Weltuhr, Systemmonitor, Desktop-Widgets.

**Nicht standardmäßig aktivieren:** Wetter (externer Dienst), Clipboard-Historie (Privatsphäre), Systemupdates (kann Ablenkung erzeugen), intensive Live-Statistiken.

### 7.3 Modulmanifest

Ein Modul soll statische Metadaten haben, bevor QML geladen wird. Beispielkonzept:

```json
{
  "id": "org.example.widget.audio",
  "name": "Audio",
  "version": "1.0.0",
  "apiVersion": 1,
  "kind": "status-indicator",
  "slots": ["taskbar-right", "control-center"],
  "requires": ["service:pipewire"],
  "optionalRequires": ["service:wireplumber"],
  "settingsSchema": "audio-settings-v1",
  "permissions": ["audio.read", "audio.control"]
}
```

Das ist ein **Vorschlag**, kein bereits existierendes Dateiformat. Das Manifest muss validiert werden; `id`, Versionsschema, erlaubte Slots und Berechtigungen sind verbindlich. Keine beliebigen Shell-Kommandos als Manifest-Option.

### 7.4 Konfiguration und Live-Updates

Zentraler Zustand enthält:
- Aktivierte Modul-IDs
- Reihenfolge je Slot
- Sichtbarkeit und Größe
- Modulspezifische Einstellungen
- API-/Schema-Version
- optional zuletzt bekannten Fehlerstatus

Beim Speichern:
1. Eingaben gegen Schema validieren.
2. temporäre Datei schreiben.
3. Datei atomar ersetzen.
4. betroffene Modelle aktualisieren.
5. bei Laufzeitfehler auf letzten gültigen Zustand zurückfallen und verständliche Meldung zeigen.

Module sollen über einen zentralen Registry-/Model-Layer registriert werden. Nicht jede QML-Komponente liest und schreibt selbständig dieselbe JSON-Datei. Einstellungen werden live übernommen, sofern möglich; sonst wird angezeigt, welche Komponente neu geladen werden muss.

### 7.5 Drei Erweiterungsstufen

**Stufe A – integrierte Widgets (MVP):** QML-Dateien im eigenen Repository, bekannte Schnittstellen, gemeinsam getestet und mit dem Core ausgeliefert.

**Stufe B – lokale Module:** installierbare lokale Module mit Manifest, Versionierung und festgelegten Berechtigungen. Fehlerhafte Module müssen deaktivierbar sein, ohne die ganze Shell zu blockieren.

**Stufe C – Repository (später):** signierte/prüfbare Pakete, Herkunftsinformationen, Kompatibilitätsregeln, Review-/Release-Prozess und klare Deinstallationsregeln.

QML-Module sind nicht automatisch eine Sicherheits-Sandbox. Fremder QML-Code kann in der Regel die Berechtigungsgrenzen eines normalen Prozesses nutzen. Deshalb zunächst keine beliebigen Drittanbieter-Plugins laden. Ein Berechtigungsmanifest ist Dokumentation und Validierung, keine Sandbox. Für nicht vertrauenswürdige Erweiterungen wäre Prozessisolation und ein enges IPC-Protokoll erforderlich.

### 7.6 Fehlerisolierung und Recovery

- Jeder optionale Modulbereich hat einen definierten Fehlerzustand.
- Ein Widget darf den gesamten Shell-Start nicht verhindern.
- Fehlerhafte Module werden beim nächsten Start vorübergehend deaktiviert, sofern ein sicherer Mechanismus dies unterstützt.
- Recovery-Start lädt nur Core-Module und erlaubt Konfiguration zu korrigieren.
- Logs nennen Modul-ID, Version und Fehlerkontext, aber keine Passwörter, Tokens oder sensible Clipboard-Inhalte.

---

## 8. Control Center

Das Control Center ist ein **schnelles Bedienfeld**, keine zweite Settings-App. Es zeigt den aktuellen Zustand und bietet die häufigsten Aktionen; detaillierte Konfiguration führt in die Settings-App.

### 8.1 Struktur

- **General:** Netzwerk, Bluetooth, Audio, Helligkeit, Night Light, Energieprofil, Focus/Do Not Disturb.
- **Network:** aktive Verbindung, WLAN-Schalter, verfügbare Netze, VPNs, Kabelverbindung, Hotspot sofern unterstützt.
- **Audio:** Ausgabegerät, Lautstärke/Mute, Eingabegerät, Mikrofon-Mute, optional App-Lautstärke.
- **Bluetooth:** Schalter, gekoppelte/nahe Geräte, Verbinden/Trennen, Akkustand sofern geliefert.
- **Power:** Akku, Netzbetrieb, Energieprofil, Energiesparmodus.
- **Display (P1/P2):** erkannte Monitore, Helligkeit sofern verfügbar, Night Light, Display-Einstellungen öffnen.
- **Privacy (P2):** Mikrofon-/Kamera-/Screen-Share-Status nur soweit verlässlich verfügbar, Clipboard-Einstellungen.
- **Focus:** Nicht-stören, zeitlich begrenzter Fokus, Benachrichtigungsregeln.

Auf schmalen Bildschirmen Tabs vermeiden, die nicht mehr passen; lieber klare Unterseiten oder ein scrollbares Panel. Hardwareabhängige Abschnitte werden ausgeblendet oder als „nicht verfügbar“ erklärt, nicht mit wirkungslosen Schaltern angezeigt.

### 8.2 Datenquellen, Aktionen und Fehlerzustände

| Bereich | Bevorzugte Quelle / Schnittstelle | Aktion | Fehlerzustand |
|---|---|---|---|
| Workspaces/Fenster | Hyprland IPC | Fokus/Workspace-Aktion | Reconnect, Zustand neu abfragen |
| Netzwerk | NetworkManager D-Bus/API oder gewählter Backend-Adapter | verbinden/trennen/Toggle | Dienst nicht verfügbar, Authentifizierung nötig |
| Audio | PipeWire/WirePlumber bzw. kompatible Audio-Schnittstelle | Gerät, Lautstärke, Mute | kein Gerät, Server nicht erreichbar |
| Bluetooth | BlueZ D-Bus | Toggle, Pairing, Connect | Adapter fehlt, Gerät außer Reichweite |
| Akku | UPower oder verfügbare Kernel-/Systemschnittstelle | Profil/Power-Einstellungen | keine Batterie oder Werte nicht verfügbar |
| Helligkeit | unterstützte Display-/Backlight-Schnittstelle | Helligkeit ändern | Gerät nicht steuerbar |
| Benachrichtigungen | gewählter Notification-Daemon/Protokoll | DND, öffnen/löschen | Backend nicht verfügbar |
| Updates | Paketmanager/Update-Backend | prüfen/öffnen | keine Verbindung, Paketmanager gesperrt |

Die konkreten Backends müssen in Phase 0 an den bestehenden Installationsstand angepasst werden. Nur einen Netzwerkmanager gleichzeitig für dieselben Interfaces verwenden; die UI darf nicht mehrere konkurrierende Backends gleichzeitig konfigurieren.

### 8.3 Bedienregeln

- Schalter zeigt Zustand und Lade-/Anwendungsstatus.
- Nach einem Klick optimistisch nur dann umschalten, wenn ein Fehler sauber zurückgerollt wird; ansonsten bis zur bestätigten Antwort den tatsächlichen Backend-Zustand anzeigen.
- Lange Vorgänge zeigen Fortschritt und Abbruchmöglichkeit, wo sinnvoll.
- Bei fehlender Berechtigung einen klaren Authentifizierungsdialog oder Systemmechanismus aufrufen; keine stille Eskalation.
- Fehler haben „Erneut versuchen“ und bei Bedarf „Einstellungen öffnen“.

---

## 9. Settings-Konzept

### 9.1 Navigation

1. Appearance
2. Taskbar & Dock
3. Widgets & Extensions
4. Desktop & Workspaces
5. Displays
6. Network
7. Bluetooth
8. Audio
9. Power & Battery
10. Notifications & Focus
11. Keyboard & Input
12. Applications
13. Privacy & Security
14. System & Updates
15. About / Diagnostics

Die linke Navigation sollte Suche und klare Kategorien haben. Jede Einstellungsseite nutzt gemeinsame Komponenten und zeigt kurze Beschreibungen. Fortgeschrittene Optionen sind einklappbar.

### 9.2 Control Center versus Settings

**Control Center:** Zustand sehen und häufige Aktion sofort ausführen. Beispiele: WLAN wählen, Lautstärke ändern, Bluetooth-Gerät verbinden, DND aktivieren, Helligkeit ändern.

**Settings:** Profile und Verhalten dauerhaft konfigurieren. Beispiele: gespeicherte Netzwerke verwalten, Audio-Defaults, Display-Anordnung, Benachrichtigungsregeln, Shortcuts, Geräteoptionen, Themes und Widget-Konfiguration.

### 9.3 Persistenz und Migration

- Nutzerkonfiguration in einem eigenen Verzeichnis unter `~/.config/<projekt-id>/`.
- Laufzeitdaten/Cache getrennt unter `~/.cache/<projekt-id>/`.
- Zustands-/Protokolldaten, sofern nötig, unter `~/.local/state/<projekt-id>/`.
- Dateien mit Schema-Version versehen.
- Defaults versioniert im Paket mitliefern, Nutzerwerte separat halten.
- Migrationen sind kleine, testbare Funktionen von Version N nach N+1.
- Ungültige Konfiguration nicht überschreiben: sichern, Defaults laden, Fehler protokollieren und UI zur Wiederherstellung anbieten.
- Reset pro Seite, pro Modul und global anbieten; globale Rücksetzung mit Bestätigung.

### 9.4 Beispiel einer Konfigurationsstruktur

```json
{
  "schemaVersion": 1,
  "appearance": {
    "mode": "dark",
    "accent": "blue",
    "reducedMotion": false,
    "transparency": true
  },
  "taskbar": {
    "density": "comfortable",
    "monitorMode": "all",
    "dockMagnification": false,
    "left": ["home", "app-dock"],
    "center": ["workspaces"],
    "right": ["network", "audio", "notifications", "clock"]
  },
  "widgets": {
    "enabled": ["clock", "workspaces", "network", "audio", "notifications"],
    "order": {
      "taskbar-right": ["network", "audio", "notifications", "clock"]
    }
  }
}
```

Dieses Schema dient als Ausgangspunkt. Tatsächliche Werte sollten nach einer ersten QML-Implementierung und Schema-Validierung festgelegt werden. Modulkonfigurationen sollten nach `moduleId` getrennt bleiben, damit nicht jede Änderung das gesamte globale Schema destabilisiert.

---

## 10. Desktop, Laptop und Hardwareerkennung

### 10.1 Gemeinsame Codebasis

Die Shell darf nicht in „Desktop-Version“ und „Laptop-Version“ aufgespalten werden. Stattdessen stellt ein Hardware-/Capability-Layer verfügbare Fähigkeiten bereit, z. B.:

- `battery.available`
- `brightness.available`
- `bluetooth.available`
- `wifi.available`
- `audio.inputDevices`
- `display.count`
- `powerProfiles.available`
- `touchInput.available`

Diese Capability-Werte sind Laufzeitinformationen, keine dauerhaft in die UI geschriebenen Annahmen. Geräte können entfernt, angeschlossen oder nach Resume neu erkannt werden.

### 10.2 Desktop

- Multi-Monitor-Layout und unterschiedliche Skalierung testen.
- GPU-/CPU-Informationen nur als optionale Diagnose.
- Kein Akku-Bereich ohne Batterie.
- Externe Audio-/Bluetooth-Geräte dynamisch aktualisieren.
- Taskbar-Popups an den jeweiligen Monitor binden.

### 10.3 Laptop

- Akkustand und Netzteilstatus, wenn zuverlässig verfügbar.
- Helligkeit nur bei steuerbarer Hardware.
- Energieprofile nur anbieten, wenn ein passender Dienst verfügbar ist.
- Touchpad, Tastaturbeleuchtung und Deckelverhalten können von Treiber, Firmware und Systemdienst abhängen.
- Resume aus Suspend als zentraler Testfall: Geräteverbindungen und UI-Zustände erneut abfragen.

### 10.4 Docking und hybride Systeme

Monitor-Events, Audio-Device-Wechsel und Netzwerk-/Bluetooth-Änderungen müssen laufend verarbeitet werden. Vermeide einmalige Hardwareerkennung ausschließlich beim Shell-Start. Wenn ein Gerät verschwindet, wird die entsprechende UI-Komponente aktualisiert und zeigt keinen veralteten Zustand.

---

## 11. Technische Zielarchitektur

### 11.1 Schichten

1. **Installations- und Paketierungsschicht:** installiert Core, optionale Pakete und Konfigurationen; keine UI-Logik.
2. **Linux-Systemdienste:** Netzwerk, Audio, Bluetooth, Power, Benachrichtigungen, Authentifizierung.
3. **Hyprland:** Fenster, Workspaces, Fokus, Monitore, Regeln und compositor-spezifische Aktionen.
4. **Backend-Adapter:** kapseln D-Bus, IPC, CLI-Fallbacks und Capability-Erkennung.
5. **Shell-Core:** ConfigStore, ThemeStore, ModuleRegistry, PopupManager, ErrorReporter, HardwareCapabilities.
6. **Designsystem:** Tokens, Basiskomponenten, Zustände und Layoutregeln.
7. **Shell-Module:** Taskbar, Launcher, Control Center, Settings, Notifications, OSD, Power Menu.
8. **Widgets:** kleine Komponenten mit deklarierter Position, Voraussetzungen und Einstellungen.
9. **Optionale Anwendungen/Erweiterungen:** separate Pakete und Prozesse, wenn sie eigenständigen Lebenszyklus benötigen.
10. **Diagnose/Recovery:** Logs, Konfigurationsbackup, Safe Mode und Tests.

### 11.2 Datenfluss

```text
Linux-Dienste / Hyprland IPC
            |
     Backend-Adapter
            |
   zentraler Status / Models
            |
  +---------+-----------+
  |         |           |
Taskbar   Popups      Settings
  |         |           |
  +----- gemeinsame Tokens -----+
            |
       Quickshell / QML
```

UI-Komponenten sollen nicht direkt aus vielen Stellen beliebige CLI-Kommandos starten. Adapter kapseln Kommandozeilen, Fehlercodes, Timeouts und Parsing. Wo eine stabile D-Bus-API vorhanden ist, ist diese einer fragilen Ausgabeformat-Auswertung vorzuziehen.

### 11.3 Hyprland-Integration

- IPC-Verbindung nur im passenden aktiven Hyprland-Kontext aufbauen.
- Event-Socket für Workspace-, Fenster- und Monitoränderungen verwenden.
- Bei Reconnect oder Verlust des Event-Streams vollständigen Snapshot laden.
- Sockets zeitnah schließen; fehlerhafte oder blockierende IPC-Verbindungen dürfen den Compositor nicht festhalten.
- Hyprland-Version und relevante Schnittstellen testen; Konfigurationssyntax kann sich zwischen Versionen ändern.
- Aktionen über einen kleinen, typisierten Adapter ausführen; keine unkontrollierten Eingaben direkt aus Nutzereinstellungen übernehmen.

Aktuelle Referenz: [Hyprland IPC](https://wiki.hypr.land/ipc/) und [Workspace Rules](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/).

### 11.4 Vorgeschlagene Projektstruktur

```text
project/
├── README.md
├── LICENSE
├── install.sh
├── uninstall.sh
├── packages/
│   ├── core.txt
│   ├── network.txt
│   ├── audio.txt
│   ├── bluetooth.txt
│   └── optional-apps.txt
├── config/
│   ├── hypr/
│   └── defaults/
├── shell/
│   ├── Main.qml
│   ├── core/
│   │   ├── ConfigStore.qml
│   │   ├── ThemeStore.qml
│   │   ├── ModuleRegistry.qml
│   │   ├── HardwareCapabilities.qml
│   │   ├── PopupManager.qml
│   │   └── ErrorReporter.qml
│   ├── components/
│   ├── modules/
│   │   ├── taskbar/
│   │   ├── launcher/
│   │   ├── control-center/
│   │   ├── settings/
│   │   ├── notifications/
│   │   └── osd/
│   ├── widgets/
│   └── services/
│       ├── HyprlandAdapter.qml
│       ├── NetworkAdapter.qml
│       ├── AudioAdapter.qml
│       ├── BluetoothAdapter.qml
│       └── PowerAdapter.qml
├── tests/
│   ├── config/
│   ├── adapters/
│   └── smoke/
└── docs/
    ├── architecture.md
    ├── widgets.md
    └── troubleshooting.md
```

Die Struktur ist ein Vorschlag, kein Abbild der vorhandenen Dateien. QML-Objekte/Singletons sollen nur dort eingesetzt werden, wo ihre Lebensdauer und globale Rolle klar sind; keine unüberschaubaren globalen Singletons für jeden Statuswert.

### 11.5 Technische Grenzen und Systemwerkzeuge

| Bereich | Quickshell/QML | Externe Schnittstelle / Dienst |
|---|---|---|
| Taskbar, Launcher, Popups, Settings | direkt | Desktop Entries / Systemzustand |
| Workspaces, Fensterfokus | UI und Darstellung | Hyprland IPC |
| Netzwerk | Anzeige/Bedienoberfläche | NetworkManager oder bewusst gewählter Backend |
| Audio | Slider/Device UI | PipeWire/WirePlumber bzw. kompatible Schnittstelle |
| Bluetooth | Geräte-UI | BlueZ |
| Akku/Energie | Anzeige/Bedienelemente | UPower/Power-Profile/Kernel-Schnittstellen je System |
| Helligkeit | UI | verfügbare Backlight-/Display-Schnittstelle |
| Notifications | Center/History-UI | Notification-Daemon und freigegebene Schnittstelle |
| Authentifizierung | Dialog-UI, falls passend | PAM-/Polkit-/Systemmechanismus |
| Screenshots/Clipboard | UI und Workflow | bewährte Wayland-Werkzeuge und freigegebene Protokolle |
| Updates | Status/Progress UI | pacman/Update-Backend; privilegierte Aktionen geschützt |
| Wetter | Widget-UI | externe API oder optionaler Dienst |

Diese Tabelle ist eine Architekturzuordnung, keine Garantie, dass jedes Backend ohne zusätzliche Abhängigkeiten sofort verfügbar ist.

---

## 12. Installationsskript und Paketstrategie

### 12.1 Installationsskript versus vollständiger OS-Installer

**Shell-Installer (jetzt):** konfiguriert eine bestehende Arch-Installation. Er prüft Voraussetzungen, installiert ausgewählte Pakete, sichert Dateien, richtet die Shell ein und kann Änderungen dokumentieren.

**OS-Installer (später):** würde Partitionierung, Bootloader, Kernel, initramfs, Benutzeranlage, Locale, Netzwerk und weitere Basissystemfragen abdecken. Das ist ein separates Projekt mit wesentlich höherem Risiko und sollte nicht in das bestehende `install.sh` hineingemischt werden.

### 12.2 Installationsprofile

- **Core:** Quickshell, Hyprland-Integration, minimale UI, notwendige Runtime-Abhängigkeiten und eine funktionsfähige Sitzung.
- **Desktop Essentials:** Netzwerk-, Audio-, Benachrichtigungs-, Polkit- und Portal-Komponenten, soweit noch nicht vorhanden.
- **Laptop:** nur zusätzliche Werkzeuge/Dienste für Akku, Helligkeit und Energieprofile, sofern erforderlich.
- **Bluetooth:** BlueZ und passende Bedienintegration.
- **Productivity:** Screenshot, Clipboard, Rechner, Kalender etc.
- **Theming:** optionale Fonts, Cursor-/Icon-Themes, Wallpaper-Tools.
- **Developer:** Diagnosewerkzeuge und Entwicklungsabhängigkeiten, nicht Teil der normalen Installation.

Die konkreten Paketnamen sind anhand des aktuellen Arch-Repository-Standes und der bestehenden Installation zu verifizieren.

### 12.3 Paket-Kategorien

**Core-Kandidat:**
- Quickshell und seine tatsächlich benötigten Runtime-Abhängigkeiten
- Hyprland (falls nicht bereits installiert)
- benötigte Desktop-Portal-/Polkit-/Notification-Komponenten je Zielkonfiguration
- grundlegende Shell-Assets und Default-Konfiguration

**Service-Abhängigkeiten (nur ein passendes Backend wählen):**
- Netzwerk: z. B. NetworkManager oder eine bewusst gepflegte Alternative; nicht mehrere konkurrierende Netzwerkmanager aktivieren.
- Audio: PipeWire plus passender Session-/Policy-Manager, falls noch nicht vorhanden.
- Bluetooth: BlueZ nur bei gewünschter Bluetooth-Unterstützung.
- Akku: Backend nur falls notwendig; vorhandene Kernel-/System-Schnittstellen berücksichtigen.
- Benachrichtigungen: ein klar definiertes Backend.

**Optional:**
- Browser, Dateimanager, Terminal (nur falls Nutzer keine geeigneten Apps hat oder ein Default gewünscht ist)
- Wetter, Clipboard, Screenshot, zusätzliche Produktivitätstools
- zusätzliche Themes, Fonts und Cursorpakete
- Monitoring und Entwicklerwerkzeuge

**Nicht pauschal entfernen:**
- Systembibliotheken, Dienste oder Kommandozeilenwerkzeuge, nur weil eine GUI ersetzt wird.
- Vorhandene Apps nicht ungefragt deinstallieren.
- Pakete, deren Abhängigkeiten unklar sind, erst nach Bestandsaufnahme bewerten.

### 12.4 Anforderungen an `install.sh`

- `set -Eeuo pipefail` oder ein gleichwertig bewusstes Fehlerkonzept; jede Ausnahme dokumentieren.
- Frühe Prüfung auf Arch, benötigte Rechte, Netzwerk, freien Speicher und erwartete Tools.
- `--dry-run`, `--profile`, `--no-optional-apps`, `--backup-dir` und `--help`.
- Paketlisten zentral und nachvollziehbar halten.
- Nur fehlende Pakete installieren; keine ungefragten vollständigen Systemupdates als versteckte Nebenwirkung.
- Vor jeder Konfigurationsänderung Backup anlegen.
- Vorhandene Dateien niemals still überschreiben; Diff/Backup oder explizite Nutzerentscheidung.
- Wiederholte Ausführung soll keinen Schaden anrichten (idempotent).
- Fehler mit konkretem Schritt und Logpfad ausgeben.
- Keine Passwörter/Tokens in Logs.
- Änderungen an Diensten klar anzeigen; Dienste nicht doppelt oder konkurrierend aktivieren.
- Keine `curl | sh`-Installation ohne verifizierte Quelle und Integritätsprüfung.
- Uninstall-Mechanismus entfernt nur nachweislich vom Projekt verwaltete Dateien und ändert keine Nutzerdateien ohne Bestätigung.
- Installation in VM/Testbenutzer testen, nicht zuerst auf dem täglichen Produktivsystem.

### 12.5 Paketierung später

Wenn die Struktur stabil ist, sollte die Shell in Arch-Pakete zerlegt werden: Core, Assets/Themes, optionale Module und eventuell einzelne Integrationen. Paketierung sollte Arch-Packaging-Konventionen und reproduzierbare Build-Praktiken beachten. Referenz: [Arch package guidelines](https://wiki.archlinux.org/title/Arch_package_guidelines).

---

## 13. Sicherheit und Fehlerbehandlung

### 13.1 Vertrauensgrenzen

- QML ist UI-Code, kein Sicherheitsmechanismus.
- Keine beliebigen `sudo`-Befehle aus Settings oder Widget-Manifests ausführen.
- Privilegierte Aktionen an etablierte Systemmechanismen delegieren.
- Konfigurationswerte vor Verwendung validieren und Argumente nicht als Shell-Strings zusammensetzen.
- Erweiterungen aus unbekannter Quelle nicht automatisch ausführen.
- Netzwerk-/Wetter-Widgets müssen klar machen, wenn sie externe Daten senden oder abrufen.

### 13.2 Fehlerklassen

1. **Hardware nicht vorhanden:** Widget ausblenden oder Capability als nicht verfügbar markieren.
2. **Dienst nicht verfügbar:** UI bleibt bedienbar, Fehler mit Retry anzeigen.
3. **Aktion abgelehnt:** Backend-Fehler anzeigen, Zustand aus Quelle der Wahrheit neu lesen.
4. **Ungültige Konfiguration:** Backup und Defaults laden, kein Crash-Loop.
5. **QML-/Modulfehler:** Fehler isolieren, optionales Modul deaktivieren.
6. **Hyprland-Verbindung verloren:** Verbindung wiederherstellen und Snapshot neu laden.
7. **Shell startet nicht:** Recovery-Modus und Anleitung über TTY/Terminal dokumentieren.

### 13.3 Logging und Diagnose

- strukturierte Logs mit Zeit, Modul, Schweregrad und Fehler-ID.
- keine sensiblen Inhalte loggen.
- Debug-Logging gezielt aktivierbar.
- Diagnoseansicht mit Shell-Version, Hyprland-Version, Modulstatus, relevanten Diensten und Konfigurationsvalidierung.
- Export von Diagnoseinformationen nur nach expliziter Zustimmung und mit Möglichkeit, sensible Felder zu entfernen.

### 13.4 Sperrbildschirm und Power-Aktionen

Lock Screen und Authentifizierung sind keine normalen Popup-Features. Für das MVP eine etablierte, zur Wayland-Sitzung passende Lösung integrieren. Vor eigener Implementierung muss geprüft werden, wie der Compositor, PAM, Session-Management und Screen-Capture zusammenspielen. Ein hübscher QML-Bildschirm allein bietet keine sichere Sperre.

---

## 14. Roadmap mit Abhängigkeiten und Abnahmekriterien

Zeitschätzungen hängen von Größe des bestehenden Codes und verfügbarer Entwicklungszeit ab. Die Phasen werden anhand der Ergebnisse abgeschlossen, nicht allein anhand des Kalenders.

### Phase 0 – Bestandsaufnahme

**Ziel:** tatsächlichen Zustand verstehen.

**Aufgaben**
- `install.sh`, Paketlisten, QML-Dateien, Hyprland-Konfiguration und Screenshot inventarisieren.
- alle installierten/aktivierten Dienste und bestehenden Tools erfassen.
- Feature-Matrix: vorhanden, teilweise vorhanden, geplant, nicht vorgesehen.
- Installations- und Deinstallationsrisiken dokumentieren.
- Testhardware und Zielmonitorgrößen festlegen.

**Abhängigkeiten:** keine.  
**Ergebnis:** Ist-Analyse, Abhängigkeitskarte, priorisierte technische Risiken.  
**Abnahme:** jedes bekannte Feature hat einen Status; alle Paketentfernungen sind begründet; keine Implementierung wird ohne Beleg als vorhanden markiert.  
**Risiken:** fehlende Screenshots/Dateien, versteckte Seiteneffekte im Installer.  
**Noch nicht bauen:** Plugin-System, komplette Settings-App, eigener OS-Installer.

### Phase 1 – Fundament

**Ziel:** wartbare Projektstruktur und sichere Konfigurationsbasis.

**Aufgaben**
- Verzeichnisstruktur, Naming, Versionierung und Logging.
- Design-Tokens, ThemeStore, gemeinsame Komponenten.
- ConfigStore mit Schema-Versionierung, Backup und Reset.
- Fehler-/Loading-/Empty-State-Komponenten.
- Capability-Modell und Adapter-Schnittstellen.
- Tests für Config-Validierung und Migration.

**Abhängigkeiten:** Phase 0.  
**Ergebnis:** Shell startet stabil mit Theme und validierter Konfiguration.  
**Abnahme:** ungültige Konfiguration führt nicht zum Crash-Loop; Theme-Wechsel wirkt zentral; Defaults sind wiederherstellbar.  
**Risiken:** zu frühe Abstraktion, übermäßige Singletons.  
**Noch nicht bauen:** Drittanbieter-Plugins, dynamische Wallpaper-Farbengine.

### Phase 2 – Core Shell

**Ziel:** täglich nutzbare Kernoberfläche.

**Aufgaben**
- Taskbar-Grundlayout mit drei Zonen.
- App-Dock und Desktop-Entry-Erkennung.
- Hyprland-Adapter mit Snapshot + Event-Reconnect.
- Workspace-Anzeige und Wechsel.
- Home Menu, Popup-Grundsystem, Power Menu.
- grundlegende Tastaturbedienung und Monitorzuordnung.

**Abhängigkeiten:** Phase 1.  
**Ergebnis:** Shell kann Apps starten/fokussieren, Workspaces anzeigen und Menüs öffnen.  
**Abnahme:** Shell-Neustart, Hyprland-Reconnect, mehrere Workspaces und zwei Monitore getestet; keine blockierenden IPC-Verbindungen.  
**Risiken:** Änderungen an Hyprland-Schnittstellen, fehlerhafte Zustandsannahmen.  
**Noch nicht bauen:** Live-Fenstervorschauen, Magnification, komplexe Gesten.

### Phase 3 – Settings und Widgets

**Ziel:** Kernoberfläche konfigurierbar machen.

**Aufgaben**
- Settings-Navigation.
- Widget-Katalog und Registry.
- Aktivieren, deaktivieren, sortieren, konfigurieren.
- persistente Konfiguration und Live-Updates.
- Hardwareabhängige Widgets.
- Fehlerzustand und Reset je Widget.

**Abhängigkeiten:** Phase 1 und 2.  
**Ergebnis:** Nutzer kann die Taskbar ohne manuelle QML-Änderung anpassen.  
**Abnahme:** Reihenfolge bleibt nach Neustart erhalten; deaktiviertes Widget wird nicht geladen; ungültige Widget-Konfiguration wird abgefangen.  
**Risiken:** Modulzustand und globale Konfiguration geraten auseinander.  
**Noch nicht bauen:** öffentliches Plugin-Repository, freie QML-Installation aus dem Netz.

### Phase 4 – Systemintegration

**Ziel:** wichtige Systemfunktionen zuverlässig bedienen.

**Aufgaben**
- Netzwerk-/Audio-/Bluetooth-Adapter.
- Notification Center und DND.
- Helligkeit und Energieverwaltung, wenn verfügbar.
- Status-OSD.
- Lock Screen-/Authentifizierungsintegration mit etablierter Lösung.
- Hardwarewechsel und Resume testen.

**Abhängigkeiten:** Phase 1–3.  
**Ergebnis:** Control Center bietet zuverlässige Schnellaktionen.  
**Abnahme:** fehlende Geräte/Dienste werden korrekt behandelt; Aktionen zeigen bestätigten Zustand; keine konkurrierenden Netzwerkdienste.  
**Risiken:** unterschiedliche Backend-Konfigurationen und Hardwaretreiber.  
**Noch nicht bauen:** eigene Netzwerk- oder Audio-Daemons.

### Phase 5 – Produktivität

**Ziel:** ausgewählte Zusatzwerkzeuge integrieren.

**Aufgaben**
- Rechner, Kalender/Uhr, Screenshot und Clipboard nach Nutzen auswählen.
- Command Palette/Suche als gemeinsame Engine planen.
- Notizen und To-do als getrennte Module, falls Datenmodell umfangreicher wird.
- Datenschutz- und Offline-Verhalten definieren.

**Abhängigkeiten:** stabile Module und Settings.  
**Ergebnis:** kleine, gut integrierte Werkzeuge ohne Core-Aufblähung.  
**Abnahme:** Werkzeuge können einzeln deaktiviert werden; Shell bleibt bei Toolfehlern stabil.  
**Risiken:** Scope Creep, doppelte Apps.  
**Noch nicht bauen:** eigene Volltextsuche über das gesamte Dateisystem, Cloud-Sync.

### Phase 6 – Personalisierung

**Ziel:** visuelle Identität ausbauen.

**Aufgaben**
- Light/Dark Mode, Akzentfarbe, Kontrasttests.
- Wallpaper Manager und optional dynamische Farbpalette.
- kompakte/erweiterte Taskbar.
- Animationseinstellungen, Reduced Motion.
- Icon-/Cursor-/Font-Integration.

**Abhängigkeiten:** stabile Tokens und Settings.  
**Ergebnis:** ein konsistentes, anpassbares Designsystem.  
**Abnahme:** Theme-Wechsel ist zentral und ohne Neustart möglich, soweit technisch unterstützt; Kontrast und Fokuszustände bleiben sichtbar.  
**Risiken:** zu viele Theme-Optionen, Lesbarkeit durch dynamische Farben.  
**Noch nicht bauen:** umfangreicher Theme-Marktplatz.

### Phase 7 – Optionale Erweiterungen

**Ziel:** kontrollierte lokale Erweiterbarkeit.

**Aufgaben**
- Manifestformat, API-Version und Berechtigungsdeklaration.
- lokale Installation/Deinstallation.
- Versions- und Abhängigkeitsprüfung.
- Fehlerisolation und Safe Mode.
- später Paket-/Repository-Konzept samt Herkunft und Signaturprüfung.

**Abhängigkeiten:** Phase 3 und stabile API.  
**Ergebnis:** lokale Module können kontrolliert verwaltet werden.  
**Abnahme:** inkompatibles Modul wird nicht aktiviert; fehlerhaftes Modul lässt Core weiterlaufen; Deinstallation entfernt nur verwaltete Dateien.  
**Risiken:** QML ist keine Sandbox, Plugin-API driftet.  
**Noch nicht bauen:** automatische Ausführung beliebiger Remote-Plugins.

### Phase 8 – Stabilisierung und Release

**Ziel:** reproduzierbare Installation und zuverlässiger Alltag.

**Aufgaben**
- Installations-/Upgrade-/Rollback-Tests.
- Multi-Monitor, Laptop, Suspend/Resume, fehlende Dienste, kaputte Konfiguration.
- Performance-/Speicherprüfung.
- Dokumentation, bekannte Einschränkungen und Recovery.
- Versionierung und Release-Checkliste.
- Paketierung erwägen.

**Abhängigkeiten:** Kernphasen abgeschlossen.  
**Ergebnis:** versionierter Release-Kandidat.  
**Abnahme:** Neuinstallation und wiederholte Installation erfolgreich; Upgrade erhält Konfiguration; Rollback/Recovery dokumentiert; keine P0-Fehler offen.  
**Risiken:** große Hardwarematrix und Rolling-Release-Änderungen.  
**Noch nicht bauen:** vollständige eigene Distribution, bevor Shell-Release stabil ist.

---

## 15. MVP: Was zuerst wirklich fertig werden sollte

### MVP-1: Benutzbare Shell

- [ ] Quickshell startet zuverlässig in der bestehenden Hyprland-Sitzung.
- [ ] Taskbar mit Home, App-Dock, Workspaces, Statusbereich, Uhr und Benachrichtigungszugang.
- [ ] Launcher kann installierte Apps aus Desktop Entries finden und starten.
- [ ] Workspaces werden korrekt angezeigt und gewechselt.
- [ ] Popup-Grundsystem und Power Menu.
- [ ] zentrale Tokens, Dark Mode und klare Fokus-/Fehlerzustände.
- [ ] Konfiguration validiert, gesichert und zurücksetzbar.
- [ ] Installationsskript ist idempotent und überschreibt keine Nutzerdateien still.

### MVP-2: Konfigurierbarkeit

- [ ] Settings-Grundgerüst.
- [ ] Statusindikatoren ein-/ausblenden und sortieren.
- [ ] Widget-Katalog mit Aktivieren/Deaktivieren.
- [ ] Live-Updates oder klar gekennzeichneter Reload-Bedarf.
- [ ] Hardwareabhängige Widgets werden korrekt ein-/ausgeblendet.

### MVP-3: Alltagstaugliche Integration

- [ ] Netzwerk- und Audiozustand.
- [ ] Bluetooth optional.
- [ ] Benachrichtigungen und DND.
- [ ] OSD für Lautstärke und gegebenenfalls Helligkeit.
- [ ] etablierte Lock-Screen-/Authentifizierungsintegration.
- [ ] Tests für Multi-Monitor, Reconnect, Suspend/Resume und fehlende Dienste.

**Release-Kriterium:** Ein Benutzer kann das System installieren, sich anmelden, Apps starten, Workspaces wechseln, Audio/Netzwerk bedienen, Einstellungen ändern und sich sicher abmelden/sperren, ohne QML-Dateien manuell bearbeiten zu müssen.

---

## 16. Teststrategie und Qualitätskriterien

### Funktionstests
- ConfigStore: ungültige JSON-Datei, fehlende Werte, unbekannte Schlüssel, Migration.
- ModuleRegistry: unbekannte ID, fehlende Voraussetzung, doppelte ID, ungültiger Slot.
- Hyprland-Adapter: Eventverlust, Reconnect, leerer Zustand, Monitor hinzugefügt/entfernt.
- Settings: Speichern, Reset, Live-Update, Fehler bei Backend-Aktion.
- Installer: erste Ausführung, zweite Ausführung, Abbruch, Dry Run, vorhandene Datei.

### Manuelle Szenarien
- Laptop mit Akku, Laptop am Netzteil, Desktop ohne Batterie.
- Ein Monitor, zwei Monitore mit unterschiedlicher Skalierung.
- Netzwerkdienst gestoppt; Bluetooth-Hardware fehlt; kein Audio-Ausgabegerät.
- Quickshell-Neustart während laufender Apps.
- Suspend/Resume und Docking.
- Tastaturbedienung, reduzierte Animationen, hoher Kontrast.
- Anwendung mit sehr langem Titel, viele laufende Apps, viele Workspaces.

### Qualitätsziele als Startwerte
- Taskbar reagiert bei normalem Zustand ohne spürbare Verzögerung.
- Statusanzeigen hängen nicht dauerhaft an synchronen, blockierenden Prozessen.
- Optionales Widget kann ausfallen, ohne die ganze Shell zu beenden.
- Jede wichtige Aktion ist per Tastatur erreichbar.
- keine ungeklärten kritischen Fehler beim Release.
- Performance-Messungen auf Referenzhardware statt ungeprüfter Behauptungen über RAM-/CPU-Verbrauch.

---

## 17. Offene technische Entscheidungen

Vor Implementierung verbindlich klären:

1. **Projektname und Reverse-DNS-ID:** bestimmt Konfigurationspfade, Paketnamen und Modul-IDs.
2. **Quickshell-Version und Laufzeitumgebung:** API-Verfügbarkeit anhand der tatsächlich eingesetzten Version prüfen.
3. **Hyprland-Version und Konfigurationsformat:** die aktuelle Dokumentation kann sich ändern; IPC und Konfigurationssyntax an der Zielversion testen.
4. **Netzwerk-Backend:** NetworkManager oder eine bestehende Alternative; genau ein zuständiges Backend pro Interface.
5. **Audio-Backend:** PipeWire/WirePlumber bzw. bereits installierte Lösung.
6. **Benachrichtigungsdienst:** vorhandenen Daemon verwenden oder bewusst festlegen.
7. **Polkit-/Authentifizierungsintegration:** festlegen, welche Systemkomponenten für privilegierte Aktionen und Sperren zuständig sind.
8. **Taskbar-Modus:** permanent sichtbar oder Auto-Hide als Standard; Verhalten bei Vollbild.
9. **Multi-Monitor-Modell:** pro Monitor lokale Workspaces oder zentraler Zustand mit klaren Regeln.
10. **Erweiterungsmodell:** integrierte Module zuerst; Entscheidung zu Drittanbieter-Code erst nach Sicherheitsprüfung.
11. **Paketierung:** Skript für bestehende Systeme zuerst; Arch-Pakete/Repository erst nach Stabilisierung.
12. **Supportumfang:** nur Hyprland oder später weitere Compositoren? Für MVP nur Hyprland sauber unterstützen.

---

## 18. Hauptrisiken und Gegenmaßnahmen

| Risiko | Gegenmaßnahme |
|---|---|
| Zu großer Funktionsumfang | MVP-Kriterien und P0/P1/P2/P3 strikt einhalten |
| UI übernimmt zu viel Systemlogik | Adapter und vorhandene Dienste nutzen |
| QML-Modulfehler stürzt gesamte Shell ab | optionale Module isolieren, Recovery-Modus |
| Updates brechen Integrationen | Versionschecks, Adaptertests, Release-Smoke-Tests |
| Installationsskript zerstört vorhandene Konfiguration | Backup, Diff, Dry Run, keine stillen Überschreibungen |
| Neomorphism verschlechtert Kontrast | semantische Tokens, Fokus-/Kontrasttests, Reduced Effects |
| Hardware wird nur beim Start erkannt | dynamische Events und erneute Abfrage nach Reconnect/Resume |
| Unsichere Drittanbieter-Plugins | kein Remote-QML im MVP, spätere Prozessisolation erwägen |
| Eigenes Lock Screen ist nicht sicher | etablierte Authentifizierungs-/Lock-Lösung integrieren |
| Doppelte Netzwerk-/Audio-Dienste | Backend-Inventar und genau eine zuständige Lösung |

---

## 19. Nächste konkrete Schritte

1. `install.sh`, Hyprland-Konfiguration, QML-Dateien und den Taskbar-Screenshot in die Bestandsaufnahme aufnehmen.
2. Aktuelle Paketliste und aktivierte Dienste erfassen.
3. Ist/Soll-Matrix erstellen: **vorhanden**, **teilweise vorhanden**, **geplant**, **optional**, **nicht vorgesehen**.
4. Ein kleines technisches Spike-Projekt umsetzen: Quickshell-Start, Taskbar-Fenster, Hyprland-Workspace-Events, Konfigurationsdatei und Theme-Tokens.
5. Erst nach erfolgreichem Spike die übrigen Adapter und Widgets aufbauen.

### Quellen zur technischen Verifikation

- [Hyprland IPC](https://wiki.hypr.land/ipc/) – Steuer- und Event-Sockets, Live-Ereignisse und Reconnect-Verhalten.
- [Hyprland Workspace Rules](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) – Workspace-Konfiguration; Syntax an die installierte Hyprland-Version anpassen.
- [Arch Linux Package Guidelines](https://wiki.archlinux.org/title/Arch_package_guidelines) – spätere Paketierung und Verzeichnis-/Paketkonventionen.
- [ArchWiki: NetworkManager](https://wiki.archlinux.org/title/NetworkManager) – Netzwerkdienst und Integrationshinweise.
- [ArchWiki: PipeWire](https://wiki.archlinux.org/title/PipeWire) – Audio-Stack und User-Services.

Die genannten Quellen belegen konkrete Integrationsansätze, ersetzen aber nicht die Prüfung der installierten Versionen. Vor allem Quickshell-APIs, Hyprland-Konfigurationssyntax und optionale Dienstschnittstellen sollten gegen die tatsächlich verwendeten Versionen getestet werden.

---

## Schlussentscheidung

Baue zuerst **eine ausgezeichnete, robuste Shell**, nicht gleich ein vollständiges Betriebssystem. Der erste Release muss mit Taskbar, Launcher, Workspaces, Popup-Grundsystem, Settings-Basis und verlässlicher Installation überzeugen. Danach folgen Systemintegration und ein kontrolliertes Widget-System. Ein eigener OS-Installer, ein öffentliches Erweiterungs-Repository und aufwendige Fenster-Vorschauen sind erst sinnvoll, wenn Kernarchitektur, Konfiguration und Recovery stabil sind.
