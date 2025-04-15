-- App Carousel Script for specific applications
-- Keeps the previous toggle functionality and adds a carousel mode

-- Toggle functionality
local appHistory = {}
local historyLimit = 10  -- last 10 apps
local isManualSwitch = false  -- flag to track if manually switching apps

-- Carousel functionality - define your preferred apps here
local carouselApps = {
    "Google Chrome",
    "iTerm2",
    "Simulator", 
    "Xcode"
}
local currentCarouselIndex = 1

-- Function to update application history when focus changes
local function applicationWatcher(appName, eventType)
    if eventType == hs.application.watcher.activated then
        -- Only update history if this wasn't triggered by our own switcher
        -- or if it was but we've now reset the flag
        if not isManualSwitch then
            -- Remove the app from history if it's already there
            for i, existingApp in ipairs(appHistory) do
                if existingApp == appName then
                    table.remove(appHistory, i)
                    break
                end
            end
            -- Add the app to the front of history
            table.insert(appHistory, 1, appName)
            -- Trim history if it's too long
            if #appHistory > historyLimit then
                table.remove(appHistory)
            end
            -- Debug: Print the current history
            print("App history updated:")
            for i, app in ipairs(appHistory) do
                print(i .. ": " .. app)
            end

            -- Update currentCarouselIndex if current app is in carousel
            for i, app in ipairs(carouselApps) do
                if app == appName then
                    currentCarouselIndex = i
                    break
                end
            end
        else
            -- Reset the flag for next time
            isManualSwitch = false
        end
    end
end

-- Start the application watcher
local appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()

-- Function to toggle between the two most recent applications
local function toggleBetweenApps()
    if #appHistory >= 2 then
        local currentApp = appHistory[1]
        local targetApp = appHistory[2]
        -- Swap the top two apps in our history to reflect the change
        appHistory[1] = targetApp
        appHistory[2] = currentApp
        print("Toggling from: " .. currentApp .. " to: " .. targetApp)
        -- Set the flag so we don't double-update history
        isManualSwitch = true
        -- Get the actual application object instead of just using the name
        local app = hs.application.get(targetApp)
        if app then
            -- Activate the app and bring it to front
            app:activate(true)
        else
            -- Fallback to launchOrFocus if we couldn't get the app object
            hs.application.launchOrFocus(targetApp)
        end
    else
        print("Need at least 2 apps in history to toggle")
    end
end

-- Function to cycle through the carousel of selected apps
local function cycleNextApp()
    -- Get list of running applications that match our carousel
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
    
    -- If no carousel apps are running, do nothing
    if #runningCarouselApps == 0 then
        print("No carousel apps are currently running")
        return
    end
    
    -- Find current app in the running carousel apps
    local currentAppName = hs.application.frontmostApplication():name()
    local currentIndex = 0
    
    for i, app in ipairs(runningCarouselApps) do
        if app == currentAppName then
            currentIndex = i
            break
        end
    end
    
    -- Determine next app (if current app isn't in carousel, start at the beginning)
    local nextIndex = currentIndex + 1
    if nextIndex > #runningCarouselApps or currentIndex == 0 then
        nextIndex = 1
    end
    
    local targetApp = runningCarouselApps[nextIndex]
    print("Cycling to: " .. targetApp)
    
    -- Set the flag so we don't double-update history
    isManualSwitch = true
    
    -- Get the actual application object and activate it
    local app = hs.application.get(targetApp)
    if app then
        app:activate(true)
    end
end

-- Keep the toggle functionality on cmd+shift+alt+ctrl+0
hs.hotkey.bind({"cmd", "shift", "alt", "ctrl"}, "0", toggleBetweenApps)

-- Add carousel functionality on a different key combination (cmd+shift+alt+ctrl+9)
hs.hotkey.bind({"cmd", "shift", "alt", "ctrl"}, "9", cycleNextApp)

print("Toggle and Carousel functionality registered!")
