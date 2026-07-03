# Fluent Renewed Plus

Fluent Renewed Plus is a modern, customizable Roblox GUI library with an extensive range of UI elements, 61 themes, over 10,000 icons, a built-in key system, acrylic blur effects, and powerful addons for configuration management and utility features.

## Features

- Modern design with smooth spring animations
- 8 UI element types: Button, Toggle, Slider, Dropdown, Colorpicker, Keybind, Input, Paragraph
- 61 built-in themes
- Over 10,000 icons (Lucide 0.469.0 + Phosphor 2.1.0)
- Acrylic frosted glass blur effect
- Glass transparency mode
- Floating minimize button (draggable, customizable)
- Window resizing
- Built-in key system with 3 validation modes and 4 API services
- Notification system with buttons and sounds
- Dialog system
- Addons: SaveManager, InterfaceManager, ExtraSetting
- Mobile support
- Strict Luau types

## Differences From Original Fluent

- 61 themes instead of 6 (default: Vynixu)
- Key system with 3 modes: static key, custom validator, API services (Platoboost, PandaDevelopment, Luarmor, JunkieDevelopment)
- Floating minimize button with drag support and customizable icon/size
- Window resizing option
- Glass transparency option
- Mobile configuration support
- ExtraSetting addon: AFK mode, FPS overlay/boost, anti-AFK, auto rejoin
- Over 10,000 icons (original: ~900)
- Dropdown: searchable, multi-select with any value type, AllowNull, AutoDeselect
- Colorpicker: UpdateOnChange for live preview
- Input: MaxLength, ClearOnFocusLost
- Toggle: embedded Keybind inside toggle row
- Paragraph: TitleAlignment, ContentAlignment
- Acrylic: uses DepthOfFieldEffect (more reliable)
- Lune build system for compilation and publishing

---

# Installation

## Loadstring (Executor)

```lua
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
```

## Wally (Roblox Studio)

```toml
[dependencies]
Fluent = "dawid-scripts/fluent@1.0.5"
```

---

# Quick Start

```lua
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "My Script",
    SubTitle = "by me",
    TabWidth = 160,
    Size = UDim2.fromOffset(470, 380),
    Acrylic = false,
    Theme = "Vynixu",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

Tabs.Main:AddButton({
    Title = "Hello",
    Description = "Click me",
    Callback = function()
        print("Hello, world!")
    end
})

Window:SelectTab(1)
```

---

# Creating Window

```lua
local Window = Fluent:CreateWindow(Config)
```

`Fluent:CreateWindow()` / `Fluent:Window()` / `Fluent:AddWindow()` can only be called once.

## Window Config

| Option | Type | Default | Description |
|---|---|---|---|
| Title | string? | Game name | Window title text |
| SubTitle | string? | "Made with Fluent Renewed Plus" | Subtitle below title |
| TabWidth | number? | 160 | Width of the tab selector panel |
| Size | UDim2? | UDim2.fromOffset(470, 300) | Initial window size |
| MinSize | Vector2? | Vector2.new(470, 300) | Minimum window size (when resizable) |
| Resize | boolean? | false | Enable window resizing via bottom-right handle |
| MinimizeKey | Enum.KeyCode? | RightControl | Key to toggle minimize |
| Acrylic | boolean? | false | Enable acrylic blur effect (DepthOfField) |
| Theme | string? | "Vynixu" | Initial theme name |
| Mobile | table? | -- | Mobile-specific configuration |
| HideButton | boolean? | nil | Show hide button. `nil` = auto (mobile only), `true` = always, `false` = hidden |
| Transparency | boolean? | false | Enable glass transparency effect |
| KeySystem | table? | -- | Key system config (omit to skip) |
| KeyFolder | string? | "FluentTemp" | Folder for saved key files |

### Mobile Config

| Option | Type | Description |
|---|---|---|
| GetIcon | function | Function returning icon image data |
| Size | number | Icon size |

## Key System Config

Include a `KeySystem` table in the Window config to enable key validation.

| Option | Type | Description |
|---|---|---|
| Title | string? | Dialog title (default: "Key System") |
| Note | string? | Description text below the title |
| SaveKey | boolean? | Save validated key to disk |
| Key | string or {string}? | Static key(s) for validation (Mode 1) |
| KeyValidator | function? | Custom validation function(key) (Mode 2) |
| API | {table}? | List of API service configs (Mode 3) |
| URL | string? | "Get Key" button link |
| Thumbnail | table? | Side image: {Image, Width?, Title?} |

