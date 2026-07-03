local Library = require(game:GetService("ReplicatedStorage"):WaitForChild("Fluent"):WaitForChild("MainModule"))

local Window = Library:Window{
	Title = `Fluent Renewed Plus {Library.Version}`,
	SubTitle = "by Lamduck2005",
	TabWidth = 160,
	Size = UDim2.fromOffset(1200, 600),
	Resize = true,
	Acrylic = true,
	Theme = "Vynixu",
	MinimizeKey = Enum.KeyCode.P,
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
	-- KeySystem = {
	-- 	Title = "Fluent Renewed Plus",
	-- 	Note = "24 hour key, access all scripts!",
	-- 	SaveKey = true,
	-- 	Thumbnail = {
	-- 		Image = "rbxassetid://8992230677",
	-- 		Title = "Premium",
	-- 	},
	-- 	API = {
	-- 		{ Type = "platoboost", ServiceId = "your-service-id", Secret = "your-secret" },
	-- 		{ Type = "pandadevelopment", ServiceId = "your-service-id" },
	-- 		{ Type = "luarmor", ScriptId = "your-script-id", Discord = "discord.gg/..." },
	-- 		{ Type = "junkiedevelopment", ServiceId = "your-service-id", ApiKey = "your-api-key", Provider = "your-provider" },
	-- 	},
	-- },
}

local Tabs = {
    Main = Window:Tab{
        Title = "Main",
        Icon = "phosphor-users-bold"
    },
    Settings = Window:Tab{
        Title = "Settings",
        Icon = "settings"
    }
}

local Paragraph = Tabs.Main:Paragraph("Paragraph", {
    Title = "Paragraph",
    Content = "This is a paragraph.\nSecond line!"
})

print(Paragraph.Value)

Paragraph:SetValue("This paragraph text is changed!")

print(Paragraph.Value)

Tabs.Main:Paragraph("Aligned Paragraph", {
    Title = "Paragraph",
    Content = "This is a paragraph with a center alignment!",
    TitleAlignment = "Middle",
    ContentAlignment = Enum.TextXAlignment.Center
})

Tabs.Main:AddDivider()

Tabs.Main:Button({
    Title = "Button",
    Description = "Very important button",
    Callback = function()
        local D = Window:Dialog({
            Title = "Title",
            Content = "This is a dialog",
            Buttons = {
                {
                    Title = "Confirm",
                    Callback = function()
                        Window:Dialog({
                            Title = "Another Dialog",
                            Content = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse mollis dolor eget erat mattis, id mollis mauris cursus. Proin ornare sollicitudin odio, id posuere diam luctus id.",
                            Buttons = { { Title = "Ok", Callback = function() print("Ok") end} }
                        })
                    end
                },
                {
                    Title = "Cancel",
                    Callback = function()
                        print("Cancelled the dialog.")
                    end
                }
            }
        })
        print(D)
        D.Closed:Wait()
        print("Ok!!!")
    end
})

Tabs.Main:AddSpace()

Tabs.Main:Button({
    Title = "Button but with an error",
    Description = "Not a important button",
    Callback = function()
        print("Hello, "..tonumber("World").."!")
    end
})

Tabs.Main:AddSpace({Column = 3})

local Toggle = Tabs.Main:Toggle("Toggle", {Title = "Toggle", Default = false })

local Slider = Tabs.Main:Slider("Slider", {
    Title = "Slider",
    Description = "This is a slider",
    Default = 2.0,
    Min = 0.0,
    Max = 15.5,
    Rounding = 1
})

print(Slider.Value)

Slider.Value = 4.5

print(Slider.Value)

local Dropdown = Tabs.Main:Dropdown("Dropdown", {
    Title = "Dropdown",
    Values = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen"},
    Multi = false,
    Default = 1,
})

Dropdown:SetValue("four")

print(Dropdown.Value)

Dropdown.Value = 4.5
Dropdown.Values = {"fifteen", "sixteen", "seventeen", "eighteen", "nineteen", "twenty", "twentyone", "twentytwo", "twentythree", "twentyfour", "twentyfive", "twentysix", "twentyseven", "twentyeight"}

print(Dropdown.Value)

local MultiDropdown = Tabs.Main:Dropdown("MultiDropdown", {
    Title = "Dropdown",
    Description = "You can select multiple values.",
    Values = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen"},
    Multi = true,
    Default = {"seven", "twelve"},
})

