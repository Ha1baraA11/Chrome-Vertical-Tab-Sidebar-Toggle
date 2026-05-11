-- ChromeVerticalTabSidebarToggle
-- Hammerspoon script to toggle Chrome's native vertical tab sidebar
-- via keyboard shortcut (Cmd+S) and/or mouse left-edge hover.
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
-- Schemes (edit SCHEME below to choose):
--   1 = Keyboard only      — Cmd+S toggles sidebar
--   2 = Mouse edge only    — hover left edge to expand, move away to collapse
--   3 = Keyboard + Mouse   — both triggers active (default)
--
-- Debug:
--   Cmd+Alt+D -> show service status
--   Cmd+Alt+B -> dump all Chrome AX buttons to Console
--   Cmd+Alt+R -> force restart all services

-- ----------------------------------------------------------
-- Scheme selector (1 / 2 / 3)
-- ----------------------------------------------------------
local SCHEME = 3

-- ----------------------------------------------------------
-- Modules
-- ----------------------------------------------------------
local eventtap   = hs.eventtap
local keycodes   = hs.keycodes
local appWatcher = hs.application.watcher
local caffeinate = hs.caffeinate
local timer      = hs.timer
local mouse      = hs.mouse
local app        = hs.application
local alert      = hs.alert

-- ----------------------------------------------------------
-- Configuration
-- ----------------------------------------------------------
local APP_NAME            = "Google Chrome"
local EDGE_THRESHOLD      = 2       -- px from left edge to trigger hover
local EXIT_THRESHOLD      = 380     -- px from left edge to trigger collapse
local WAIT_TIME           = 0.15    -- seconds to hover before triggering
local MOUSE_POLL_INTERVAL = 0.05    -- seconds between mouse position checks
local DEBUG               = true

local USE_KEYBOARD = (SCHEME == 1 or SCHEME == 3)
local USE_MOUSE    = (SCHEME == 2 or SCHEME == 3)

-- ----------------------------------------------------------
-- State
-- ----------------------------------------------------------
local keyTap          = nil
local mousePoller     = nil
local edgeTimer       = nil
local isEdgeActive    = false
local graceTimer      = nil
local totalEventCount = 0
_G.inSwitchingGracePeriod = false
_G.mouseLastHeartbeat     = timer.secondsSinceEpoch()

-- ----------------------------------------------------------
-- Forward declarations
-- ----------------------------------------------------------
local log, areServicesRunning, startServices, stopServices, restartServices
local createKeyTap, createMousePoller, resetEdgeState, toggleSidebar
local mousePollCallback, setGracePeriod, findSidebarButton

-- ----------------------------------------------------------
-- AX: Find sidebar button in Chrome's accessibility tree
-- ----------------------------------------------------------
findSidebarButton = function(axElement, depth)
    depth = depth or 0
    if not axElement or depth > 15 then return nil end

    local role = axElement:attributeValue("AXRole")
    if role == "AXButton" then
        local title = string.lower(tostring(axElement:attributeValue("AXTitle") or ""))
        local desc  = string.lower(tostring(axElement:attributeValue("AXDescription") or ""))
        if title == "expand tabs" or title == "collapse tabs"
            or desc == "expand tabs" or desc == "collapse tabs" then
            return axElement
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
-- Service management
-- ----------------------------------------------------------
areServicesRunning = function()
    local keyTapRunning      = not USE_KEYBOARD or (keyTap and keyTap:isEnabled())
    local mousePollerRunning = not USE_MOUSE or (mousePoller and mousePoller:isRunning())
    return keyTapRunning, mousePollerRunning
end

startServices = function()
    if USE_KEYBOARD then
        local keyTapRunning = keyTap and keyTap:isEnabled()
        if not keyTapRunning then
            createKeyTap()
            if keyTap then
                keyTap:start()
                log("KeyTap started")
            end
        end
    end

    if USE_MOUSE then
        local mousePollerRunning = mousePoller and mousePoller:isRunning()
        if not mousePollerRunning then
            createMousePoller()
            if mousePoller then
                mousePoller:start()
                log("MousePoller started")
            end
        end
    end
end

stopServices = function()
    if USE_KEYBOARD and keyTap and keyTap:isEnabled() then
        keyTap:stop()
        log("KeyTap stopped")
    end
    if USE_MOUSE and mousePoller and mousePoller:isRunning() then
        mousePoller:stop()
        log("MousePoller stopped")
    end
    resetEdgeState()
end