### API Service Config

Each entry in the `API` table:

| Service | Args |
|---|---|
| platoboost | {ServiceId, Secret} |
| pandadevelopment | {ServiceId} |
| luarmor | {ScriptId, Discord?} |
| junkiedevelopment | {ServiceId, ApiKey, Provider} |

### Key System Example

```lua
local Window = Fluent:CreateWindow({
    Title = "My Script",
    KeySystem = {
        Key = {"key1", "key2"},
        URL = "https://discord.gg/example",
        SaveKey = true,
        Thumbnail = {
            Image = "rbxassetid://1234567890",
            Title = "My Script"
        }
    }
})
```

---

# Library API

## Properties

| Property | Type | Description |
|---|---|---|
| Version | string | Library version ("1.0.5") |
| Options | table | All created options/elements indexed by ID |
| Themes | {string} | List of available theme names |
| CreatedWindow | table or nil | The created Window object |
| UIContainer | Instance | Parent container (CoreGui / PlayerGui) |
| Utilities | table | Helper functions (Resize, Truncate, GetIcon, etc.) |
| Connections | {RBXScriptSignal} | All active signal connections |
| Unloaded | boolean | Whether the library was destroyed |
| Loaded | boolean | Inverse of Unloaded |
| Theme | string | Current theme name |
| DialogOpen | boolean | Whether a dialog is currently open |
| UseAcrylic | boolean | Was acrylic enabled at window creation |
| Acrylic | boolean | Is acrylic currently active |
| Transparency | boolean | Is glass transparency active |
| MinimizeKey | Enum.KeyCode | Key to toggle minimize |
| GUI | ScreenGui | The root ScreenGui instance |
| OnUnload | Signal | Fired when the library is being destroyed |
| PostUnload | Signal | Fired after the destroy animation completes |
| ThemeChanged | Signal | Fired when the theme changes |

## Methods

| Method | Arguments | Description |
|---|---|---|
| CreateWindow(Config) | Config: table | Create the main window |
| Window(Config) | Config: table | Alias for CreateWindow |
| AddWindow(Config) | Config: table | Alias for CreateWindow |
| SetTheme(Name) | Name: string | Set the UI theme |
| Destroy() | -- | Destroy the library with fade-out animation |
| ToggleAcrylic(Value) | Value: boolean | Enable or disable acrylic blur |
| ToggleTransparency(Value) | Value: boolean | Enable or disable glass transparency |
| Notify(Config) | Config: table | Create a notification (returns object) |
| SafeCallback(Function, ...) | fn, ...any | Execute callback with pcall error handling |

## Utilities

| Method | Signature | Description |
|---|---|---|
| Resize(X, Y) | (number, number) -> (number, number) | Scale coordinates from 1920x1080 reference |
| Truncate(n, d, r) | (number, number?, boolean?) -> number | Truncate or round decimals |
| Round(n, f) | (number, number?) -> number | Round to decimal places |
| GetIcon(Name) | (string) -> {Image, ImageRectSize, ImageRectOffset} | Get icon image data by name |
| Prettify(v) | (EnumItem or string or number) -> string or number | Format enums/values nicely |
| Clone(v) | (any) -> (any, boolean) | Deep clone tables, instances, or functions |
| GetOS() | () -> string | Detect OS: Windows, macOS, Mobile, Xbox, PlayStation, MetaHorizon |

---

# Tabs and Sections

## Creating Tabs

```lua
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}
```

Tab config:

| Option | Type | Description |
|---|---|---|
| Title | string | Tab display name |
| Icon | string? | Icon name (Lucide or Phosphor) |

## Selecting Tabs

```lua
Window:SelectTab(1)       -- by index (1-based)
Window:SelectTab(Tabs.Main)   -- by tab object
```

## Creating Sections

Sections group related elements under a header.

```lua
local Section = Tabs.Main:AddSection("Section Name")

-- Elements can be created directly on a section:
Section:AddButton({
    Title = "Button in Section",
    Callback = function() end
})
```

---

# Elements

All elements are created via `Tab:AddElementName("Id", Config)` or `Section:AddElementName("Id", Config)`.

The `Id` string is used to access the element later via `Fluent.Options["Id"]`.

## Button

A clickable button with a chevron icon.

```lua
local Button = Tabs.Main:AddButton("MyButton", {
    Title = "Click Me",
    Description = "This button does something",
    Callback = function()
        print("Button clicked!")
    end
})
```

