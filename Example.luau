local Library = loadstring(game:HttpGet("https://github.com/lamduck2005/Fluent-Renewed-Plus/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/lamduck2005/Fluent-Renewed-Plus/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/lamduck2005/Fluent-Renewed-Plus/master/Addons/InterfaceManager.luau"))()
local ExtraSetting = loadstring(game:HttpGet("https://raw.githubusercontent.com/lamduck2005/Fluent-Renewed-Plus/master/Addons/ExtraSetting.luau"))()
 
local Window = Library:Window{
	Title = `Fluent Renewed Plus {Library.Version}`,
	SubTitle = "by Lamduck2005",
	TabWidth = 160,
	Size = UDim2.fromOffset(830, 525),
	Resize = true,
	Acrylic = true,
	Theme = "Vynixu",
	MinimizeKey = Enum.KeyCode.RightControl,
	HideButton = true,
	Transparency = false,

	-- Key system (active: Mode 1 - static key. Password: "fluent")
	-- KeySystem = {
	-- 	Title = "Fluent Renewed",
	-- 	Note = "Enter your key to continue.",
	-- 	SaveKey = true,
	-- 	Key = "fluent",
	-- 	URL = "https://github.com/lamduck2005/Fluent-Renewed-Plus",
	-- 	Thumbnail = {
	-- 		Image = "rbxassetid://8992230677",
	-- 		Title = "Fluent",
	-- 	},
	-- },

	-- Mode 2: Custom validator (comment Mode 1 above, uncomment this)
	-- KeySystem = {
	-- 	Title = "Fluent Renewed",
	-- 	Note = "Enter the secret password.",
	-- 	SaveKey = true,
	-- 	KeyValidator = function(key)
	-- 		return key == "mypassword"
	-- 	end,
	-- },

	-- Mode 3: API services (comment Mode 1 above, uncomment this + fill your credentials)
	KeySystem = {
		Title = "Fluent Renewed",
		Note = "24 hour key, access all scripts!",
		SaveKey = true,
		-- Thumbnail = {
		-- 	Image = "rbxassetid://8992230677",
		-- 	Title = "Premium",
		-- },
		API = {
			{ Type = "platoboost", ServiceId = "your-service-id", Secret = "your-secret" },
			{ Type = "pandadevelopment", ServiceId = "your-service-id" },
			{ Type = "luarmor", ScriptId = "your-script-id", Discord = "discord.gg/..." },
			{ Type = "junkiedevelopment", ServiceId = "your-service-id", ApiKey = "your-api-key", Provider = "your-provider" },
		},
	},
}


-- Fluent Renewed provides ALL 1544 Lucide 0.469.0 https://lucide.dev/icons/ Icons and ALL 9072 Phosphor 2.1.0 https://phosphoricons.com/ Icons for the tabs, icons are optional
local Tabs = {
    Main = Window:CreateTab{
        Title = "Main",
        Icon = "phosphor-users-bold"
    },
    Settings = Window:CreateTab{
        Title = "Settings",
        Icon = "settings"
    },
    SubTabs = Window:CreateTab{
        Title = "SubTabs",
        Icon = "layers"
    },
    Extra = Window:CreateTab{
        Title = "Extra",
        Icon = "settings"
    }
}

-- Create SubTabBar inside Main Tab
local SubTabContainers = Tabs.Main:AddSubTabBar({
    SubTabs = { "SubTab A", "SubTab B", "SubTab C" },
    Default = "SubTab A",
})

SubTabContainers["SubTab A"]:AddToggle("Toggle_A1", { Title = "Example Toggle A1", Default = false })
SubTabContainers["SubTab B"]:AddToggle("Toggle_B1", { Title = "Example Toggle B1", Default = false })
SubTabContainers["SubTab C"]:AddToggle("Toggle_C1", { Title = "Example Toggle C1", Default = false })

-- Setup SubTabs demo with Sections, Toggles, and Buttons
local DemoContainers = Tabs.SubTabs:AddSubTabBar({
    SubTabs = { "Tab 1", "Tab 2", "Tab 3" },
    Default = "Tab 1",
})

