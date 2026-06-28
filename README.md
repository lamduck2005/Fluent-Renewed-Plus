# Fluent Renewed

![Fluent Renewed Title](Assets/darkmode.png#gh-dark-mode-only)
![Fluent Renewed Title](Assets/darkmode.png#gh-light-mode-only)

## ⚡ Features

- Modern design
- Many customization options
- Almost any UI Element you would ever need

## 🔌 Installation

You can load Fluent through a GitHub Release:

```lua
local Library = loadstring(game:GetService("HttpService"):GetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau", true))()
```

```lua
local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau", true))()
```

## 📜 Usage

[Example Script the studio environment](https://github.com/ActualMasterOogway/Fluent-Renewed/blob/master/Example.client.luau)

[Example Script for an exploit environment](https://github.com/ActualMasterOogway/Fluent-Renewed/blob/master/Example.luau)

## 📖 Window Configuration

Below are the available options for `Library:Window{}`:

| Option | Type | Default | Description |
|---|---|---|---|
| `Title` | `string?` | Game name | Window title |
| `SubTitle` | `string?` | `"Made with Fluent Renewed"` | Window subtitle |
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

## 🔑 KeySystem

KeySystem is an optional pre-window authentication dialog that blocks the UI until a valid key is entered. Configured via `KeySystem` table in `Library:Window{}`.

### Priority (first matching method wins):

1. **KeyValidator** (custom function) — highest priority
2. **Key** (string/table) — fallback if no KeyValidator and no API
3. **API** services — used if KeyValidator is nil and API is configured
4. **URL only** (no validation) — just shows a "Get key" button that copies the URL

If `SaveKey` is enabled, validated keys are saved to `(Folder)/{hwid}.key` and auto-loaded on next launch. If the saved key fails validation, it is deleted and the dialog reopens.

### Configuration

| Option | Type | Default | Description |
|---|---|---|---|
| `Title` | `string?` | `Config.Title` | Dialog title |
| `Note` | `string?` | — | Note text displayed below the title |
| `Key` | `string \| {string}?` | — | Valid key or table of valid keys |
| `KeyValidator` | `(key: string) -> boolean?` | — | Custom validation function |
| `SaveKey` | `boolean?` | `false` | Save validated key to file |
| `URL` | `string?` | — | URL copied to clipboard on "Get key" click |
| `Thumbnail` | `table?` | — | Side thumbnail image config (see below) |
| `API` | `{APIConfig}?` | — | Array of API service configs (see below) |
| `Folder` | `string?` | `"Temp"` | Folder name for saved key files |

### Thumbnail

```lua
Thumbnail = {
    Image = "rbxassetid://...",  -- Required: thumbnail image
    Title = "Premium Access",    -- Optional: overlay title text
    Width = 200                  -- Optional: width in px (default 200)
}
```

When set, the thumbnail appears on the left side of the dialog. The dialog width increases by half the thumbnail width. The Exit button moves to the bottom-left of the thumbnail.

### API Services

Port of WindUI's key service wrappers (`Src/Modules/KeyServices.luau`). Each service has a `Copy()` function that copies the key link to clipboard and a `Verify()` function used for key validation (in executor environments only — not available in Studio).

| Service Type | Required Fields | Description |
|---|---|---|
| `"platoboost"` | `ServiceId` (number), `Secret` (string) | Platoboost API |
| `"pandadevelopment"` | `ServiceId` (string) | Panda Development API |
| `"junkiedevelopment"` | `ServiceId`, `ApiKey`, `Provider` | Junkie Development (requires `JunkieProtected`) |
| `"luarmor"` | `ScriptId`, `Discord` (string?) | Luarmor API (requires `API`) |

Each API config can also include:
- `Title` (string) — display name in the dropdown (defaults to service name)
- `Icon` (string) — custom icon (defaults to service icon)
- `Desc` (string) — description shown in the dropdown

### Validation modes

**1. KeyValidator (custom function):**
```lua
KeySystem = {
    KeyValidator = function(key)
        -- Custom logic, e.g. hash comparison
        return key == "your-key-here"
    end,
    SaveKey = true,
}
```

**2. Static Key (string or table):**
```lua
KeySystem = {
    Key = "your-key-here",       -- single key
    -- or
    Key = {"key-1", "key-2"},    -- multiple valid keys
    SaveKey = true,
}
```

**3. API services (external validation):**
```lua
KeySystem = {
    API = {
        {
            Type = "platoboost",
            ServiceId = 12345,
            Secret = "your-secret-here",
        },
        {
            Type = "pandadevelopment",
            ServiceId = "your-service-id",
    },
    SaveKey = true,
}
```

### Full example

```lua
local Window = Library:Window{
    Title = "My Script",
    KeySystem = {
        Title = "Key System",
        Note = "Get your key at discord.gg/example",
        SaveKey = true,
        Key = {"your-key-here"},
        Thumbnail = {
            Image = "rbxassetid://9886659671",
            Title = "Premium Access",
            Width = 200,
        },
        API = {
            {
                Type = "platoboost",
                ServiceId = 12345,
                Secret = "your-secret-here",
            },
        },
    },
}
```

### Files

| File | Description |
|---|---|
| `Src/Modules/KeySystem.luau` | Dialog UI + validation logic |
| `Src/Modules/KeyServices.luau` | API service wrappers (Platoboost, Panda, Junkie, Luarmor) |
| `Src/init.luau` | Integration: blocking loop, save/load, 3 validation branches |

## Credits

- [Master Oogway](https://github.com/ActualMasterOogway/Fluent-Renewed) - The master mind behind Fluent Renewed
- [dawid](https://github.com/dawid-scripts/Fluent) - The master mind behind Fluent
- [Lucide](https://github.com/lucide-icons), [Phosphor](https://github.com/phosphor-icons) - The sexy icons
- [richie0866/remote-spy](https://github.com/richie0866/remote-spy) - Assets for the UI, some of the code
- [violin-suzutsuki/LinoriaLib](https://github.com/violin-suzutsuki/LinoriaLib) - Code for most of the elements, save manager
- [7kayoh/Acrylic](https://github.com/7kayoh/Acrylic) - Porting richie0866's acrylic module to lua
- [Latte Softworks & Kotera](https://github.com/latte-soft/wax/) - Bundler
- [Pepsied-5229/Pepsi-UI-Library](https://github.com/Pepsied-5229/Pepsi-UI-Library) - Inspiration for new features, some of the code