| Option | Type | Description |
|---|---|---|
| Title | string | Button label |
| Description | string? | Description text |
| Callback | function | Fired on click |

## Toggle

A toggle switch for boolean values.

```lua
local Toggle = Tabs.Main:AddToggle("MyToggle", {
    Title = "Toggle",
    Description = "Toggle description",
    Default = false,
    Callback = function(state)
        if state then
            print("Toggle On")
        else
            print("Toggle Off")
        end
    end
})
```

| Option | Type | Default | Description |
|---|---|---|---|
| Title | string | -- | Toggle label |
| Description | string? | -- | Description text |
| Default | boolean? | false | Initial state |
| Callback | function(boolean)? | -- | Fired on state change |

### Methods

```lua
Toggle:SetValue(true)          -- Set state
Toggle:OnChanged(function()    -- Listen for changes
    print("Value:", Toggle.Value)
end)
```

### Embedded Keybind

A keybind picker can be embedded inside a toggle row:

```lua
local ToggleKeybind = Toggle:Keybind("ToggleKeybind", {
    Title = "Keybind",
    Mode = "Toggle",
    Default = "LeftControl",
    Callback = function(value)
        print("Keybind state:", value)
    end
})
```

## Slider

A draggable slider with editable numeric input.

```lua
local Slider = Tabs.Main:AddSlider("MySlider", {
    Title = "Slider",
    Description = "This is a slider",
    Default = 2,
    Min = 0,
    Max = 5,
    Rounding = 1,
    Callback = function(Value)
        print("Slider changed:", Value)
    end
})
```

| Option | Type | Default | Description |
|---|---|---|---|
| Title | string | -- | Slider label |
| Description | string? | -- | Description text |
| Default | number? | 0 | Initial value |
| Min | number? | 0 | Minimum value |
| Max | number? | 100 | Maximum value |
| Rounding | number? | 1 | Decimal places to round to |
| Callback | function(number)? | -- | Fired on value change |

### Methods

```lua
Slider:SetValue(3)              -- Set value (clamped and rounded)
Slider:OnChanged(function(v)    -- Listen for changes
    print("Value:", v)
end)
```

## Dropdown

Single or multi-select dropdown with searchable options.

```lua
local Dropdown = Tabs.Main:AddDropdown("MyDropdown", {
    Title = "Dropdown",
    Description = "Select an option",
    Values = {"one", "two", "three"},
    Multi = false,
    Default = 1,
    Searchable = false,
})
```

| Option | Type | Default | Description |
|---|---|---|---|
| Title | string | -- | Dropdown label |
| Description | string? | -- | Description text |
| Values | {any}? | {} | List of options (any type: strings, instances, enums, numbers) |
| Multi | boolean? | false | Allow selecting multiple values |
| Default | any or {any: boolean}? | nil | Initial selection |
| Searchable | boolean? | false | Show search filter input |
| FocusSearch | boolean? | false | Auto-focus search when opening |
| SearchPlaceholder | string? | "Search..." | Placeholder text for search |
| Displayer | function(any)? | -- | Custom display function for values |
| AutoDeselect | boolean? | true | Deselect current value when clicking it again |
| AllowNull | boolean? | false | Prevent deselecting the last value |
| Callback | function(any)? | -- | Fired on selection change |

### Methods

```lua
Dropdown:SetValue("four")                           -- Single: set value
Dropdown:SetValue({three = true, five = true})     -- Multi: set values (table map)
Dropdown:SetValues({"a", "b", "c"})                -- Replace all options
Dropdown:Open()                                     -- Open dropdown list
Dropdown:Close()                                    -- Close dropdown list
Dropdown:Display()                                  -- Update display text
Dropdown:GetActiveValues()                          -- Get currently selected values
Dropdown:OnChanged(function(v)                      -- Listen for changes
    print("Value:", v)
end)
```

### Multi-Select Example

```lua
local MultiDropdown = Tabs.Main:AddDropdown("MultiDropdown", {
    Title = "Multi Dropdown",
    Values = {"one", "two", "three", "four"},
    Multi = true,
    Default = {"seven", "twelve"},
})

MultiDropdown:OnChanged(function(Value)
    local Values = {}
    for Value, State in next, Value do
        table.insert(Values, Value)
    end
    print("Selected:", table.concat(Values, ", "))
end)
```

## Colorpicker

A color picker with HSV map, hue slider, hex/RGB input, and optional transparency.