MultiDropdown:SetValue({
    three = true,
    five = true,
    seven = false
})

local MultiInstanceDropdown = Tabs.Main:Dropdown("MultiInstanceDropdown", {
    Title = "Instance Dropdown",
    Description = "You can select multiple values and any instance or any other value!",
    Values = {workspace, 5, Enum.JoinSource, Enum.MarketplaceBulkPurchasePromptStatus.Error},
    Multi = true,
    Default = {5},
})

local MultiTableDropdown = Tabs.Main:Dropdown("MultiInstanceDropdown", {
    Title = "Dropdown Displayer Function",
    Description = "You can change what the name of the Value is when passing the Displayer Function!",
    Values = {
        {
            Name = "Rawr 5",
            Value = 5
        },
        {
            Name = "Rawr 4",
            Value = 4
        },
        {
            Name = "Rawr 3",
            Value = 3
        },
        {
            Name = "Rawr 21",
            Value = 21
        }
    },
    Displayer = function(Val)
        return Val.Name
    end,
    Multi = true,
    Default = {}
})

local SearchableDropdown = Tabs.Main:Dropdown("SearchingDropdown", {
    Title = "Dropdown",
    Values = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen"},
    Multi = false,
    Searchable = true,
    Default = 1,
    AutoDeselect = true,
    Callback = function(Value)
        print(Value)
    end
})

local Colorpicker = Tabs.Main:Colorpicker("Colorpicker", {
    Title = "Colorpicker",
    Default = Color3.fromRGB(96, 205, 255)
})

local TColorpicker = Tabs.Main:Colorpicker("TransparencyColorpicker", {
    Title = "Colorpicker",
    Description = "but you can change the transparency.",
    Transparency = 0,
    Default = Color3.fromRGB(96, 205, 255)
})

local CColorpicker = Tabs.Main:Colorpicker("ChangeColorpicker", {
    Title = "Colorpicker",
    Description = "but it updates while you slide.",
    Transparency = 0,
    Default = Color3.fromRGB(96, 205, 255),
    UpdateOnChange = true
})

local Keybind = Tabs.Main:Keybind("Keybind", {
    Title = "KeyBind",
    Mode = "Hold",
    Default = "LeftControl",
    ChangedCallback = function(New)
        print("Keybind changed:", New)
    end
})

local Input = Tabs.Main:Input("Input", {
    Title = "Input",
    Default = "Default",
    Numeric = false,
    Finished = false,
    Placeholder = "Placeholder text",
    Callback = function(Value)
        print("Input changed:", Value)
    end
})

local InputLostFocus = Tabs.Main:Input("InputFocusLost", {
    Title = "Input",
    Default = "Default",
    ClearOnFocusLost = true, -- Only availible when Finished == true
    Numeric = false,
    Finished = true,
    Placeholder = "Placeholder text",
    Callback = function(Value)
        print("Input changed:", Value)
    end
})

Toggle:OnChanged(function()
    print("Toggle changed:", Library.Options["Toggle"].Value)
end)

Slider:OnChanged(function(Value)
    print("Slider changed:", Value)
end)

Dropdown:OnChanged(function(Value)
    print("Dropdown changed:", Value)
end)

