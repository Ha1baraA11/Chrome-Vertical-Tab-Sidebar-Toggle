<p align="center">
  <img src="assets/logo.png" alt="Chrome-Vertical-Tab-Sidebar-Toggle Logo" width="200">
</p>

<h1 align="center">Chrome-Vertical-Tab-Sidebar-Toggle</h1>

<p align="center">
  <strong>通过 macOS 辅助功能 API 切换 Chrome 原生垂直标签页侧边栏的 Hammerspoon 脚本</strong><br>
  键盘快捷键、屏幕边缘悬停触发，或两者兼用，随你选择。
</p>

<p align="center">
  <a href="README.md">English</a> · <a href="README.zh-TW.md">繁體中文</a> · <a href="README_ja.md">日本語</a> · <a href="README_ko.md">한국어</a> · <a href="README_es.md">Español</a> · <a href="README_pt-BR.md">Português</a> · <a href="README_ru.md">Русский</a> · <a href="README_fr.md">Français</a> · <a href="README_de.md">Deutsch</a>
</p>

---

## 功能介绍

Chrome 有内置的垂直标签页侧边栏，但没有快捷键来切换它。这个脚本提供两个版本来解决这个问题：

- **`init.lua`** — 支持三种可选方案（快捷键 / 鼠标边缘 / 两者兼有）
- **`init-keyboard-only.lua`** — 仅快捷键，无鼠标检测