for _, tabName in ipairs({ "Tab 1", "Tab 2", "Tab 3" }) do
    local container = DemoContainers[tabName]
    local key = tabName:gsub(" ", "")
    
    local section = container:AddSection(tabName .. " Group")
    
    section:AddToggle("Toggle_Demo" .. key, {
        Title = "Option for " .. tabName,
        Default = false
    })
    
    section:AddButton({
        Title = "Run Test",
        Callback = function()
            print("Running test for " .. tabName)
        end
    })
end

local Options = Library.Options

Library:Notify{
    Title = "Notification",
    Content = "This is a notification",
    SubContent = "SubContent", -- Optional
    Duration = 5 -- Set to nil to make the notification not disappear
}

local Paragraph = Tabs.Main:CreateParagraph("Paragraph", {
    Title = "Paragraph",
    Content = "This is a paragraph.\nSecond line!"
})

print(Paragraph.Value)

Paragraph:SetValue("This paragraph text is changed!")

print(Paragraph.Value)

Tabs.Main:CreateParagraph("Aligned Paragraph", {
    Title = "Paragraph",
    Content = "This is a paragraph with a center alignment!",
    TitleAlignment = "Middle",
    ContentAlignment = Enum.TextXAlignment.Center
})

Tabs.Main:CreateButton{
    Title = "Button",
    Description = "Very important button",
    Callback = function()
        Window:Dialog{
            Title = "Title",
            Content = "This is a dialog",
            Buttons = {
                {
                    Title = "Confirm",
                    Callback = function()
                        print("Confirmed the dialog.")
                    end
                },
                {
                    Title = "Cancel",
                    Callback = function()
                        print("Cancelled the dialog.")
                    end
                }
            }
        }
    end
}

local Toggle = Tabs.Main:CreateToggle("MyToggle", {Title = "Toggle", Default = false })

Toggle:OnChanged(function()
    print("Toggle changed:", Options.MyToggle.Value)
end)

Options.MyToggle:SetValue(false)

local Slider = Tabs.Main:CreateSlider("Slider", {
    Title = "Slider",
    Description = "This is a slider",
    Default = 2,
    Min = 0,
    Max = 5,
    Rounding = 1,
    Callback = function(Value)
        print("Slider was changed:", Value)
    end
})

Slider:OnChanged(function(Value)
    print("Slider changed:", Value)
end)

Slider:SetValue(3)

local Dropdown = Tabs.Main:CreateDropdown("Dropdown", {
    Title = "Dropdown",
    Values = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen"},
    Multi = false,
    Default = 1,
})

Dropdown:SetValue("four")

Dropdown:OnChanged(function(Value)
    print("Dropdown changed:", Value)
end)

local MultiDropdown = Tabs.Main:CreateDropdown("MultiDropdown", {
    Title = "Dropdown",
    Description = "You can select multiple values.",
    Values = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen"},
    Multi = true,
    Default = {"seven", "twelve"},
})

MultiDropdown:SetValue{
    three = true,
    five = true,
    seven = false
}

MultiDropdown:SetValues{"fifteen", "sixteen", "seventeen"}

