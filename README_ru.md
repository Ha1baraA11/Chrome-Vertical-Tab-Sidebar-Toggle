<p align="center">
  <img src="assets/logo.png" alt="Chrome-Vertical-Tab-Sidebar-Toggle Logo" width="200">
</p>

<h1 align="center">Chrome-Vertical-Tab-Sidebar-Toggle</h1>

<p align="center">
  <strong>Скрипт Hammerspoon для переключения боковой панели вертикальных вкладок Chrome через API доступности macOS</strong><br>
  Горячая клавиша, активация при наведении на край, или оба варианта — выбор за вами.
</p>

<p align="center">
  <a href="README.md">English</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.zh-TW.md">繁體中文</a> · <a href="README_ja.md">日本語</a> · <a href="README_ko.md">한국어</a> · <a href="README_es.md">Español</a> · <a href="README_pt-BR.md">Português</a> · <a href="README_fr.md">Français</a> · <a href="README_de.md">Deutsch</a>
</p>

---

## Что делает

В Chrome есть встроенная боковая панель вертикальных вкладок, но нет горячей клавиши для её переключения. Этот скрипт решает проблему двумя версиями：

- **`init.lua`** — поддерживает три выборочных схемы (клавиатура / край мыши / оба)
- **`init-keyboard-only.lua`** — только горячие клавиши, без обнаружения мыши

