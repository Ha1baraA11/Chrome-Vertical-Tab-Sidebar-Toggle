<p align="center">
  <img src="assets/logo.png" alt="Chrome-Vertical-Tab-Sidebar-Toggle Logo" width="200">
</p>

<h1 align="center">Chrome-Vertical-Tab-Sidebar-Toggle</h1>

<p align="center">
  <strong>Ein Hammerspoon-Skript, das Chromes native vertikale Tab-Seitenleiste über die macOS Accessibility API umschaltet</strong><br>
  Tastenkürzel, Mausrand-Trigger, oder beides — Sie haben die Wahl.
</p>

<p align="center">
  <a href="README.md">English</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.zh-TW.md">繁體中文</a> · <a href="README_ja.md">日本語</a> · <a href="README_ko.md">한국어</a> · <a href="README_es.md">Español</a> · <a href="README_pt-BR.md">Português</a> · <a href="README_ru.md">Русский</a> · <a href="README_fr.md">Français</a>
</p>

---

## Was es macht

Chrome hat eine integrierte vertikale Tab-Seitenleiste, aber kein Tastenkürzel zum Umschalten. Dieses Skript löst das mit zwei Versionen：

- **`init.lua`** — unterstützt drei auswählbare Schemata (Tastatur / Mausrand / beides)
- **`init-keyboard-only.lua`** — nur Tastenkürzel, keine Mauserkennung