MultiDropdown:OnChanged(function(Value)
    local Values = {}

    for Value, State in next, Value do
        Values[#Values + 1] = Value
    end

    print("Mutlidropdown changed:", table.concat(Values, ", "))
end)

MultiInstanceDropdown:OnChanged(function(Value)
    local Values = {}

    for Value, State in next, Value do
        Values[#Values + 1] = typeof(Value)
    end

    print("Mutlidropdown with instance selection changed:", table.concat(Values, ", "))
end)

MultiTableDropdown:OnChanged(function(Value)
    local Values = {}

    for Value, State in next, Value do
        Values[#Values + 1] = Value
    end

    print("Mutlidropdown table displayer thingy idk:", Values)
end)

Colorpicker:OnChanged(function()
    print("Colorpicker changed:", TColorpicker.Value)
end)

TColorpicker:OnChanged(function()
    print(
        "TColorpicker changed:", TColorpicker.Value,
        "Transparency:", TColorpicker.Transparency
    )
end)

CColorpicker:OnChanged(function()
    print(
        "CColorpicker changed:", CColorpicker.Value,
        "Transparency:", CColorpicker.Transparency
    )
end)

Tabs.Main:Button{
    Title = "Really Really big Dropdown",
    Description = "",
    Callback = function()
        local Values = {}

        for i = 1, 1750 do
            Values[i] = i
        end

        Tabs.Main:Dropdown("Dropdown", {
            Title = "Big Dropdown",
            Values = Values,
            Multi = false,
            Default = 1,
        })
    end
}

Tabs.Main:Button{
    Title = "Set Dropdown Values",
    Description = "",
    Callback = function()
        local Values = {}

        for i = 1, 1 do
            Values[i] = math.random(i, i^2)
        end

        Dropdown:SetValues(Values)
    end
}

local ToggleKeybind = Tabs.Main:Toggle("ToggleWithKeybind", {
    Title = "Toggle",
    Default = false
})

local ActualKeybindForTheToggle = ToggleKeybind:Keybind("KeybindInToggle", {
    Title = "Keybind",
    Default = Enum.KeyCode.A
})

task.spawn(function()
    while true do
        wait(1)
        local state = Keybind:GetState()
        if state then
            print("Keybind is being held down")
        end
        if Library.Unloaded then break end
    end
end)

local InterfaceSection = Tabs.Settings:Section("Interface")

InterfaceSection:Dropdown("InterfaceTheme", {
    Title = "Theme",
    Description = "Changes the interface theme.",
    Values = Library.Themes,
    Default = Library.Theme,
    Callback = function(Value)
        Library:SetTheme(Value)
    end
})

if Library.UseAcrylic then
    InterfaceSection:Toggle("AcrylicToggle", {
        Title = "Acrylic",
        Description = "The blurred background requires graphic quality 8+",
        Default = Library.Acrylic,
        Callback = function(Value)
            Library:ToggleAcrylic(Value)
        end
    })
end

InterfaceSection:Toggle("TransparentToggle", {
    Title = "Transparency",
    Description = "Makes the interface transparent.",
    Default = Library.Transparency,
    Callback = function(Value)
        Library:ToggleTransparency(Value)
    end
})

InterfaceSection:Keybind("MenuKeybind", {
    Title = "Minimize Bind", 
    Default = Library.MinimizeKey or Enum.KeyCode.RightShift,
    ChangedCallback = function(Value)
        Library.MinimizeKey = Value
    end
})
Library.MinimizeKeybind = Library.Options.MenuKeybind

Window:SelectTab(1)

Library:Notify({
    Title = "Fluent",
    Content = "The script has been loaded.",
    Duration = 8,
    Sound = {
        SoundId = "rbxassetid://8486683243"
    }
})

-- ======== STRESS TEST SUITE ========

local RunService = game:GetService("RunService")
local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- FPS overlay
local FpsGui = Instance.new("ScreenGui")
FpsGui.Name = "FluentFPSMonitor"
FpsGui.ResetOnSpawn = false
FpsGui.Enabled = false

local FpsBg = Instance.new("Frame")
FpsBg.Size = UDim2.fromOffset(280, 24)
FpsBg.Position = UDim2.fromOffset(10, 10)
FpsBg.BackgroundColor3 = Color3.new(0, 0, 0)
FpsBg.BackgroundTransparency = 0.35
FpsBg.BorderSizePixel = 0
FpsBg.Parent = FpsGui

local FpsLabel = Instance.new("TextLabel")
FpsLabel.Size = UDim2.fromScale(1, 1)
FpsLabel.BackgroundTransparency = 1
FpsLabel.TextColor3 = Color3.new(1, 1, 1)
FpsLabel.TextSize = 13
FpsLabel.Font = Enum.Font.Code
FpsLabel.TextXAlignment = Enum.TextXAlignment.Left
FpsLabel.Position = UDim2.fromOffset(4, 0)
FpsLabel.Text = "FPS: -- | Mem: -- KB"
FpsLabel.Parent = FpsBg
FpsGui.Parent = PlayerGui

local fpsCount, fpsTime, currentFps = 0, os.clock(), 0
RunService.RenderStepped:Connect(function()
	fpsCount += 1
	local now = os.clock()
	if now - fpsTime >= 0.5 then
		currentFps = math.floor(fpsCount * 2)
		fpsCount, fpsTime = 0, now
		FpsLabel.Text = string.format("FPS: %d | Mem: %.1f KB", currentFps, collectgarbage("count"))
	end
end)

local StressTab = Window:Tab({
	Title = "Stress",
	Icon = "phosphor-gauge-bold",
})

StressTab:Toggle("FpsMonitorToggle", {
	Title = "FPS Monitor",
	Description = "Show FPS + memory overlay",
	Default = false,
	Callback = function(v)
		FpsGui.Enabled = v
	end,
})

local BenchSection = StressTab:Section("Benchmarks")

-- 1) 2000 dropdown options
local stressDropdownsRef = {}
local stressSpawnCount = 0
BenchSection:Button({
	Title = "Spawn 2000 Dropdown Options",
	Description = "20 dropdowns × 100 values each. Measures total load time.",
	Callback = function()
		local start = os.clock()
		stressSpawnCount += 1

		for d = 1, 20 do
			local vals = {}
			for v = 1, 100 do
				vals[v] = "Opt " .. d .. "-" .. v
			end

			local dd = StressTab:Dropdown("StressDD_" .. stressSpawnCount .. "_" .. d, {
				Title = "Dropdown " .. d .. " (100 options)",
				Values = vals,
				Default = 1,
			})
			stressDropdownsRef[#stressDropdownsRef + 1] = dd

			if d % 5 == 0 then
				task.wait()
			end
		end

		local elapsed = os.clock() - start
		print(string.format("[Stress] 2000 options created in %.2fs | Mem: %.1f KB", elapsed, collectgarbage("count")))
	end,
})

BenchSection:Button({
	Title = "Cleanup All Stress Dropdowns",
	Description = "Destroys every spawned dropdown + section from all spawns",
	Callback = function()
		local ddCount = #stressDropdownsRef
		for _, dd in stressDropdownsRef do
			if dd and dd.Destroy then
				dd:Destroy()
			end
		end
		table.clear(stressDropdownsRef)

		print(string.format("[Stress] %d dropdowns cleaned | Mem: %.1f KB", ddCount, collectgarbage("count")))
	end,
})

-- 2) Notification flood
BenchSection:Button({
	Title = "Notification Flood (50)",
	Description = "Creates 50 notifications at once",
	Callback = function()
		local start = os.clock()
		for i = 1, 50 do
			Library:Notify({
				Title = "Flood #" .. i,
				Content = "Stress notification " .. i,
				Duration = 4,
			})
		end
		print(string.format("[Stress] 50 notifications in %.3fs | Mem: %.1f KB", os.clock() - start, collectgarbage("count")))
	end,
})

-- 3) Dropdown rebuild spam
local RebuildDD = StressTab:Dropdown("RebuildTargetDD", {
	Title = "Rebuild Target",
	Values = {"a", "b", "c"},
	Default = 1,
})
BenchSection:Button({
	Title = "Rebuild Spam (100×50)",
	Description = "Rebuilds dropdown 100 times, 50 values each",
	Callback = function()
		local start = os.clock()
		for i = 1, 100 do
			local vals = {}
			for j = 1, 50 do
				vals[j] = "v" .. i .. "-" .. j
			end
			RebuildDD:SetValues(vals)
			if i % 10 == 0 then
				task.wait()
			end
		end
		print(string.format("[Stress] 100 rebuilds in %.3fs | Mem: %.1f KB", os.clock() - start, collectgarbage("count")))
	end,
})

-- 4) Create / destroy loop
BenchSection:Button({
	Title = "Create / Destroy Loop (100×5)",
	Description = "Create 100 toggles in tab, destroy, repeat 5×. Watch memory after GC.",
	Callback = function()
		local start = os.clock()

		for cycle = 1, 5 do
			local els = {}
			for i = 1, 100 do
				els[i] = StressTab:Toggle("CDTog_" .. cycle .. "_" .. i, {
					Title = "CD " .. cycle .. "-" .. i,
					Default = false,
				})
			end
			task.wait()
			for i = 1, 100 do
				if els[i] and els[i].Destroy then
					els[i]:Destroy()
				end
			end
			table.clear(els)
			task.wait()
		end

		print(string.format("[Stress] 5 cycles of 100 create/destroy in %.3fs | Mem: %.1f KB", os.clock() - start, collectgarbage("count")))
	end,
})

-- 5) Memory report + quick GC
BenchSection:Button({
	Title = "Memory Report",
	Description = "Prints memory & FPS to console",
	Callback = function()
		local mem = collectgarbage("count")
		print(string.format("[Stress] Mem: %.1f KB | FPS: %d", mem, currentFps))
	end,
})

print(Library.Utilities:GetOS())