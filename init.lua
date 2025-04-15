
-- toggle functionality
local appHistory = {}
local historyLimit = 10  -- last 10 apps
local isManualSwitch = false  -- flag to track if manually switching apps

-- carousel functionality 
-- whatever apps are added here are included in the possible apps you can cycle through
local carouselApps = {
    "Google Chrome",
    "iTerm2",
    "Simulator",
}

local currentCarouselIndex = 1

-- function to update application history when focus changes
local function applicationWatcher(appName, eventType)
    if eventType == hs.application.watcher.activated then
        -- update history if this wasn't triggered by our own switcher
        -- or if it was but we've now reset the flag
        if not isManualSwitch then
            -- remove the app from history if it's already there
            for i, existingApp in ipairs(appHistory) do
                if existingApp == appName then
                    table.remove(appHistory, i)
                    break
                end
            end
            -- add the app to the front of history
            table.insert(appHistory, 1, appName)
            -- trim history if it's too long
            if #appHistory > historyLimit then
                table.remove(appHistory)
            end
            -- Debug
            print("App history updated:")
            for i, app in ipairs(appHistory) do
                print(i .. ": " .. app)
            end

            -- update currentCarouselIndex if current app is in carousel
            for i, app in ipairs(carouselApps) do
                if app == appName then
                    currentCarouselIndex = i
                    break
                end
            end
        else
            -- reset the flag for next time
            isManualSwitch = false
        end
    end
end

-- application watcher
local appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()

-- function to toggle between the two most recent applications
local function toggleBetweenApps()
    if #appHistory >= 2 then
        local currentApp = appHistory[1]
        local targetApp = appHistory[2]
        -- swap the top two apps in our history to reflect the change
        appHistory[1] = targetApp
        appHistory[2] = currentApp
        print("Toggling from: " .. currentApp .. " to: " .. targetApp)
        -- set the flag so we don't double-update history
        isManualSwitch = true
        -- get the actual application object instead of just using the name
        local app = hs.application.get(targetApp)
        if app then
            -- activate the app and bring it to front
            app:activate(true)
        else
            -- fallback to launchOrFocus 
            hs.application.launchOrFocus(targetApp)
        end
    else
        print("Need at least 2 apps in history to toggle")
    end
end

-- function to cycle through the carousel of selected apps
local function cycleNextApp()
    -- get list of running applications that match our carousel
    local runningCarouselApps = {}
    local allApps = hs.application.runningApplications()
    for _, app in ipairs(allApps) do
        local appName = app:name()
        for _, carouselApp in ipairs(carouselApps) do
            if appName == carouselApp then
                table.insert(runningCarouselApps, appName)
                break
            end
        end
    end
	
    -- if no carousel apps are running, do nothing
    if #runningCarouselApps == 0 then
        print("No carousel apps are currently running")
        return
    end
    
    -- find current app in the running carousel apps
    local currentAppName = hs.application.frontmostApplication():name()
    local currentIndex = 0
    
    for i, app in ipairs(runningCarouselApps) do
        if app == currentAppName then
            currentIndex = i
            break
        end
    end
    
    -- determine next app (if current app isn't in carousel, start at the beginning)
    local nextIndex = currentIndex + 1
    if nextIndex > #runningCarouselApps or currentIndex == 0 then
        nextIndex = 1
    end
    
    local targetApp = runningCarouselApps[nextIndex]
    print("Cycling to: " .. targetApp)
    
    -- set the flag so we don't double-update history
    isManualSwitch = true
    
    -- get the actual application object and activate it
    local app = hs.application.get(targetApp)
    if app then
        app:activate(true)
    end
end

-- this is the command that just goes back and forth between the last two apps
-- this binding is not practical without a customizable keyboard
-- you can set it to whatever you like
hs.hotkey.bind({"cmd", "shift", "alt", "ctrl"}, "0", toggleBetweenApps)

-- this is the command that cycles between the apps in the carousel
-- this binding is not practical without a customizable keyboard
-- you can set it to whatever you like
hs.hotkey.bind({"cmd", "shift", "alt", "ctrl"}, "9", cycleNextApp)

print("toggle and carousel functionality registered")