Es funktioniert, indem es Chromes Accessibility-Baum (`AXUIElement`) durchsucht, um die Schaltfläche "Expand Tabs" / "Collapse Tabs" zu finden und sie per `AXPress` zu drücken. Gleicher Ansatz wie [ChromeSidebarToggleRaycast](https://github.com/RotulPlastik/ChromeSidebarToggleRaycast).

## Demo

https://github.com/user-attachments/assets/bcf2a76a-8028-4b63-bc8a-f0b9e1178a25

## Anforderungen

- macOS 13+
- [Hammerspoon](https://www.hammerspoon.org)
- Google Chrome mit aktivierter vertikaler Tab-Seitenleiste
- Hammerspoon hat Berechtigung für Bedienungshilfen erhalten

## Vertikale Tab-Seitenleiste in Chrome aktivieren

Die vertikale Tab-Seitenleiste ist standardmäßig deaktiviert. Um sie zu aktivieren：

1. Geben Sie `chrome://flags/#vertical-tabs` in die Adressleiste ein
2. Ändern Sie **Vertical tabs** auf **Enabled**
3. Klicken Sie auf **Relaunch**, um Chrome neu zu starten
4. Nach dem Neustart klicken Sie mit der rechten Maustaste auf einen leeren Bereich der Tableiste, um die Option zu sehen

## Installation

1. Hammerspoon installieren：

   ```bash
   brew install --cask hammerspoon
   ```

2. Version wählen und in die Hammerspoon-Konfiguration kopieren：

   **Schema-Version**（drei Modi, Standard）：
   ```bash
   cp init.lua ~/.hammerspoon/init.lua
   ```

   **Nur-Tastatur-Version**：
   ```bash
   cp init-keyboard-only.lua ~/.hammerspoon/init.lua
   ```

   Falls bereits eine `~/.hammerspoon/init.lua` existiert, fügen Sie den Inhalt am Ende hinzu.

3. Berechtigung für Bedienungshilfen erteilen：
   - Systemeinstellungen → Datenschutz & Sicherheit → Bedienungshilfen
   - Hammerspoon hinzufügen und aktivieren

4. Hammerspoon-Konfiguration neu laden（Klicken Sie auf das Menüleisten-Symbol → Konfiguration neu laden）

5. （Optional）Hammerspoon zu den Login-Objekten hinzufügen, damit es automatisch startet：
   - Systemeinstellungen → Allgemein → Login-Objekte
   - Hammerspoon hinzufügen

## Schemata（`init.lua`）

Bearbeiten Sie die Variable `SCHEME` am Anfang von `init.lua`, um einen Modus zu wählen：

| Schema | Wert | Auslöser |
|--------|------|----------|
| Nur Tastatur | `1` | `Cmd+S` schaltet die Seitenleiste um |
| Nur Mausrand | `2` | Über den linken Rand schweben zum Erweitern, über 380px hinaus bewegen zum Reduzieren |
| Tastatur + Maus | `3` | Beide Auslöser aktiv（Standard） |

```lua
local SCHEME = 3  -- 1 = Tastatur, 2 = Mausrand, 3 = Beides
```

Wenn Chrome nicht die Vordergrund-App ist, werden alle Auslöser automatisch deaktiviert.

## Auslöser

| Auslöser | Aktion | Schema |
|----------|--------|--------|
| `Cmd+S` | Seitenleiste umschalten | 1 & 3 |
| Maus am linken Rand (0-2px) für 0.15s | Seitenleiste erweitern | 2 & 3 |
| Maus bewegt sich über 380px vom linken Rand | Seitenleiste reduzieren | 2 & 3 |

## Debug

| Tastenkürzel | Aktion |
|--------------|--------|
| `Cmd+Alt+D` | Service-Status anzeigen |
| `Cmd+Alt+B` | Alle Chrome-AX-Schaltflächen in die Konsole ausgeben |
| `Cmd+Alt+R` | Alle Services erzwungen neu starten |

## Konfiguration

### Schema-Selektor（`init.lua`）

```lua
local SCHEME = 3  -- 1 = Tastatur, 2 = Mausrand, 3 = Beides
```

### Mausrand-Schwellenwerte（`init.lua`, Schemata 2 & 3）

```lua
local EDGE_THRESHOLD    = 2       -- Pixel vom linken Rand zum Auslösen
local EXIT_THRESHOLD    = 380     -- Pixel vom linken Rand zum Reduzieren
local WAIT_TIME         = 0.15    -- Sekunden Wartezeit vor dem Auslösen
local MOUSE_POLL_INTERVAL = 0.05  -- Sekunden zwischen Mauspositionsprüfungen
```

### Beide Versionen

```lua
local DEBUG = true  -- Debug-Meldungen in die Konsole ausgeben
```

## Tastenkürzel anpassen

Verfügbar in `init.lua` und `init-keyboard-only.lua`. Das Standard-Tastenkürzel ist `Cmd+S`, das Chromes natives Tastenkürzel zum „Seite speichern" überschreibt. Um es zu ändern, bearbeiten Sie die Tastenprüfung in der Funktion `createKeyTap`：

```lua
-- Cmd+S -> toggle sidebar
if flags.cmd and not flags.ctrl and not flags.alt and not flags.shift
    and keyCode == keycodes.map["s"] then
```

### Modifikatortasten

Ändern Sie die `flags.*`-Bedingungen, um Ihre gewünschte Modifikatorkombination festzulegen：

| Modifikator | Flag | Beispiel |
|-------------|------|----------|
| Cmd | `flags.cmd` | `flags.cmd and not flags.ctrl` |
| Ctrl | `flags.ctrl` | `flags.ctrl and not flags.cmd` |
| Alt/Option | `flags.alt` | `flags.alt` |
| Shift | `flags.shift` | `flags.shift` |

Setzen Sie das Flag auf `true`, um es zu erfordern, `not flags.xxx`, um es auszuschließen.

### Tastencode

Ändern Sie `keycodes.map["s"]` in einen beliebigen Tastennamen. Häufige Beispiele：

```lua
keycodes.map["s"]       -- S
keycodes.map["b"]       -- B
keycodes.map["/"]       -- /
keycodes.map["return"]  -- Return/Enter
keycodes.map["space"]   -- Leertaste
keycodes.map["f1"]      -- F1
```

Vollständige Tastennamenliste：Führen Sie `hs.keycodes.map` in der Hammerspoon-Konsole aus.

### Beispiele

**`Ctrl+Shift+B`**：
```lua
if flags.ctrl and not flags.cmd and flags.shift and not flags.alt
    and keyCode == keycodes.map["b"] then
```

**`Cmd+Alt+/`**：
```lua
if flags.cmd and not flags.ctrl and flags.alt and not flags.shift
    and keyCode == keycodes.map["/"] then
```

**`Cmd+Shift+Return`**：
```lua
if flags.cmd and not flags.ctrl and not flags.alt and flags.shift
    and keyCode == keycodes.map["return"] then
```

Nach dem Bearbeiten laden Sie die Hammerspoon-Konfiguration neu, um die Änderungen anzuwenden.

## So funktioniert es

1. Ein `eventtap` fängt `Cmd+S` ab, wenn Chrome im Vordergrund ist（Schemata 1 & 3）
2. Ein Mauspositions-Poller (50Hz) erkennt das Schweben am linken Rand und das Verlassen（Schemata 2 & 3）
3. Beide Auslöser rufen `toggleSidebar()` auf, das：
   - Das AX-Wurzelelement von Chrome über `hs.axuielement.applicationElement()` erhält
   - In den Fenstern nach einer Schaltfläche mit `AXDescription` sucht, die zu "Expand Tabs" oder "Collapse Tabs" passt
   - `performAction("AXPress")` auf der gefundenen Schaltfläche aufruft
4. Ein Watchdog erkennt, wenn der Mauspoller abstürzt, und startet ihn automatisch neu（Schemata 2 & 3）
5. Schonfristen verhindern Fehlauslöser beim App-Wechsel

## Dateien

| Datei | Beschreibung |
|-------|--------------|
| `init.lua` | Version mit 3 Schemata（Tastatur / Maus / beides） |
| `init-keyboard-only.lua` | Nur-Tastatur-Version, keine Mauserkennung |

## Danksagung

- Originalkonzept：[ChromeSidebarToggleRaycast](https://github.com/RotulPlastik/ChromeSidebarToggleRaycast) by RotulPlastik
- Für Hammerspoon adaptiert mit Mausrand-Trigger-Unterstützung

## Lizenz

MIT