```lua
local Colorpicker = Tabs.Main:AddColorpicker("MyColorpicker", {
    Title = "Colorpicker",
    Description = "Pick a color",
    Default = Color3.fromRGB(96, 205, 255),
    Transparency = 0,
    UpdateOnChange = false,
    Callback = function()
        print("Color changed:", Colorpicker.Value)
    end
})
```

| Option | Type | Default | Description |
|---|---|---|---|
| Title | string | -- | Colorpicker label |
| Description | string? | -- | Description text |
| Default | Color3? | Color3.new(1, 1, 1) | Initial color |
| Transparency | number? | nil | Initial transparency (0-1), shows alpha slider if set |
| UpdateOnChange | boolean? | false | Fire callback while sliding (live preview) |
| Callback | function()? | -- | Fired on color change |

### Methods

```lua
Colorpicker:SetValueRGB(Color3.fromRGB(0, 255, 140))        -- Set from RGB
Colorpicker:SetValue({Hue, Sat, Vib}, Transparency?)   -- Set from HSV
Colorpicker:OnChanged(function()                          -- Listen for changes
    print("Color:", Colorpicker.Value)
end)
```

## Keybind

A keybind picker with Always/Toggle/Hold modes.

```lua
local Keybind = Tabs.Main:AddKeybind("MyKeybind", {
    Title = "Keybind",
    Description = "Keybind Description",
    Mode = "Toggle",   -- "Always", "Toggle", or "Hold"
    Default = "LeftControl",
    Callback = function(Value)
        print("Keybind clicked!", Value)
    end,
    ChangedCallback = function(New)
        print("Keybind changed to:", New)
    end
})
```

| Option | Type | Default | Description |
|---|---|---|---|
| Title | string | -- | Keybind label |
| Description | string? | -- | Description text |
| Mode | string? | "Toggle" | "Always": always active, "Toggle": click to toggle, "Hold": active while held |
| Default | string? | "" | Default key (e.g. "LeftControl", "MB1", "MB2") |
| Callback | function(boolean)? | -- | Fired when keybind is pressed/released |
| ChangedCallback | function(KeyCode or UserInputType)? | -- | Fired when the bound key changes |

### Methods

```lua
Keybind:GetState()                          -- Check if keybind is currently active
Keybind:SetValue("MB2", "Toggle")          -- Set key and mode
Keybind:DoClick()                           -- Manually trigger the keybind
Keybind:OnClick(function()                  -- Listen for click events
    print("Clicked, state:", Keybind:GetState())
end)
Keybind:OnChanged(function()                -- Listen for key/mode changes
    print("Changed:", Keybind.Value)
end)
```

### State Checking Loop

```lua
task.spawn(function()
    while task.wait() do
        if Keybind:GetState() then
            print("Keybind is being held down")
        end
        if Fluent.Unloaded then break end
    end
end)
```

## Input

A text input field with validation options.

```lua
local Input = Tabs.Main:AddInput("MyInput", {
    Title = "Input",
    Description = "Enter text",
    Default = "Default",
    Placeholder = "Type here...",
    Numeric = false,
    Finished = false,
    MaxLength = 100,
    ClearOnFocusLost = false,
    Callback = function(Value)
        print("Input changed:", Value)
    end
})
```

| Option | Type | Default | Description |
|---|---|---|---|
| Title | string | -- | Input label |
| Description | string? | -- | Description text |
| Default | string? | "" | Initial text |
| Placeholder | string? | "" | Placeholder text |
| Numeric | boolean? | false | Only allow numeric input |
| Finished | boolean? | false | Only fire callback on Enter press |
| MaxLength | number? | -- | Maximum character count |
| ClearOnFocusLost | boolean? | false | Clear text on focus lost (only when Finished is true) |
| Callback | function(string)? | -- | Fired on value change |

### Methods

```lua
Input:SetValue("New text")     -- Set text
Input:OnChanged(function()     -- Listen for changes
    print("Value:", Input.Value)
end)
```

## Paragraph

A static text display element (not interactive).

```lua
local Paragraph = Tabs.Main:AddParagraph("MyParagraph", {
    Title = "Paragraph",
    Content = "This is a paragraph.\nSecond line!",
    TitleAlignment = "Left",
    ContentAlignment = "Left"
})
```

| Option | Type | Default | Description |
|---|---|---|---|
| Title | string | -- | Paragraph title |
| Content | string? | "" | Main text content |
| TitleAlignment | string or Enum? | "Left" | "Left", "Center", "Middle", or TextXAlignment |
| ContentAlignment | string or Enum? | "Left" | "Left", "Center", "Middle", or TextXAlignment |
| Callback | function()? | -- | Optional callback (not commonly used) |

