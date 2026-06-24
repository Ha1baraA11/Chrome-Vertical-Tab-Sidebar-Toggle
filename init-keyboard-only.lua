-- Chrome-Vertical-Tab-Sidebar-Toggle (Keyboard Only)
-- Hammerspoon script to toggle Chrome's native vertical tab sidebar
-- via keyboard shortcut only (Cmd+S).
-- Uses macOS Accessibility API to find and press the sidebar button.
--
-- Requirements:
--   - Hammerspoon (https://www.hammerspoon.org)
--   - macOS Accessibility permission granted to Hammerspoon
--   - Chrome with vertical tab sidebar enabled
--
-- Usage:
--   Copy this file to ~/.hammerspoon/init.lua
--   (or append to your existing init.lua)
--
-- Triggers:
--   Cmd+S in Chrome -> toggle sidebar (blocks Chrome's save-page)
--
-- Debug:
--   Cmd+Alt+D -> show service status
--   Cmd+Alt+B -> dump all Chrome AX buttons to Console
--   Cmd+Alt+R -> force restart key tap

-- ----------------------------------------------------------
-- Modules
-- ----------------------------------------------------------
local eventtap  = hs.eventtap
local keycodes  = hs.keycodes
local appWatcher = hs.application.watcher
local caffeinate = hs.caffeinate
local timer     = hs.timer
local app       = hs.application
local alert     = hs.alert

-- ----------------------------------------------------------
-- Configuration
-- ----------------------------------------------------------
local APP_NAME = "Google Chrome"
local DEBUG    = true

-- Sidebar toggle button labels (lower-case), matched against AXTitle/AXDescription.
-- Chrome localizes these, so include every locale you use.
local SIDEBAR_LABELS = {
    "expand tabs", "collapse tabs",             -- English
    "展開分頁", "收合分頁",                       -- Traditional Chinese
    "展开标签页", "收起标签页",                   -- Simplified Chinese
    "タブを開く", "タブを閉じる",                 -- Japanese
    "탭 펼치기", "탭 접기",                       -- Korean
    "tabs maximieren", "tabs minimieren",       -- German
    "mostrar pestañas", "ocultar pestañas",     -- Spanish
    "développer les onglets", "réduire les onglets", -- French
    "mostrar guias", "ocultar guias",           -- Portuguese (Brazil)
    "развернуть вкладки", "свернуть вкладки",   -- Russian
}

-- ----------------------------------------------------------
-- State
-- ----------------------------------------------------------
local keyTap          = nil
local graceTimer      = nil
local totalEventCount = 0
_G.inSwitchingGracePeriod = false

-- ----------------------------------------------------------
-- Forward declarations
-- ----------------------------------------------------------
local log, startKeyTap, stopKeyTap, restartKeyTap
local toggleSidebar, setGracePeriod, findSidebarButton

-- ----------------------------------------------------------
-- AX: Find sidebar button in Chrome's accessibility tree
-- ----------------------------------------------------------
findSidebarButton = function(axElement, depth)
    depth = depth or 0
    if not axElement or depth > 25 then return nil end

    local role = axElement:attributeValue("AXRole")
    if role == "AXButton" then
        local title = string.lower(tostring(axElement:attributeValue("AXTitle") or ""))
        local desc  = string.lower(tostring(axElement:attributeValue("AXDescription") or ""))
        for _, label in ipairs(SIDEBAR_LABELS) do
            if title == label or desc == label then
                return axElement
            end
        end
    end

    local children = axElement:attributeValue("AXChildren")
    if children then
        for _, child in ipairs(children) do
            local result = findSidebarButton(child, depth + 1)
            if result then return result end
        end
    end
    return nil
end

-- ----------------------------------------------------------
-- Core: Toggle sidebar via AX API
-- ----------------------------------------------------------
toggleSidebar = function()
    totalEventCount = totalEventCount + 1

    local frontApp = app.frontmostApplication()
    if not frontApp or frontApp:name() ~= APP_NAME or _G.inSwitchingGracePeriod then
        return
    end

    local axApp = hs.axuielement.applicationElement(frontApp)
    local windows = axApp:attributeValue("AXWindows")
    if not windows or #windows == 0 then
        log("No Chrome windows found")
        return
    end

    local button = nil
    for _, win in ipairs(windows) do
        button = findSidebarButton(win)
        if button then break end
    end

    if button then
        button:performAction("AXPress")
        log("Sidebar toggled via AX API")
    else
        log("Sidebar button not found in AX tree")
    end
end

-- ----------------------------------------------------------
-- Logging
-- ----------------------------------------------------------
log = function(message)
    if DEBUG then
        print("[TabFlip] " .. message)
    end
end

-- ----------------------------------------------------------
-- Grace period (avoids triggers during app switching)
-- ----------------------------------------------------------
setGracePeriod = function(seconds)
    _G.inSwitchingGracePeriod = true
    if graceTimer then graceTimer:stop() end
    graceTimer = timer.doAfter(seconds, function()
        _G.inSwitchingGracePeriod = false
        log("Grace period ended")
    end)
    log("Grace period: " .. seconds .. "s")
end

-- ----------------------------------------------------------
-- Keyboard: Cmd+S intercept
-- ----------------------------------------------------------
startKeyTap = function()
    if keyTap and keyTap:isEnabled() then return end

    if keyTap then
        keyTap:stop()
        keyTap = nil
    end

    keyTap = eventtap.new({eventtap.event.types.keyDown}, function(event)
        totalEventCount = totalEventCount + 1

        local frontApp = app.frontmostApplication()
        if not frontApp or frontApp:name() ~= APP_NAME or _G.inSwitchingGracePeriod then
            return false
        end

        local flags = event:getFlags()
        local keyCode = event:getKeyCode()

        -- Cmd+S -> toggle sidebar
        if flags.cmd and not flags.ctrl and not flags.alt and not flags.shift
            and keyCode == keycodes.map["s"] then
            log("Cmd+S intercepted, toggling sidebar")
            toggleSidebar()
            return true
        end

        return false
    end)

    if keyTap then
        keyTap:start()
        log("KeyTap started")
    end
end

stopKeyTap = function()
    if keyTap and keyTap:isEnabled() then
        keyTap:stop()
        log("KeyTap stopped")
    end
end

restartKeyTap = function()
    log("Restarting KeyTap...")
    stopKeyTap()
    timer.doAfter(0.5, function()
        startKeyTap()
        log("KeyTap restarted")
    end)
end

-- ----------------------------------------------------------
-- App lifecycle: Chrome focus / defocus / sleep
-- ----------------------------------------------------------
startKeyTap()

appWatcher.new(function(appName, eventType, _)
    if appName ~= APP_NAME then return end

    if eventType == appWatcher.activated then
        log("Chrome activated")
        setGracePeriod(1.5)
        timer.doAfter(0.5, startKeyTap)
    elseif eventType == appWatcher.deactivated then
        log("Chrome deactivated")
        setGracePeriod(1)
        timer.doAfter(0.3, stopKeyTap)
    elseif eventType == appWatcher.launched then
        log("Chrome launched")
        setGracePeriod(2)
    elseif eventType == appWatcher.terminated then
        log("Chrome terminated")
        stopKeyTap()
    end
end):start()

caffeinate.watcher.new(function(event)
    if event == caffeinate.watcher.systemDidWake then
        log("System woke up")
        setGracePeriod(3)
        timer.doAfter(2, function()
            restartKeyTap()
            if app.frontmostApplication():name() == APP_NAME then
                log("Woke into Chrome, KeyTap restored")
            end
        end)
    elseif event == caffeinate.watcher.systemWillSleep then
        log("System sleeping")
        stopKeyTap()
    end
end):start()

-- ----------------------------------------------------------
-- Init
-- ----------------------------------------------------------
timer.doAfter(2, function()
    local frontApp = app.frontmostApplication()
    if frontApp and frontApp:name() == APP_NAME then
        log("Initialized in Chrome")
        startKeyTap()
    else
        log("Initialized (not in Chrome)")
    end
    setGracePeriod(2)
end)

-- ----------------------------------------------------------
-- Debug hotkeys
-- ----------------------------------------------------------
hs.hotkey.bind({"cmd", "alt"}, "D", function()
    local frontApp = app.frontmostApplication()
    local keyTapRunning = keyTap and keyTap:isEnabled()

    local status = string.format(
        "Chrome-Vertical-Tab-Sidebar-Toggle (Keyboard Only):\n" ..
        "App: %s\n" ..
        "KeyTap: %s\n" ..
        "Events: %d\n" ..
        "Grace: %s",
        frontApp and frontApp:name() or "None",
        keyTapRunning and "running" or "stopped",
        totalEventCount,
        _G.inSwitchingGracePeriod and "yes" or "no"
    )

    alert.show(status, 5)
    log("Status: " .. status:gsub("\n", ", "))
end)

hs.hotkey.bind({"cmd", "alt"}, "B", function()
    local frontApp = app.frontmostApplication()
    if not frontApp or frontApp:name() ~= APP_NAME then
        alert.show("Chrome is not frontmost", 3)
        return
    end

    local axApp = hs.axuielement.applicationElement(frontApp)
    local windows = axApp:attributeValue("AXWindows")
    if not windows or #windows == 0 then
        alert.show("No windows", 3)
        return
    end

    local results = {}
    local function dumpButtons(el, depth)
        if not el or depth > 15 then return end
        local role = el:attributeValue("AXRole")
        local title = el:attributeValue("AXTitle")
        local desc = el:attributeValue("AXDescription")
        local help = el:attributeValue("AXHelp")

        if role == "AXButton" then
            table.insert(results, string.format(
                "Title: [%s] | Desc: [%s] | Help: [%s]",
                tostring(title), tostring(desc), tostring(help)
            ))
        end

        local children = el:attributeValue("AXChildren")
        if children then
            for _, child in ipairs(children) do
                dumpButtons(child, depth + 1)
            end
        end
    end

    for _, win in ipairs(windows) do
        dumpButtons(win, 0)
    end

    print("=== Chrome AX Buttons ===")
    for i, r in ipairs(results) do
        print(i .. ". " .. r)
    end
    print("=== Total: " .. #results .. " buttons ===")
    alert.show("Found " .. #results .. " buttons, check Console", 3)
end)

hs.hotkey.bind({"cmd", "alt"}, "R", function()
    alert.show("Restarting KeyTap...", 2)
    restartKeyTap()
end)

log("Chrome-Vertical-Tab-Sidebar-Toggle (Keyboard Only) loaded")
