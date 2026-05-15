<p align="center">
  <img src="assets/logo.png" alt="Chrome-Vertical-Tab-Sidebar-Toggle Logo" width="200">
</p>

<h1 align="center">Chrome-Vertical-Tab-Sidebar-Toggle</h1>

<p align="center">
  <strong>透過 macOS 無障礙 API 切換 Chrome 原生垂直標籤欄側邊欄的 Hammerspoon 腳本</strong><br>
  鍵盤快捷鍵、滑鼠邊緣觸發，或兩者兼用，隨你選擇。
</p>

<p align="center">
  <a href="README.md">English</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.zh-TW.md">繁體中文</a>
</p>

---

## 功能介紹

Chrome 有內建的垂直標籤欄側邊欄，但沒有快捷鍵來切換它。這個腳本提供兩個版本來解決這個問題：

- **`init.lua`** — 支援三種可選方案（快捷鍵 / 滑鼠邊緣 / 兩者兼有）
- **`init-keyboard-only.lua`** — 僅快捷鍵，無滑鼠偵測

原理是遍歷 Chrome 的無障礙樹（`AXUIElement`），找到「Expand Tabs」或「Collapse Tabs」按鈕，然後透過 `AXPress` 點擊它。方法與 [ChromeSidebarToggleRaycast](https://github.com/RotulPlastik/ChromeSidebarToggleRaycast) 相同。

## 系統要求

- macOS 13+
- [Hammerspoon](https://www.hammerspoon.org)
- Google Chrome 已啟用垂直標籤欄側邊欄
- Hammerspoon 已取得輔助使用權限

## 安裝步驟

1. 安裝 Hammerspoon：

   ```bash
   brew install --cask hammerspoon
   ```

2. 選擇一個版本，複製到 Hammerspoon 設定目錄：

   **方案版本**（三種模式，預設）：
   ```bash
   cp init.lua ~/.hammerspoon/init.lua
   ```

   **純快捷鍵版本**：
   ```bash
   cp init-keyboard-only.lua ~/.hammerspoon/init.lua
   ```

   如果已有 `~/.hammerspoon/init.lua`，請將內容附加到末尾。

3. 授予輔助使用權限：
   - 系統設定 → 隱私與安全性 → 輔助使用
   - 新增並啟用 Hammerspoon

4. 重新載入 Hammerspoon 設定（點選選單列圖示 → 重新載入設定）

## 方案選擇（`init.lua`）

編輯 `init.lua` 頂部的 `SCHEME` 變數來選擇模式：

| 方案 | 值 | 觸發方式 |
|------|-----|----------|
| 純快捷鍵 | `1` | `Cmd+S` 切換側邊欄 |
| 純滑鼠邊緣 | `2` | 懸停左邊緣展開，移出超過 380px 收合 |
| 快捷鍵 + 滑鼠 | `3` | 兩種觸發同時生效（預設） |

```lua
local SCHEME = 3  -- 1 = 快捷鍵, 2 = 滑鼠邊緣, 3 = 兩者兼有
```

當 Chrome 不是前景應用時，所有觸發自動停用。

## 觸發方式

| 觸發 | 動作 | 方案 |
|------|------|------|
| `Cmd+S` | 切換側邊欄 | 1 和 3 |
| 滑鼠在左邊緣（0-2px）懸停 0.15 秒 | 展開側邊欄 | 2 和 3 |
| 滑鼠移出左邊緣超過 380px | 收合側邊欄 | 2 和 3 |

## 偵錯

| 快捷鍵 | 功能 |
|--------|------|
| `Cmd+Alt+D` | 顯示服務狀態 |
| `Cmd+Alt+B` | 將 Chrome AX 樹中所有按鈕輸出到控制台 |
| `Cmd+Alt+R` | 強制重新啟動所有服務 |

## 設定項目

### 方案選擇器（`init.lua`）

```lua
local SCHEME = 3  -- 1 = 快捷鍵, 2 = 滑鼠邊緣, 3 = 兩者兼有
```

### 滑鼠邊緣閾值（`init.lua`，方案 2 和 3）

```lua
local EDGE_THRESHOLD    = 2       -- 左邊緣觸發區域（像素）
local EXIT_THRESHOLD    = 380     -- 離開左邊緣閾值（像素）
local WAIT_TIME         = 0.15    -- 懸停等待時間（秒）
local MOUSE_POLL_INTERVAL = 0.05  -- 滑鼠輪詢間隔（秒）
```

### 兩個版本通用

```lua
local DEBUG = true  -- 是否輸出偵錯資訊到控制台
```

## 自訂快捷鍵

`init.lua` 和 `init-keyboard-only.lua` 均支援自訂快捷鍵。預設快捷鍵為 `Cmd+S`。如需修改，編輯 `createKeyTap` 函式內的按鍵判斷：

```lua
-- Cmd+S -> toggle sidebar
if flags.cmd and not flags.ctrl and not flags.alt and not flags.shift
    and keyCode == keycodes.map["s"] then
```

### 修飾鍵

修改 `flags.*` 條件來設定你想要的修飾鍵組合：

| 修飾鍵 | 標誌 | 範例 |
|--------|------|------|
| Cmd | `flags.cmd` | `flags.cmd and not flags.ctrl` |
| Ctrl | `flags.ctrl` | `flags.ctrl and not flags.cmd` |
| Alt/Option | `flags.alt` | `flags.alt` |
| Shift | `flags.shift` | `flags.shift` |

設為 `true` 表示需要該鍵，`not flags.xxx` 表示排除該鍵。

### 按鍵代碼

將 `keycodes.map["s"]` 改為任意按鍵名稱。常用範例：

```lua
keycodes.map["s"]       -- S
keycodes.map["b"]       -- B
keycodes.map["/"]       -- /
keycodes.map["return"]  -- Enter
keycodes.map["space"]   -- 空白鍵
keycodes.map["f1"]      -- F1
```

完整按鍵名稱列表：在 Hammerspoon 控制台中執行 `hs.keycodes.map`。

### 範例

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

修改後重新載入 Hammerspoon 設定即可生效。

## 工作原理

1. `eventtap` 在 Chrome 為前景時攔截 `Cmd+S`（方案 1 和 3）
2. 滑鼠位置輪詢器（50Hz）偵測左邊緣懸停和離開（方案 2 和 3）
3. 兩個觸發器都呼叫 `toggleSidebar()`：
   - 透過 `hs.axuielement.applicationElement()` 取得 Chrome 的 AX 根元素
   - 在視窗中搜尋 `AXDescription` 符合「Expand Tabs」或「Collapse Tabs」的按鈕
   - 呼叫 `performAction("AXPress")` 點擊按鈕
4. 看門狗偵測滑鼠輪詢器是否停止並自動重新啟動（方案 2 和 3）
5. 寬限期防止應用切換時的誤觸發

## 檔案說明

| 檔案 | 說明 |
|------|------|
| `init.lua` | 三方案版本（快捷鍵 / 滑鼠 / 兩者兼有） |
| `init-keyboard-only.lua` | 純快捷鍵版本，無滑鼠偵測 |

## 致謝

- 原始方案：[ChromeSidebarToggleRaycast](https://github.com/RotulPlastik/ChromeSidebarToggleRaycast) by RotulPlastik
- 適配 Hammerspoon 並增加滑鼠邊緣觸發

## 授權條款

MIT