### Methods

```lua
Paragraph:SetValue("New content")     -- Update content
Paragraph:SetContent("New content")   -- Update content (alias)
Paragraph:OnChanged(function()         -- Listen for changes
    print("Content changed")
end)
```

---

# Notifications

Notifications appear in the bottom-right corner with a frosted glass background.

```lua
local Notification = Fluent:Notify({
    Title = "Notification",
    Content = "This is the main text",
    SubContent = "Optional extra text",
    Duration = 5,               -- seconds, nil = persistent
    Buttons = {                 -- optional action buttons
        {
            Title = "OK",
            Callback = function()
                print("OK clicked")
            end
        }
    },
    Sound = {                   -- optional sound
        SoundId = "rbxassetid://123456789"
    }
})

-- Notification object properties
print(Notification.Closed)   -- boolean, becomes true when closed
```

| Option | Type | Description |
|---|---|---|
| Title | string | Notification title |
| Content | string | Main text |
| SubContent | string? | Secondary text |
| Duration | number? | Auto-close after N seconds (nil = persistent) |
| Buttons | {Button}? | Array of {Title, Callback} |
| Sound | table? | Sound config: {SoundId = "rbxassetid://..."} |

---

# Dialogs

Modal dialogs with customizable buttons.

```lua
Window:Dialog({
    Title = "Confirm",
    Content = "Are you sure?",
    Buttons = {
        {
            Title = "Yes",
            Callback = function()
                print("Confirmed")
            end
        },
        {
            Title = "No",
            Callback = function()
                print("Cancelled")
            end
        }
    }
})
```

| Option | Type | Description |
|---|---|---|
| Title | string | Dialog title |
| Content | string | Dialog body text |
| Buttons | {Button} | Array of {Title, Callback} |

---

# Themes

Fluent Renewed Plus comes with 61 built-in themes.

## Setting a Theme

```lua
Fluent:SetTheme("Dark")           -- Set at runtime

-- Or set in the Window config:
Fluent:CreateWindow({ Theme = "Vynixu" })
```

## Available Themes

- Vynixu (default)
- Dark
- Darker
- Light
- Quiet Light
- Aqua
- Tomorrow Night Blue
- Abyss
- Amethyst
- Amethyst Dark
- Rose
- Yaru
- United Ubuntu
- Elementary
- Yaru Dark
- United GNOME
- Arc Dark
- Ambiance
- Adapta Nokto
- Monokai
- Monokai Classic
- Monokai Vibrant
- Monokai Dimmed
- Typewriter
- Dark Typewriter
- Kimbie Dark
- Solarized Dark
- Solarized Light
- DuoTone Dark Sea
- DuoTone Dark Sky
- DuoTone Dark Space
- DuoTone Dark Forest
- DuoTone Dark Earth
- VSC Dark+
- VSC Dark Modern
- VSC Dark High Contrast
- VSC Light+
- VSC Light Modern
- VSC Light High Contrast
- VSC Red
- VS Dark
- VS Light
- GitHub Dark
- GitHub Dark Dimmed
- GitHub Dark Default
- GitHub Dark High Contrast
- GitHub Dark Colorblind
- GitHub Light
- GitHub Light Default
- GitHub Light High Contrast
- GitHub Light Colorblind
- Viow Arabian
- Viow Arabian Mix
- Viow Darker
- Viow Flat
- Viow Light
- Viow Mars
- Viow Neon

## Custom Themes

A theme file returns a table of color properties:

```lua
return {
    Accent = Color3.fromRGB(96, 205, 255),
    AcrylicMain = Color3.fromRGB(60, 60, 60),
    AcrylicBorder = Color3.fromRGB(90, 90, 90),
    AcrylicGradient = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
    }),
    AcrylicNoise = 0.9,
    TitleBarLine = Color3.fromRGB(30, 30, 30),
    Tab = Color3.fromRGB(35, 35, 35),
    Element = Color3.fromRGB(30, 30, 30),
    ElementBorder = Color3.fromRGB(45, 45, 45),
    InElementBorder = Color3.fromRGB(40, 40, 40),
    ElementTransparency = 0,
    Text = Color3.fromRGB(230, 230, 230),
    SubText = Color3.fromRGB(160, 160, 160),
    -- Optional (falls back to Dark theme defaults):
    ToggleToggled = ...,
    SliderRail = ...,
    Keybind = ...,
    Input = ..., InputFocused = ..., InputIndicator = ...,
    Dialog = ..., DialogHolder = ..., DialogHolderLine = ...,
    DialogButton = ..., DialogButtonBorder = ...,
    DialogBorder = ..., DialogInput = ..., DialogInputLine = ...,
    DropdownFrame = ..., DropdownHolder = ...,
    DropdownBorder = ..., DropdownOption = ...,
    Hover = ..., HoverChange = ...
}
```