Работает путём обхода дерева доступности Chrome (`AXUIElement`) для поиска кнопки "Expand Tabs" / "Collapse Tabs" и нажатия через `AXPress`. Тот же подход, что и в [ChromeSidebarToggleRaycast](https://github.com/RotulPlastik/ChromeSidebarToggleRaycast).

## Демо

https://github.com/user-attachments/assets/bcf2a76a-8028-4b63-bc8a-f0b9e1178a25

## Требования

- macOS 13+
- [Hammerspoon](https://www.hammerspoon.org)
- Google Chrome с включённой боковой панелью вертикальных вкладок
- Разрешение на доступность, выданное Hammerspoon

## Включение боковой панели вертикальных вкладок в Chrome

Боковая панель вертикальных вкладок по умолчанию отключена. Чтобы включить：

1. Введите `chrome://flags/#vertical-tabs` в адресной строке
2. Измените **Vertical tabs** на **Enabled**
3. Нажмите **Relaunch** для перезапуска Chrome
4. После перезапуска щёлкните правой кнопкой мыши по пустой области панели вкладок, чтобы увидеть опцию

## Установка

1. Установить Hammerspoon：

   ```bash
   brew install --cask hammerspoon
   ```

2. Выбрать версию и скопировать в конфигурацию Hammerspoon：

   **Версия со схемами**（три режима, по умолчанию）：
   ```bash
   cp init.lua ~/.hammerspoon/init.lua
   ```

   **Версия только с клавиатурой**：
   ```bash
   cp init-keyboard-only.lua ~/.hammerspoon/init.lua
   ```

   Если у вас уже есть `~/.hammerspoon/init.lua`, добавьте содержимое в конец.

3. Предоставить разрешение на доступность：
   - Системные настройки → Конфиденциальность и безопасность → Специальные возможности
   - Добавить и включить Hammerspoon

4. Перезагрузить конфигурацию Hammerspoon（нажмите на значок в строке меню → Перезагрузить конфигурацию）

5. （Необязательно）Добавить Hammerspoon в элементы входа для автоматического запуска：
   - Системные настройки → Основные → Элементы входа
   - Добавить Hammerspoon

## Схемы（`init.lua`）

Отредактируйте переменную `SCHEME` в верхней части `init.lua` для выбора режима：

| Схема | Значение | Триггеры |
|-------|----------|----------|
| Только клавиатура | `1` | `Cmd+S` переключает боковую панель |
| Только край мыши | `2` | Наведение на левый край для развёртывания, перемещение за 380px для свёртывания |
| Клавиатура + Мышь | `3` | Оба триггера активны（по умолчанию） |

```lua
local SCHEME = 3  -- 1 = Клавиатура, 2 = Край мыши, 3 = Оба
```

Когда Chrome не является активным приложением, все триггеры автоматически отключаются.

## Триггеры

| Триггер | Действие | Схема |
|---------|----------|-------|
| `Cmd+S` | Переключить боковую панель | 1 & 3 |
| Мышь на левом краю (0-2px) в течение 0.15с | Развёрнуть боковую панель | 2 & 3 |
| Мышь перемещается за 380px от левого края | Свернуть боковую панель | 2 & 3 |

## Отладка

| Комбинация | Действие |
|------------|----------|
| `Cmd+Alt+D` | Показать статус службы |
| `Cmd+Alt+B` | Вывести все кнопки AX Chrome в консоль |
| `Cmd+Alt+R` | Принудительный перезапуск всех служб |

## Конфигурация

### Селектор схемы（`init.lua`）

```lua
local SCHEME = 3  -- 1 = Клавиатура, 2 = Край мыши, 3 = Оба
```

### Пороговые значения края мыши（`init.lua`, схемы 2 & 3）

```lua
local EDGE_THRESHOLD    = 2       -- пикселей от левого края для срабатывания
local EXIT_THRESHOLD    = 380     -- пикселей от левого края для свёртывания
local WAIT_TIME         = 0.15    -- секунд ожидания перед срабатыванием
local MOUSE_POLL_INTERVAL = 0.05  -- секунд между проверками позиции мыши
```

### Обе версии

```lua
local DEBUG = true  -- выводить отладочные сообщения в консоль
```

## Настройка горячих клавиш

Доступно в `init.lua` и `init-keyboard-only.lua`. Комбинация по умолчанию — `Cmd+S`, которая перезаписывает стандартное сочетание клавиш Chrome для «Сохранить страницу». Для изменения отредактируйте проверку клавиши в функции `createKeyTap`：

```lua
-- Cmd+S -> toggle sidebar
if flags.cmd and not flags.ctrl and not flags.alt and not flags.shift
    and keyCode == keycodes.map["s"] then
```

### Модификаторы

Измените условия `flags.*` для установки желаемой комбинации модификаторов：

| Модификатор | Флаг | Пример |
|-------------|------|--------|
| Cmd | `flags.cmd` | `flags.cmd and not flags.ctrl` |
| Ctrl | `flags.ctrl` | `flags.ctrl and not flags.cmd` |
| Alt/Option | `flags.alt` | `flags.alt` |
| Shift | `flags.shift` | `flags.shift` |

Установите флаг в `true` для требования, `not flags.xxx` для исключения.

### Код клавиши

Замените `keycodes.map["s"]` на любое имя клавиши. Частые примеры：

```lua
keycodes.map["s"]       -- S
keycodes.map["b"]       -- B
keycodes.map["/"]       -- /
keycodes.map["return"]  -- Return/Enter
keycodes.map["space"]   -- Пробел
keycodes.map["f1"]      -- F1
```

Полный список имён клавиш：выполните `hs.keycodes.map` в консоли Hammerspoon.

### Примеры

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

После редактирования перезагрузите конфигурацию Hammerspoon для применения изменений.

## Как это работает

1. `eventtap` перехватывает `Cmd+S`, когда Chrome является активным приложением（схемы 1 & 3）
2. Определитель позиции мыши (50Hz) обнаруживает наведение на левый край и уход（схемы 2 & 3）
3. Оба триггера вызывают `toggleSidebar()`, который：
   - Получает корневой элемент AX Chrome через `hs.axuielement.applicationElement()`
   - Ищет в окнах кнопку с `AXDescription`, соответствующим "Expand Tabs" или "Collapse Tabs"
   - Вызывает `performAction("AXPress")` на найденной кнопке
4. Сторож обнаруживает сбой определителя мыши и автоматически перезапускает его（схемы 2 & 3）
5. Периоды задержки предотвращают ложные срабатывания при переключении приложений

## Файлы

| Файл | Описание |
|------|----------|
| `init.lua` | Версия с 3 схемами（клавиатура / мышь / оба） |
| `init-keyboard-only.lua` | Версия только с клавиатурой, без обнаружения мыши |

## Благодарности

- Оригинальная концепция：[ChromeSidebarToggleRaycast](https://github.com/RotulPlastik/ChromeSidebarToggleRaycast) by RotulPlastik
- Адаптировано для Hammerspoon с поддержкой активации при наведении на край

## Лицензия

MIT
