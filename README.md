# ChromeVerticalTabSidebarToggle

[English](README.md) | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md)

A [Hammerspoon](https://www.hammerspoon.org) script that toggles Chrome's native vertical tab sidebar using the macOS Accessibility API.

## What it does

Chrome has a built-in vertical tab sidebar, but no keyboard shortcut to toggle it. This script solves that with two versions:

- **`init.lua`** — supports three selectable schemes (keyboard / mouse edge / both)
- **`init-keyboard-only.lua`** — keyboard shortcut only, no mouse detection

It works by traversing Chrome's Accessibility tree (`AXUIElement`) to find the "Expand Tabs" / "Collapse Tabs" button and pressing it via `AXPress`. Same approach as [ChromeSidebarToggleRaycast](https://github.com/RotulPlastik/ChromeSidebarToggleRaycast).

## Requirements

- macOS 13+
- [Hammerspoon](https://www.hammerspoon.org)
- Google Chrome with vertical tab sidebar enabled
- Accessibility permission granted to Hammerspoon

## Installation

1. Install Hammerspoon:

   ```bash
   brew install --cask hammerspoon
   ```

2. Choose a version and copy to your Hammerspoon config:

   **Scheme version** (three modes, default):
   ```bash
   cp init.lua ~/.hammerspoon/init.lua
   ```

   **Keyboard-only version**:
   ```bash
   cp init-keyboard-only.lua ~/.hammerspoon/init.lua
   ```

   If you already have a `~/.hammerspoon/init.lua`, append the contents instead.

3. Grant Accessibility permission:
   - System Settings → Privacy & Security → Accessibility
   - Add and enable Hammerspoon

4. Reload Hammerspoon config (click menu bar icon → Reload Config)

## Schemes (`init.lua`)

Edit the `SCHEME` variable at the top of `init.lua` to choose a mode:

| Scheme | Value | Triggers |
|--------|-------|----------|
| Keyboard only | `1` | `Cmd+S` toggles sidebar |
| Mouse edge only | `2` | Hover left edge to expand, move beyond 380px to collapse |
| Keyboard + Mouse | `3` | Both triggers active (default) |

```lua
local SCHEME = 3  -- 1 = Keyboard, 2 = Mouse edge, 3 = Both
```

All triggers are automatically disabled when Chrome is not the frontmost app.

## Triggers

| Trigger | Action | Scheme |
|---------|--------|--------|
| `Cmd+S` | Toggle sidebar | 1 & 3 |
| Mouse hover at left edge (0-2px) for 0.15s | Expand sidebar | 2 & 3 |
| Mouse moves beyond 380px from left edge | Collapse sidebar | 2 & 3 |

## Debug

| Shortcut | Action |
|----------|--------|
| `Cmd+Alt+D` | Show service status |
| `Cmd+Alt+B` | Dump all Chrome AX buttons to Console |
| `Cmd+Alt+R` | Force restart all services |

## Configuration

### Scheme selector (`init.lua`)

```lua
local SCHEME = 3  -- 1 = Keyboard, 2 = Mouse edge, 3 = Both
```

### Mouse edge thresholds (`init.lua`, schemes 2 & 3)

```lua
local EDGE_THRESHOLD    = 2       -- px from left edge to trigger hover
local EXIT_THRESHOLD    = 380     -- px from left edge to trigger collapse
local WAIT_TIME         = 0.15    -- seconds to hover before triggering
local MOUSE_POLL_INTERVAL = 0.05  -- seconds between mouse position checks
```

### Both versions

```lua
local DEBUG = true  -- print debug messages to Console
```

## Customizing the keyboard shortcut

Available in both `init.lua` and `init-keyboard-only.lua`. The default shortcut is `Cmd+S`. To change it, edit the key check in the `createKeyTap` function:

```lua
-- Cmd+S -> toggle sidebar
if flags.cmd and not flags.ctrl and not flags.alt and not flags.shift
    and keyCode == keycodes.map["s"] then
```

### Modifier keys

Change the `flags.*` conditions to set your desired modifier combination:

| Modifier | Flag | Example |
|----------|------|---------|
| Cmd | `flags.cmd` | `flags.cmd and not flags.ctrl` |
| Ctrl | `flags.ctrl` | `flags.ctrl and not flags.cmd` |
| Alt/Option | `flags.alt` | `flags.alt` |
| Shift | `flags.shift` | `flags.shift` |

Set the flag to `true` to require it, `not flags.xxx` to exclude it.

### Key code

Change `keycodes.map["s"]` to any key name. Common examples:

```lua
keycodes.map["s"]       -- S
keycodes.map["b"]       -- B
keycodes.map["/"]       -- /
keycodes.map["return"]  -- Return/Enter
keycodes.map["space"]   -- Space
keycodes.map["f1"]      -- F1
```

Full key name list: run `hs.keycodes.map` in Hammerspoon Console.

### Examples

**`Ctrl+Shift+B`**:
```lua
if flags.ctrl and not flags.cmd and flags.shift and not flags.alt
    and keyCode == keycodes.map["b"] then
```

**`Cmd+Alt+/`**:
```lua
if flags.cmd and not flags.ctrl and flags.alt and not flags.shift
    and keyCode == keycodes.map["/"] then
```

**`Cmd+Shift+Return`**:
```lua
if flags.cmd and not flags.ctrl and not flags.alt and flags.shift
    and keyCode == keycodes.map["return"] then
```

After editing, reload Hammerspoon config to apply.

## How it works

1. An `eventtap` intercepts `Cmd+S` when Chrome is frontmost (schemes 1 & 3)
2. A mouse position poller (50Hz) detects left-edge hover and exit (schemes 2 & 3)
3. Both triggers call `toggleSidebar()` which:
   - Gets Chrome's `AXUIElement` root via `hs.axuielement.applicationElement()`
   - Searches windows for a button with `AXDescription` matching "Expand Tabs" or "Collapse Tabs"
   - Calls `performAction("AXPress")` on the found button
4. A watchdog detects if the mouse poller dies and auto-restarts (schemes 2 & 3)
5. Grace periods prevent false triggers during app switching

## Files

| File | Description |
|------|-------------|
| `init.lua` | Three-scheme version (keyboard / mouse / both) |
| `init-keyboard-only.lua` | Keyboard-only version, no mouse detection |

## Credits

- Original concept: [ChromeSidebarToggleRaycast](https://github.com/RotulPlastik/ChromeSidebarToggleRaycast) by RotulPlastik
- Adapted for Hammerspoon with mouse-edge trigger support

## License

MIT
