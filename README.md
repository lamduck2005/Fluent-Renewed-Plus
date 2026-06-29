# Fluent Renewed Plus

![Fluent Renewed Plus Title](Assets/darkmode.png#gh-dark-mode-only)
![Fluent Renewed Plus Title](Assets/darkmode.png#gh-light-mode-only)

## ⚡ Features

- Modern design
- Many customization options
- Almost any UI Element you would ever need
- Built-in key system with 4 service providers (Platoboost, Panda Development, Luarmor, Junkie Development)

## 🔌 Installation

Load Fluent Renewed Plus via `loadstring`:

```lua
local Library = loadstring(game:HttpGet("https://github.com/lamduck2005/Fluent-Renewed-Plus/releases/latest/download/Fluent.luau"))()
```

## 📜 Usage

[Example Script for studio environment](https://github.com/lamduck2005/Fluent-Renewed-Plus/blob/master/Example.client.luau)

[Example Script for exploit environment](https://github.com/lamduck2005/Fluent-Renewed-Plus/blob/master/Example.luau)

Quick test in your executor:
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/lamduck2005/Fluent-Renewed-Plus/master/Example.luau"))()
```

## 📖 Window Configuration

Below are the available options for `Library:Window{}`:

| Option | Type | Default | Description |
|---|---|---|---|
| `Title` | `string?` | Game name | Window title |
| `SubTitle` | `string?` | `"Made with Fluent Renewed Plus"` | Window subtitle |
| `TabWidth` | `number?` | `160` | Width of the tab selector |
| `Size` | `UDim2?` | — | Window size |
| `MinSize` | `Vector2?` | `Vector2.new(470, 380)` | Minimum window size |
| `Resize` | `boolean?` | `false` | Allow window resizing |
| `MinimizeKey` | `Enum.KeyCode?` | `Enum.KeyCode.LeftControl` | Key to toggle minimize |
| `Acrylic` | `boolean?` | `false` | Enable acrylic blur effect |
| `Theme` | `string?` | `"Vynixu"` | UI theme name |
| `Mobile` | `table?` | — | Mobile-specific configuration |
| `MinimizeButton` | `boolean?` | `false` | Show a persistent floating minimize button |
| `MinimizeButtonSize` | `number?` | `50` | Size of the minimize button in pixels |
| `MinimizeButtonIcon` | `string?` | `"bird"` | Icon name for the minimize button (any Lucide/Phosphor icon; falls back to `"bird"` if not found) |
| `Transparency` | `boolean?` | `true` | Enable window transparency effect |
| `KeySystem` | `table?` | — | Key system configuration (omit to skip) |
| `KeyFolder` | `string?` | `"FluentTemp"` | Folder to store saved keys |

### 🔽 MinimizeButton

When enabled, a small floating button is created in a separate ScreenGui that persists even when the main window is hidden. It can be clicked to toggle the window visibility, and dragged to reposition.

```lua
local Window = Library:Window{
    Title = "My Script",
    MinimizeButton = true,
    MinimizeButtonSize = 50, -- optional, defaults to 50
    MinimizeButtonIcon = "scan-eye", -- optional, defaults to "bird"
}
```

The button position is saved per-session and will restore to the last position.

### 🪟 Transparency

Controls the background transparency (frosted glass effect) of the window. Set to `false` for a fully opaque background.

```lua
-- Enable transparency (default)
local Window = Library:Window{
    Title = "My Script",
    Transparency = true,
}

-- Disable transparency for full opacity
local Window = Library:Window{
    Title = "My Script",
    Transparency = false,
}
```

You can also toggle it at runtime:
```lua
Library:ToggleTransparency(true)  -- enable
Library:ToggleTransparency(false) -- disable
```

## 🔑 Key System

Fluent Renewed Plus includes a built-in key system supporting three validation modes and four API service providers.

### KeySystem Options

| Option | Type | Default | Description |
|---|---|---|---|
| `Title` | `string?` | `"Key System"` | Dialog title |
| `Note` | `string?` | — | Description text below the title |
| `SaveKey` | `boolean?` | `false` | Save the validated key to disk for auto-login |
| `Key` | `string \| {string}` | — | Static key(s) — Mode 1 |
| `KeyValidator` | `function` | — | Custom validation function — Mode 2 |
| `API` | `{table}` | — | API service list — Mode 3 |
| `URL` | `string?` | — | Link for the "Get Key" button |
| `Thumbnail` | `table?` | — | Side thumbnail (`Image`, `Width`, `Title`) |

### Mode 1: Static Key

Provide a single key or a list of accepted keys. Users must enter one of them.

```lua
local Window = Library:Window{
    Title = "My Script",
    KeySystem = {
        Title = "Welcome",
        Note = "Enter the password to continue.",
        SaveKey = true,
        Key = "mypassword",
        -- Key = {"key1", "key2"}, -- multiple keys
        Thumbnail = {
            Image = "rbxassetid://8992230677",
            Title = "Premium",
        },
    },
}
```

### Mode 2: Custom Validator

Supply your own validation function that receives the entered key and returns `true` or `false`.

```lua
local Window = Library:Window{
    Title = "My Script",
    KeySystem = {
        Title = "Authentication",
        SaveKey = true,
        KeyValidator = function(key)
            -- Custom logic (e.g. check against a remote server)
            return key == "secret123"
        end,
    },
}
```

### Mode 3: API Services

Validate keys against one or more third-party whitelist services. When multiple services are configured, the key is checked against all of them — the first successful validation wins.

```lua
local Window = Library:Window{
    Title = "My Script",
    KeySystem = {
        Title = "Premium Access",
        Note = "24 hour key, access all features!",
        SaveKey = true,
        URL = "https://discord.gg/example",
        API = {
            { Type = "platoboost", ServiceId = "...", Secret = "..." },
            { Type = "pandadevelopment", ServiceId = "..." },
            { Type = "luarmor", ScriptId = "...", Discord = "discord.gg/..." },
            { Type = "junkiedevelopment", ServiceId = "...", ApiKey = "...", Provider = "..." },
        },
        Thumbnail = {
            Image = "rbxassetid://8992230677",
            Title = "Premium",
        },
    },
}
```

#### Service Provider Reference

| Service | Required Fields | Website |
|---|---|---|
| `platoboost` | `ServiceId`, `Secret` | [platoboost.com](https://platoboost.com) |
| `pandadevelopment` | `ServiceId` | [pandadevelopment.net](https://pandadevelopment.net) |
| `luarmor` | `ScriptId`, `Discord` (optional) | [luarmor.net](https://luarmor.net) |
| `junkiedevelopment` | `ServiceId`, `ApiKey`, `Provider` | Junkie Development |

### SaveKey & KeyFolder

When `SaveKey = true`, the validated key is written to `{KeyFolder}/{UserId}.key` so the user skips the dialog on next launch.

If multiple scripts share the same `KeyFolder` and UserId, **keys will overwrite each other**. To prevent this, set a unique `KeyFolder` per script:

```lua
-- Script A
local Window = Library:Window{
    Title = "Script A",
    KeyFolder = "ScriptA_Keys",
    KeySystem = {
        SaveKey = true,
        Key = "password123",
    },
}

-- Script B
local Window = Library:Window{
    Title = "Script B",
    KeyFolder = "ScriptB_Keys",
    KeySystem = {
        SaveKey = true,
        KeyValidator = function(k) return k == "abc" end,
    },
}
```

> **Default folder**: If `KeyFolder` is not set, keys are stored under `FluentTemp/`.