---

# Icons

Fluent Renewed Plus includes icons from two icon sets:

- Lucide 0.469.0 (1,544 icons)
- Phosphor 2.1.0 (9,072 icons)

Total: approximately 10,616 icons.

## Usage

```lua
local IconData = Fluent.Utilities:GetIcon("home")
-- Returns: {Image = "rbxassetid://...", ImageRectSize = Vector2.new(...), ImageRectOffset = Vector2.new(...)}

-- Use in tabs:
Window:AddTab({ Title = "Main", Icon = "home" })
```

Browse available icons at https://lucide.dev/icons/ (Lucide) and https://phosphoricons.com/ (Phosphor).

Icon names are in kebab-case (e.g. `"arrow-right"`, `"settings"`, `"user-circle"`).

---

# Addons

## SaveManager

SaveManager handles saving and loading UI element states (Toggle, Slider, Dropdown, Colorpicker, Keybind, Input) to JSON files.

### Loading

```lua
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
```

### Setup

```lua
SaveManager:SetLibrary(Fluent)
SaveManager:SetFolder("MyScript/settings")     -- folder path for configs
SaveManager:IgnoreThemeSettings()               -- skip ThemeManager indexes
SaveManager:SetIgnoreIndexes({"UnwantedToggle"}) -- skip specific options
```

### Methods

| Method | Arguments | Description |
|---|---|---|
| SetLibrary(lib) | table | Link the library (required) |
| SetFolder(path) | string | Set config storage folder |
| SetIgnoreIndexes(list) | {string} | Skip specific option IDs |
| IgnoreThemeSettings() | -- | Convenience: ignores InterfaceManager indexes |
| Save(name) | string | Save current options to {name}.json |
| Load(name) | string | Load options from {name}.json |
| Delete(name) | string | Delete a config file (also clears autoload) |
| RefreshConfigList() | -> {string} | List available config names |
| LoadAutoloadConfig() | -- | Load the autoload config if set |
| BuildFolderTree() | -- | Create folder structure |
| BuildConfigSection(tab) | Tab | Build config management UI |

### UI Section

When `BuildConfigSection()` is called, the following UI elements are created:

- **Config Name input** (`SaveManager_ConfigName`) -- name for new config
- **Config List dropdown** (`SaveManager_ConfigList`) -- select existing config
- **Create Config button** -- saves new config (notifies overwrite if exists)
- **Load Config button** -- loads selected config
- **Delete Config button** -- deletes selected config (clears autoload if applicable)
- **Refresh List button** -- refreshes config dropdown
- **Set as Autoload button** -- marks config for auto-load

```lua
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()  -- load autoload at startup
```

## InterfaceManager

InterfaceManager persists interface settings (theme, acrylic, transparency, minimize keybind).

### Loading

```lua
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
```

### Setup

```lua
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("MyScript")
```

### Methods

| Method | Arguments | Description |
|---|---|---|
| SetLibrary(lib) | table | Link the library (required) |
| SetFolder(path) | string | Set storage folder |
| SaveSettings() | -- | Save current settings to {folder}/options.json |
| LoadSettings() | -- | Load settings from {folder}/options.json |
| BuildFolderTree() | -- | Create folder structure |
| BuildInterfaceSection(tab) | Tab | Build interface settings UI |

### Generated UI Elements

- **Theme dropdown** (`InterfaceManager_InterfaceTheme`) -- select theme
- **Acrylic toggle** (`InterfaceManager_AcrylicToggle`, only if `Library.UseAcrylic`)
- **Transparency toggle** (`InterfaceManager_TransparentToggle`)
- **Menu keybind** (`InterfaceManager_MenuKeybind`) -- sets `Library.MinimizeKeybind`

```lua
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
InterfaceManager:LoadSettings()   -- load saved settings at startup
```

## ExtraSetting

ExtraSetting provides utility toggles for AFK mode, FPS boost, anti-AFK, auto rejoin, and more.

### Loading

```lua
local ExtraSetting = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/ExtraSetting.lua"))()
```

### Setup

