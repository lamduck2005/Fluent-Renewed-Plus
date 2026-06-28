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

## Credits

- [Master Oogway](https://github.com/ActualMasterOogway/Fluent-Renewed) - The master mind behind Fluent Renewed
- [dawid](https://github.com/dawid-scripts/Fluent) - The master mind behind Fluent
- [Lucide](https://github.com/lucide-icons), [Phosphor](https://github.com/phosphor-icons) - The sexy icons
- [richie0866/remote-spy](https://github.com/richie0866/remote-spy) - Assets for the UI, some of the code
- [violin-suzutsuki/LinoriaLib](https://github.com/violin-suzutsuki/LinoriaLib) - Code for most of the elements, save manager
- [7kayoh/Acrylic](https://github.com/7kayoh/Acrylic) - Porting richie0866's acrylic module to lua
- [Latte Softworks & Kotera](https://github.com/latte-soft/wax/) - Bundler
- [Pepsied-5229/Pepsi-UI-Library](https://github.com/Pepsied-5229/Pepsi-UI-Library) - Inspiration for new features, some of the code