MultiDropdown:OnChanged(function(Value)
    local Values = {}
    for Value, State in next, Value do
        Values[#Values + 1] = Value
    end
    print("Mutlidropdown changed:", table.concat(Values, ", "))
end)

local MultiInstanceDropdown = Tabs.Main:CreateDropdown("MultiInstanceDropdown", {
    Title = "Instance Dropdown",
    Description = "You can select multiple values and any instance or any other value!",
    Values = {workspace, 5, Enum.JoinSource, Enum.MarketplaceBulkPurchasePromptStatus.Error},
    Multi = true,
    Default = {workspace},
})

MultiInstanceDropdown:OnChanged(function(Value)
    local Values = {}
    for Value, State in next, Value do
        Values[#Values + 1] = typeof(Value)
    end
    print("Mutlidropdown with instance selection changed:", table.concat(Values, ", "))
end)

local Colorpicker = Tabs.Main:CreateColorpicker("Colorpicker", {
    Title = "Colorpicker",
    Default = Color3.fromRGB(96, 205, 255)
})

Colorpicker:OnChanged(function()
    print("Colorpicker changed:", Colorpicker.Value)
end)

Colorpicker:SetValueRGB(Color3.fromRGB(0, 255, 140))

local TColorpicker = Tabs.Main:CreateColorpicker("TransparencyColorpicker", {
    Title = "Colorpicker",
    Description = "but you can change the transparency.",
    Transparency = 0,
    Default = Color3.fromRGB(96, 205, 255)
})

TColorpicker:OnChanged(function()
    print(
        "TColorpicker changed:", TColorpicker.Value,
        "Transparency:", TColorpicker.Transparency
    )
end)

local Keybind = Tabs.Main:CreateKeybind("Keybind", {
    Title = "KeyBind",
    Mode = "Toggle", -- Always, Toggle, Hold
    Default = "LeftControl", -- String as the name of the keybind (MB1, MB2 for mouse buttons)

    -- Occurs when the keybind is clicked, Value is `true`/`false`
    Callback = function(Value)
        print("Keybind clicked!", Value)
    end,

    -- Occurs when the keybind itself is changed, `New` is a KeyCode Enum OR a UserInputType Enum
    ChangedCallback = function(New)
        print("Keybind changed!", New)
    end
})

-- OnClick is only fired when you press the keybind and the mode is Toggle
-- Otherwise, you will have to use Keybind:GetState()
Keybind:OnClick(function()
    print("Keybind clicked:", Keybind:GetState())
end)

Keybind:OnChanged(function()
    print("Keybind changed:", Keybind.Value)
end)

task.spawn(function()
    while true do
        wait(1)

        -- example for checking if a keybind is being pressed
        local state = Keybind:GetState()
        if state then
            print("Keybind is being held down")
        end

        if Library.Unloaded then break end
    end
end)

Keybind:SetValue("MB2", "Toggle") -- Sets keybind to MB2, mode to Hold

local Input = Tabs.Main:CreateInput("Input", {
    Title = "Input",
    Default = "Default",
    Placeholder = "Placeholder",
    Numeric = false, -- Only allows numbers
    Finished = false, -- Only calls callback when you press enter
    Callback = function(Value)
        print("Input changed:", Value)
    end
})

Input:OnChanged(function()
    print("Input updated:", Input.Value)
end)

Tabs.Main:CreateButton{
    Title = "Really Really big Dropdown",
    Description = "",
    Callback = function()
        local Values = {}

        for i = 1, 1000 do
            Values[i] = i
        end

        Tabs.Main:AddDropdown("BIGDropdown", {
            Title = "Big Dropdown",
            Values = Values,
            Multi = false,
            Default = 1,
        })
    end
}

-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- InterfaceManager (Allows you to have a interface managment system)

-- Hand the library over to our managers
SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)
ExtraSetting:SetLibrary(Library)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- You can add indexes of elements the save manager should ignore
SaveManager:SetIgnoreIndexes{}

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")
ExtraSetting:SetFolder("FluentScriptHub")

-- ExtraSetting.Discord = "https://discord.gg/N3uxkAHYtM"
ExtraSetting.AutoExecuteUrl = "https://raw.githubusercontent.com/DarkNetworks/Infinite-Yield/main/latest.lua"

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
ExtraSetting:BuildExtraSection(Tabs.Extra)

ExtraSetting:SetAFKInfo("Players", function()
	return "Players online", #game:GetService("Players"):GetPlayers()
end)
ExtraSetting:SetAFKInfo("Game", function()
	return "Place ID", game.PlaceId
end)


Window:SelectTab(1)

Library:Notify{
    Title = "Fluent",
    Content = "The script has been loaded.",
    Duration = 8
}

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()