```lua
ExtraSetting:SetLibrary(Fluent)
ExtraSetting:SetFolder("MyScript")
ExtraSetting:Init()
ExtraSetting:BuildExtraSection(Tabs.Settings)
```

### Methods

| Method | Arguments | Description |
|---|---|---|
| SetLibrary(lib) | table | Link the library (also adds Fluent:Rejoin()) |
| SetFolder(path) | string | Set config folder |
| SetAFKInfo(key, callback) | string, function | Add custom info to the AFK overlay |
| RemoveAFKInfo(key) | string | Remove a custom AFK info line |
| Init() | -- | Initialize all subsystems |
| BuildExtraSection(tab) | Tab | Build the Extra tab UI |

### UI Sections

#### Links
- GitHub button (always shown)
- Discord button (only shown if `ExtraSetting.Discord` is set)

#### Anti-AFK
- Anti-AFK toggle
- Auto Reconnect toggle

#### Performance
- Unlock FPS toggle (only if `setfpscap` is available)
- FPS Boost toggle (applies boost after 5 seconds)
- FPS Overlay toggle (top-right display showing FPS and memory)

#### AFK Mode
- Enable AFK toggle (disables 3D rendering, shows black overlay)
- Auto AFK Time input (idle time before auto-enter)
- Auto Enter AFK toggle

The AFK overlay displays:
- Current time
- FPS counter
- RAM usage
- Custom info via `:SetAFKInfo()`
- Double-tap the minimize key to exit AFK mode

#### Auto Rejoin and Execute

Requires both `queue_on_teleport` capability and `ExtraSetting.AutoExecuteUrl` to be set.

- Auto Rejoin Time input (minutes)
- Enable Auto Rejoin Timer toggle
- Auto Execute on Rejoin toggle (executes the URL script after rejoining)

### Config Persistence

ExtraSetting saves its configuration to `{Folder}/settings/extra/extra_config.json` (separate from SaveManager).

### Discord and AutoExecuteUrl

```lua
-- Before Init(), set these optional values:
ExtraSetting.Discord = "https://discord.gg/invite"    -- shows Discord button
ExtraSetting.AutoExecuteUrl = "https://pastebin.com/raw/..."  -- enables auto rejoin section
```

---

# Advanced

## Creator Module

The Creator module is the core UI engine. It handles instance creation, theme management, and spring animations.

```lua
local Creator = Fluent.Creator  -- accessed internally
```

| Method | Signature | Description |
|---|---|---|
| New(Class, Properties, Children) | (string, table?, {Instance}?) -> Instance | Create instance with default props and theme support |
| AddSignal(Signal, Function) | (RBXScriptSignal, function) | Connect and store a signal for cleanup |
| Disconnect() | () | Disconnect all stored signals |
| GetThemeProperty(Property) | (string) -> any | Get a theme color/value |
| UpdateTheme(RegistryIndex?) | (Instance?) | Re-apply theme colors |
| AddThemeObject(Object, Properties) | (Instance, {string: any}) | Register object for theme updates |
| OverrideTag(Object, Properties) | (Instance, {string: any}) | Override theme tag on existing object |
| SpringMotor(Initial, Instance, Prop, ...) | (...) -> (Motor, SetValue) | Create a Flipper spring motor for smooth animation |

## Acrylic System

The acrylic blur uses a DepthOfField effect for frosted glass. It consists of:

- A translucent white base layer
- A dark background layer (theme: AcrylicMain)
- A white gradient overlay (theme: AcrylicGradient)
- A noise texture layer (theme: AcrylicNoise)
- A border stroke (theme: AcrylicBorder)
- A DepthOfField blur part positioned behind the UI

```lua
Fluent:ToggleAcrylic(true)    -- Enable
Fluent:ToggleAcrylic(false)   -- Disable
```

## Hide Button

A floating toggle button that shows/hides the window. On mobile it appears automatically by default.

| Value | Behaviour |
|---|---|
| `nil` (default) | **Auto** — only visible on mobile, uses eye/eye-slash icons |
| `true` | Always visible |
| `false` | Hidden entirely |

```lua
-- Enable always-visible hide button:
Fluent:CreateWindow({
    HideButton = true
})
```

Uses `Mobile.Size` and `Mobile.GetIcon` for sizing and icons. Draggable.

## Window Resize

When `Resize = true`, a bottom-right resize handle appears. The minimum size is controlled by `MinSize`.

```lua
Fluent:CreateWindow({
    Resize = true,
    MinSize = Vector2.new(470, 380)
})
```

## Window Methods

