# Hammerspoon App Toggle & Carousel

A powerful script for macOS that provides Windows-style Alt+Tab functionality and a customizable app carousel.

## Features

### App Toggle
- Instantly switch between your two most recently used applications
- Works like Windows Alt+Tab but can be bound to any key combination
- Properly brings applications to focus for immediate keyboard interaction

### App Carousel
- Cycle through a predefined list of applications
- Only switches between apps that are already running
- Perfect for workflows that use the same set of applications

## Installation

1. Install [Hammerspoon](https://www.hammerspoon.org/) if you don't have it already
2. Copy the script to your Hammerspoon configuration directory:
   ```bash
   # Create the config directory if it doesn't exist
   mkdir -p ~/.hammerspoon/
   
   # Add this script to your init.lua file
   ```
3. Either replace your existing `~/.hammerspoon/init.lua` with this script or add the contents to your existing config
4. Reload your Hammerspoon configuration

## Configuration

### Customizing Key Bindings

The default key bindings are:
- **App Toggle**: `cmd+shift+alt+ctrl+0` - Toggles between your two most recently used apps
- **App Carousel**: `cmd+shift+alt+ctrl+9` - Cycles through your customized list of running apps

To change these bindings, edit these lines in the script:

```lua
-- For toggle function
hs.hotkey.bind({"cmd", "shift", "alt", "ctrl"}, "0", toggleBetweenApps)

-- For carousel function
hs.hotkey.bind({"cmd", "shift", "alt", "ctrl"}, "9", cycleNextApp)
```

### Customizing the App Carousel

Edit the `carouselApps` table to include the applications you want in your rotation:

```lua
local carouselApps = {
    "Google Chrome",
    "iTerm2",
    "Simulator", 
    "Xcode"
    -- Add or remove apps as needed
}
```

Note: The app names must match the official application names exactly.

## Using with a Programmable Keyboard

If you have a programmable keyboard like a Moonlander:

1. Configure a key on your keyboard to send the key combinations you've defined in Hammerspoon
2. For a single key solution, map a key to send:
   - `cmd+shift+alt+ctrl+0` for app toggling
   - `cmd+shift+alt+ctrl+9` for app carousel

Alternative: Map an unused function key (like F19) and update the script to use that key instead.

## Troubleshooting

If applications aren't focusing properly:
- Make sure Hammerspoon has accessibility permissions in System Preferences > Security & Privacy > Privacy > Accessibility
- Check your console logs by opening Hammerspoon Console from the menu bar icon

## How It Works

The script uses an application watcher to track which applications you use. The toggle function records the last two applications you've used and allows you to switch between them with a single keystroke. The carousel function checks which of your preferred applications are running and cycles through them in sequence.

## License

This script is provided free for anyone to use and modify.
