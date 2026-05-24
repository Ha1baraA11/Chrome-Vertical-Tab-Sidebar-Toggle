<p align="center">
  <img src="assets/logo.png" alt="Chrome-Vertical-Tab-Sidebar-Toggle Logo" width="200">
</p>

<h1 align="center">Chrome-Vertical-Tab-Sidebar-Toggle</h1>

<p align="center">
  <strong>Un script de Hammerspoon que alterna la barra lateral de pestañas verticales nativa de Chrome mediante la API de Accesibilidad de macOS</strong><br>
  Atajo de teclado, activación por borde de la pantalla, o ambos — tú decides.
</p>

<p align="center">
  <a href="README.md">English</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.zh-TW.md">繁體中文</a> · <a href="README_ja.md">日本語</a> · <a href="README_ko.md">한국어</a> · <a href="README_pt-BR.md">Português</a> · <a href="README_ru.md">Русский</a> · <a href="README_fr.md">Français</a> · <a href="README_de.md">Deutsch</a>
</p>

---

## Características

Chrome tiene una barra lateral de pestañas verticales integrada, pero no hay atajo de teclado para alternarla. Este script lo soluciona con dos versiones:

- **`init.lua`** — soporta tres esquemas seleccionables (teclado / borde de la pantalla / ambos)
- **`init-keyboard-only.lua`** — solo atajo de teclado, sin detección de ratón