restartServices = function()
    log("Restarting services...")
    stopServices()
    timer.doAfter(0.5, function()
        startServices()
        log("Services restarted")
        _G.mouseLastHeartbeat = timer.secondsSinceEpoch()
    end)
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
-- Keyboard: Cmd+S intercept + watchdog
-- ----------------------------------------------------------
createKeyTap = function()
    if keyTap then
        keyTap:stop()
        keyTap = nil
    end

    keyTap = eventtap.new({eventtap.event.types.keyDown}, function(event)
        totalEventCount = totalEventCount + 1

        local frontApp = app.frontmostApplication()
        if frontApp and frontApp:name() == APP_NAME and not _G.inSwitchingGracePeriod then
            local now = timer.secondsSinceEpoch()
            if (now - _G.mouseLastHeartbeat) > 5 then
                log("[Watchdog] MousePoller dead, rebuilding...")
                restartServices()
            end
        end

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

    return keyTap
end

-- ----------------------------------------------------------
-- Mouse: Left-edge hover trigger
-- ----------------------------------------------------------
resetEdgeState = function()
    if edgeTimer then
        edgeTimer:stop()
        edgeTimer = nil
    end
    isEdgeActive = false
end

mousePollCallback = function()
    _G.mouseLastHeartbeat = timer.secondsSinceEpoch()

    local frontApp = app.frontmostApplication()
    if not frontApp or frontApp:name() ~= APP_NAME or _G.inSwitchingGracePeriod then
        resetEdgeState()
        return
    end

    local pos = mouse.absolutePosition()
    local currentScreen = mouse.getCurrentScreen()
    if not currentScreen then return end

    local screenFrame = currentScreen:frame()
    local relativeX = pos.x - screenFrame.x

    if relativeX <= EDGE_THRESHOLD and not isEdgeActive then
        isEdgeActive = true
        log("Mouse entered left edge, waiting...")

        edgeTimer = timer.doAfter(WAIT_TIME, function()
            local currentPos = mouse.absolutePosition()
            local currentScreenNow = mouse.getCurrentScreen()
            if not currentScreenNow then
                isEdgeActive = false
                return
            end

            local currentRelativeX = currentPos.x - currentScreenNow:frame().x
            local currentApp = app.frontmostApplication()

            if currentRelativeX <= EDGE_THRESHOLD and currentApp and currentApp:name() == APP_NAME then
                toggleSidebar()
            else
                isEdgeActive = false
            end
        end)
    elseif isEdgeActive and relativeX >= EXIT_THRESHOLD then
        log("Mouse exited left edge (> " .. EXIT_THRESHOLD .. "px)")
        resetEdgeState()
        toggleSidebar()
    end
end

createMousePoller = function()
    if mousePoller then
        mousePoller:stop()
        mousePoller = nil
    end
    mousePoller = timer.doEvery(MOUSE_POLL_INTERVAL, mousePollCallback)
    return mousePoller
end

-- ----------------------------------------------------------
-- App lifecycle: Chrome focus / defocus / sleep
-- ----------------------------------------------------------
startServices()

appWatcher.new(function(appName, eventType, _)
    if appName ~= APP_NAME then return end

    if eventType == appWatcher.activated then
        log("Chrome activated")
        setGracePeriod(1.5)
        timer.doAfter(0.5, startServices)
    elseif eventType == appWatcher.deactivated then
        log("Chrome deactivated")
        setGracePeriod(1)
        timer.doAfter(0.3, stopServices)
    elseif eventType == appWatcher.launched then
        log("Chrome launched")
        setGracePeriod(2)
    elseif eventType == appWatcher.terminated then
        log("Chrome terminated")
        stopServices()
    end
end):start()

caffeinate.watcher.new(function(event)
    if event == caffeinate.watcher.systemDidWake then
        log("System woke up")
        setGracePeriod(3)
        timer.doAfter(2, function()
            restartServices()
            if app.frontmostApplication():name() == APP_NAME then
                log("Woke into Chrome, services restored")
            end
        end)
    elseif event == caffeinate.watcher.systemWillSleep then
        log("System sleeping")
        stopServices()
    end
end):start()

-- ----------------------------------------------------------
-- Init
-- ----------------------------------------------------------
timer.doAfter(2, function()
    local frontApp = app.frontmostApplication()
    if frontApp and frontApp:name() == APP_NAME then
        log("Initialized in Chrome")
        startServices()
    else
        log("Initialized (not in Chrome)")
    end
    setGracePeriod(2)
end)

-- ----------------------------------------------------------
-- Debug hotkeys
-- ----------------------------------------------------------
hs.hotkey.bind({"cmd", "alt"}, "D", function()
    local keyTapRunning, mousePollerRunning = areServicesRunning()
    local frontApp = app.frontmostApplication()

    local schemeName = ({ "Keyboard Only", "Mouse Edge Only", "Keyboard + Mouse" })[SCHEME]

    local status = string.format(
        "ChromeVerticalTabSidebarToggle:\n" ..
        "Scheme: %s (%d)\n" ..
        "App: %s\n" ..
        "KeyTap: %s\n" ..
        "MousePoller: %s\n" ..
        "Events: %d\n" ..
        "Grace: %s\n" ..
        "Heartbeat: %.1fs ago",
        schemeName, SCHEME,
        frontApp and frontApp:name() or "None",
        keyTapRunning and "running" or "stopped",
        mousePollerRunning and "running" or "stopped",
        totalEventCount,
        _G.inSwitchingGracePeriod and "yes" or "no",
        timer.secondsSinceEpoch() - _G.mouseLastHeartbeat
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
    alert.show("Restarting services...", 2)
    restartServices()
end)

log("ChromeVerticalTabSidebarToggle loaded (scheme " .. SCHEME .. ")")