| Method | Description |
|---|---|
| Window:Minimize() | Toggle window visibility |
| Window:Maximize(Value, NoPos, Instant) | Maximize / restore |
| Window:Dialog(Config) | Open a modal dialog |
| Window:AddTab(Config) | Add a new tab |
| Window:SelectTab(Tab) | Switch to a tab |
| Window:Destroy() | Destroy the window |

## Window Signals

| Signal | Description |
|---|---|
| OnMinimized | Fired when window is minimized |
| PostMinimized | Fired after minimize animation |
| OnMaximized | Fired when window is maximized |
| PostMaximized | Fired after maximize animation |

## Mobile Support

```lua
Fluent:CreateWindow({
    Mobile = {
        GetIcon = function() end,    -- custom icon function
        Size = 40                    -- icon size
    }
})
```

When on mobile, a `Window.HideButton` appears for toggling visibility.

## Library Signals

```lua
Fluent.OnUnload:Connect(function()
    print("Library is being destroyed")
end)

Fluent.PostUnload:Connect(function()
    print("Destroy animation complete")
end)

Fluent.ThemeChanged:Connect(function()
    print("Theme changed to:", Fluent.Theme)
end)
```

## Safe Callback

```lua
Fluent:SafeCallback(function()
    print("This runs with pcall protection")
    error("This error will be caught and shown as a notification")
end)
```

## Destroy

```lua
Fluent:Destroy()   -- Fade-out animation, fires OnUnload/PostUnload
```

---

# Hints

## Breaking Coroutine Loops

Always check `Fluent.Unloaded` to break out of loops when the library is destroyed.

```lua
task.spawn(function()
    while task.wait(1) do
        print("Running...")
        if Fluent.Unloaded then break end
    end
end)
```

---

# Examples

```lua
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local ExtraSetting = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/ExtraSetting.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Fluent " .. Fluent.Version,
    SubTitle = "by dawid",
    TabWidth = 160,
    Size = UDim2.fromOffset(470, 380),
    Resize = true,
    Acrylic = true,
    Theme = "Vynixu",
    MinimizeKey = Enum.KeyCode.RightControl,
    HideButton = true,
    Transparency = false
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

do
    Fluent:Notify({
        Title = "Welcome",
        Content = "Fluent Renewed Plus loaded!",
        Duration = 5
    })

    Tabs.Main:AddParagraph({
        Title = "About",
        Content = "This is an example script."
    })

    Tabs.Main:AddButton({
        Title = "Button",
        Description = "Click for dialog",
        Callback = function()
            Window:Dialog({
                Title = "Dialog",
                Content = "Hello!",
                Buttons = {
                    { Title = "OK", Callback = function() print("OK") end }
                }
            })
        end
    })

    local Toggle = Tabs.Main:AddToggle("MyToggle", {
        Title = "Toggle",
        Default = false,
        Callback = function(v) print("Toggle:", v) end
    })

    local Slider = Tabs.Main:AddSlider("MySlider", {
        Title = "Slider",
        Default = 5,
        Min = 0,
        Max = 10,
        Rounding = 1,
        Callback = function(v) print("Slider:", v) end
    })

    local Dropdown = Tabs.Main:AddDropdown("MyDropdown", {
        Title = "Dropdown",
        Values = {"A", "B", "C"},
        Default = 1,
        Callback = function(v) print("Dropdown:", v) end
    })

    local Colorpicker = Tabs.Main:AddColorpicker("MyColorpicker", {
        Title = "Color",
        Default = Color3.fromRGB(96, 205, 255)
    })

    local Keybind = Tabs.Main:AddKeybind("MyKeybind", {
        Title = "Keybind",
        Mode = "Toggle",
        Default = "LeftControl",
        Callback = function(v) print("Keybind:", v) end
    })

    local Input = Tabs.Main:AddInput("MyInput", {
        Title = "Input",
        Default = "text",
        Callback = function(v) print("Input:", v) end
    })
end

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
ExtraSetting:SetLibrary(Fluent)

SaveManager:SetFolder("FluentScript")
InterfaceManager:SetFolder("FluentScript")
ExtraSetting:SetFolder("FluentScript")

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
ExtraSetting:BuildExtraSection(Tabs.Settings)

ExtraSetting:Init()

Window:SelectTab(1)

SaveManager:LoadAutoloadConfig()
InterfaceManager:LoadSettings()
```

---

# License

Fluent Renewed Plus is licensed under the GNU General Public License v3.0.

Source: https://github.com/dawid-scripts/Fluent