Funciona recorriendo el árbol de accesibilidad de Chrome (`AXUIElement`) para encontrar el botón "Expand Tabs" / "Collapse Tabs" y presionarlo mediante `AXPress`. Mismo enfoque que [ChromeSidebarToggleRaycast](https://github.com/RotulPlastik/ChromeSidebarToggleRaycast).

## Demo

https://github.com/user-attachments/assets/bcf2a76a-8028-4b63-bc8a-f0b9e1178a25

## Requisitos

- macOS 13+
- [Hammerspoon](https://www.hammerspoon.org)
- Google Chrome con la barra lateral de pestañas verticales habilitada
- Permiso de accesibilidad otorgado a Hammerspoon

## Activar la barra lateral de pestañas verticales en Chrome

La barra lateral de pestañas verticales no está activada por defecto. Para activarla:

1. Escribe `chrome://flags/#vertical-tabs` en la barra de direcciones
2. Cambia **Vertical tabs** a **Enabled**
3. Haz clic en **Relaunch** para reiniciar Chrome
4. Después de reiniciar, haz clic derecho en un área vacía de la barra de pestañas para ver la opción

## Instalación

1. Instalar Hammerspoon:

   ```bash
   brew install --cask hammerspoon
   ```

2. Elegir una versión y copiar a la configuración de Hammerspoon:

   **Versión con esquemas** (tres modos, por defecto):
   ```bash
   cp init.lua ~/.hammerspoon/init.lua
   ```

   **Versión solo teclado**:
   ```bash
   cp init-keyboard-only.lua ~/.hammerspoon/init.lua
   ```

   Si ya tienes un `~/.hammerspoon/init.lua`, añade el contenido al final.

3. Otorgar permiso de accesibilidad:
   - Ajustes del Sistema → Privacidad y Seguridad → Accesibilidad
   - Añadir y habilitar Hammerspoon

4. Recargar la configuración de Hammerspoon (haz clic en el icono de la barra de menú → Recargar Configuración)

5. (Opcional) Añadir Hammerspoon a los elementos de inicio para que se ejecute automáticamente:
   - Ajustes del Sistema → General → Ítems de inicio
   - Añadir Hammerspoon

## Esquemas (`init.lua`)

Edita la variable `SCHEME` en la parte superior de `init.lua` para elegir un modo:

| Esquema | Valor | Activadores |
|---------|-------|-------------|
| Solo teclado | `1` | `Cmd+S` alterna la barra lateral |
| Solo borde de la pantalla | `2` | Pasar el ratón por el borde izquierdo de la pantalla para expandir, mover más allá de 380px para contraer |
| Teclado + Ratón | `3` | Ambos activadores activos (por defecto) |

```lua
local SCHEME = 3  -- 1 = Teclado, 2 = Borde de la pantalla, 3 = Ambos
```

Cuando Chrome no es la aplicación en primer plano, todos los activadores se desactivan automáticamente.

## Activadores

| Activador | Acción | Esquema |
|-----------|--------|---------|
| `Cmd+S` | Alternar barra lateral | 1 & 3 |
| Ratón en el borde izquierdo (0-2px) durante 0.15s | Expandir barra lateral | 2 & 3 |
| Ratón se mueve más allá de 380px del borde izquierdo | Contraer barra lateral | 2 & 3 |

## Depuración

| Atajo | Acción |
|-------|--------|
| `Cmd+Alt+D` | Mostrar estado del servicio |
| `Cmd+Alt+B` | Volcar todos los botones AX de Chrome a la consola |
| `Cmd+Alt+R` | Forzar reinicio de todos los servicios |

## Configuración

### Selector de esquema (`init.lua`)

```lua
local SCHEME = 3  -- 1 = Teclado, 2 = Borde de la pantalla, 3 = Ambos
```

### Umbrales del borde de la pantalla (`init.lua`, esquemas 2 & 3)

```lua
local EDGE_THRESHOLD    = 2       -- píxeles desde el borde izquierdo para activar
local EXIT_THRESHOLD    = 380     -- píxeles desde el borde izquierdo para contraer
local WAIT_TIME         = 0.15    -- segundos de espera antes de activar
local MOUSE_POLL_INTERVAL = 0.05  -- segundos entre comprobaciones de posición del ratón
```

### Ambas versiones

```lua
local DEBUG = true  -- imprimir mensajes de depuración en la consola
```

## Personalizar el atajo de teclado

Disponible tanto en `init.lua` como en `init-keyboard-only.lua`. El atajo por defecto es `Cmd+S`, que sobrescribe el atajo nativo de Chrome para "Guardar página". Para cambiarlo, edita la comprobación de tecla en la función `createKeyTap`:

```lua
-- Cmd+S -> toggle sidebar
if flags.cmd and not flags.ctrl and not flags.alt and not flags.shift
    and keyCode == keycodes.map["s"] then
```

### Teclas modificadoras

Cambia las condiciones `flags.*` para establecer la combinación de modificadores deseada:

| Modificador | Bandera | Ejemplo |
|-------------|---------|---------|
| Cmd | `flags.cmd` | `flags.cmd and not flags.ctrl` |
| Ctrl | `flags.ctrl` | `flags.ctrl and not flags.cmd` |
| Alt/Option | `flags.alt` | `flags.alt` |
| Shift | `flags.shift` | `flags.shift` |

Establece la bandera en `true` para requerirla, `not flags.xxx` para excluirla.

### Código de tecla

Cambia `keycodes.map["s"]` por cualquier nombre de tecla. Ejemplos comunes:

```lua
keycodes.map["s"]       -- S
keycodes.map["b"]       -- B
keycodes.map["/"]       -- /
keycodes.map["return"]  -- Return/Enter
keycodes.map["space"]   -- Espacio
keycodes.map["f1"]      -- F1
```

Lista completa de nombres de tecla:ejecuta `hs.keycodes.map` en la consola de Hammerspoon.

### Ejemplos

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

Después de editar, recarga la configuración de Hammerspoon para aplicar los cambios.

## Cómo funciona

1. Un `eventtap` intercepta `Cmd+S` cuando Chrome está en primer plano (esquemas 1 & 3)
2. Un sondeo de posición del ratón (50Hz) detecta el paso por el borde izquierdo y la salida (esquemas 2 & 3)
3. Ambos activadores llaman a `toggleSidebar()` que:
   - Obtiene el elemento raíz AX de Chrome mediante `hs.axuielement.applicationElement()`
   - Busca en las ventanas un botón con `AXDescription` que coincida con "Expand Tabs" o "Collapse Tabs"
   - Llama a `performAction("AXPress")` en el botón encontrado
4. Un temporizador de vigilancia (watchdog) detecta si el sondeo del ratón falla y lo reinicia automáticamente (esquemas 2 & 3)
5. Períodos de tolerancia previenen activaciones falsas durante el cambio de aplicaciones

## Archivos

| Archivo | Descripción |
|---------|-------------|
| `init.lua` | Versión con 3 esquemas (teclado / ratón / ambos) |
| `init-keyboard-only.lua` | Versión solo teclado, sin detección de ratón |

## Créditos

- Concepto original:[ChromeSidebarToggleRaycast](https://github.com/RotulPlastik/ChromeSidebarToggleRaycast) by RotulPlastik
- Adaptado para Hammerspoon con soporte de activación por borde de la pantalla

## Licencia

MIT