原理是遍历 Chrome 的辅助功能树（`AXUIElement`），找到"Expand Tabs"或"Collapse Tabs"按钮，然后通过 `AXPress` 点击它。方法与 [ChromeSidebarToggleRaycast](https://github.com/RotulPlastik/ChromeSidebarToggleRaycast) 相同。

## 演示

https://github.com/user-attachments/assets/bcf2a76a-8028-4b63-bc8a-f0b9e1178a25

## 支持的 Chrome 语言环境

脚本通过匹配 Chrome 辅助功能树中的侧边栏按钮标签来工作。开箱即用支持以下语言环境：

| 语言 | 语言环境 | 展开标签页 | 收起标签页 |
|------|----------|-----------|-----------|
| 英语 | `en` | Expand tabs | Collapse tabs |
| 繁体中文 | `zh-TW` / `zh-HK` | 展開分頁 | 收合分頁 |
| 简体中文 | `zh-CN` | 展开标签页 | 收起标签页 |
| 日语 | `ja` | タブを開く | タブを閉じる |
| 韩语 | `ko` | 탭 펼치기 | 탭 접기 |
| 德语 | `de` | Tabs maximieren | Tabs minimieren |
| 西班牙语 | `es` | Mostrar pestañas | Ocultar pestañas |
| 法语 | `fr` | Développer les onglets | Réduire les onglets |
| 葡萄牙语（巴西） | `pt-BR` | Mostrar guias | Ocultar guias |
| 俄语 | `ru` | Развернуть вкладки | Свернуть вкладки |

如需添加其他语言，找到你所用 Chrome 语言环境下的按钮标签，追加到 `init.lua` 的 `SIDEBAR_LABELS` 表中即可。

## 系统要求

- macOS 13+
- [Hammerspoon](https://www.hammerspoon.org)
- Google Chrome 已启用垂直标签页侧边栏
- Hammerspoon 已获得辅助功能权限

## 在 Chrome 中开启垂直标签页侧边栏

垂直标签页侧边栏默认未开启，需要手动启用：

1. 在地址栏输入 `chrome://flags/#vertical-tabs`
2. 将 **Vertical tabs** 改为 **Enabled**
3. 点击 **Relaunch** 重启浏览器
4. 重启后，右键标签栏顶部空白处即可看到选项

## 安装步骤

1. 安装 Hammerspoon：

   ```bash
   brew install --cask hammerspoon
   ```

2. 选择一个版本，复制到 Hammerspoon 配置目录：

   **方案版本**（三种模式，默认）：
   ```bash
   cp init.lua ~/.hammerspoon/init.lua
   ```

   **纯快捷键版本**：
   ```bash
   cp init-keyboard-only.lua ~/.hammerspoon/init.lua
   ```

   如果已有 `~/.hammerspoon/init.lua`，请将内容追加到末尾。

3. 授予辅助功能权限：
   - 系统设置 → 隐私与安全性 → 辅助功能
   - 添加并启用 Hammerspoon

4. 重载 Hammerspoon 配置（点击菜单栏图标 → 重载配置）

5. （可选）将 Hammerspoon 添加到登录项，开机自动启动：
   - 系统设置 → 通用 → 登录项
   - 添加 Hammerspoon

## 方案选择（`init.lua`）

编辑 `init.lua` 顶部的 `SCHEME` 变量来选择模式：

| 方案 | 值 | 触发方式 |
|------|-----|----------|
| 纯快捷键 | `1` | `Cmd+S` 切换侧边栏 |
| 纯鼠标边缘 | `2` | 悬停左边缘展开，移出超过 380px 收起 |
| 快捷键 + 鼠标 | `3` | 两种触发同时生效（默认） |

```lua
local SCHEME = 3  -- 1 = 快捷键, 2 = 鼠标边缘, 3 = 两者兼有
```

当 Chrome 不是前台应用时，所有触发自动禁用。

## 触发方式

| 触发 | 动作 | 方案 |
|------|------|------|
| `Cmd+S` | 切换侧边栏 | 1 和 3 |
| 鼠标在左边缘（0-2px）悬停 0.15 秒 | 展开侧边栏 | 2 和 3 |
| 鼠标移出左边缘超过 380px | 收起侧边栏 | 2 和 3 |

## 调试

| 快捷键 | 功能 |
|--------|------|
| `Cmd+Alt+D` | 显示服务状态 |
| `Cmd+Alt+B` | 将 Chrome AX 树中所有按钮输出到控制台 |
| `Cmd+Alt+R` | 强制重启所有服务 |

## 配置项

### 方案选择器（`init.lua`）

```lua
local SCHEME = 3  -- 1 = 快捷键, 2 = 鼠标边缘, 3 = 两者兼有
```

### 鼠标边缘阈值（`init.lua`，方案 2 和 3）

```lua
local EDGE_THRESHOLD    = 2       -- 左边缘触发区域（像素）
local EXIT_THRESHOLD    = 380     -- 离开左边缘阈值（像素）
local WAIT_TIME         = 0.15    -- 悬停等待时间（秒）
local MOUSE_POLL_INTERVAL = 0.05  -- 鼠标轮询间隔（秒）
```

### 两个版本通用

```lua
local DEBUG = true  -- 是否输出调试信息到控制台
```

## 自定义快捷键

`init.lua` 和 `init-keyboard-only.lua` 均支持自定义快捷键。默认快捷键为 `Cmd+S`，会覆盖 Chrome 原生的"保存网页"快捷键。如需修改，编辑 `createKeyTap` 函数内的按键判断：

```lua
-- Cmd+S -> toggle sidebar
if flags.cmd and not flags.ctrl and not flags.alt and not flags.shift
    and keyCode == keycodes.map["s"] then
```

### 修饰键

修改 `flags.*` 条件来设置你想要的修饰键组合：

| 修饰键 | 标志 | 示例 |
|--------|------|------|
| Cmd | `flags.cmd` | `flags.cmd and not flags.ctrl` |
| Ctrl | `flags.ctrl` | `flags.ctrl and not flags.cmd` |
| Alt/Option | `flags.alt` | `flags.alt` |
| Shift | `flags.shift` | `flags.shift` |

设为 `true` 表示需要该键，`not flags.xxx` 表示排除该键。

### 按键代码

将 `keycodes.map["s"]` 改为任意按键名称。常用示例：

```lua
keycodes.map["s"]       -- S
keycodes.map["b"]       -- B
keycodes.map["/"]       -- /
keycodes.map["return"]  -- 回车
keycodes.map["space"]   -- 空格
keycodes.map["f1"]      -- F1
```

完整按键名称列表：在 Hammerspoon 控制台中运行 `hs.keycodes.map`。

### 示例

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

修改后重载 Hammerspoon 配置即可生效。

## 工作原理

1. 当 Chrome 处于前台时，`eventtap` 会拦截 `Cmd+S`（方案 1 和 3）
2. 鼠标位置轮询器（50Hz）检测左边缘悬停和离开（方案 2 和 3）
3. 两个触发器都调用 `toggleSidebar()`：
   - 通过 `hs.axuielement.applicationElement()` 获取 Chrome 的 AX 根元素
   - 在窗口中搜索 `AXDescription` 匹配 "Expand Tabs" 或 "Collapse Tabs" 的按钮
   - 调用 `performAction("AXPress")` 点击按钮
4. Watchdog 机制检测鼠标轮询器是否异常并自动重启（方案 2 和 3）
5. 防误触缓冲时间防止应用切换时的误触发

## 文件说明

| 文件 | 说明 |
|------|------|
| `init.lua` | 三方案版本（快捷键 / 鼠标 / 两者兼有） |
| `init-keyboard-only.lua` | 纯快捷键版本，无鼠标检测 |

## 致谢

- 原始方案：[ChromeSidebarToggleRaycast](https://github.com/RotulPlastik/ChromeSidebarToggleRaycast) by RotulPlastik
- 适配 Hammerspoon 并增加鼠标边缘触发

## 许可证

MIT
