local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Mouse = game:GetService("Players").LocalPlayer:GetMouse()
local Camera = game:GetService("Workspace").CurrentCamera

local Root = script.Parent.Parent
local Creator = require(Root.Modules.Creator)

local New = Creator.New
local Components = Root.Components

local Element = {}
Element.__index = Element
Element.__type = "Dropdown"

function Element:New(Idx, Config)
	local Library = self.Library

	local dropdownConns = {}
	local optionCleanup = {}
	local AllButton, NoneButton, AllButtonLabel, NoneButtonLabel

	local Dropdown = {
		Values = (function()
			local Idxes = {}

			for i,v in next, Config.Values or {} do
				Idxes[#Idxes + 1] = v
			end

			return Idxes
		end)(),
		Value = (function()
			local valuesList = {}
			for _, v in next, Config.Values or {} do
				valuesList[#valuesList + 1] = v
			end

			if Config.Multi then
				local result = {}
				local raw = Config.Default or Config.Value
				if type(raw) == "table" then
					for k, v in next, raw do
						if type(k) == "number" and table.find(valuesList, v) then
							result[v] = true
						elseif v == true and table.find(valuesList, k) then
							result[k] = true
						end
					end
				end
				return result
			else
				local raw = Config.Default or Config.Value
				if type(raw) == "number" and valuesList[raw] ~= nil then
					return valuesList[raw]
				elseif raw and table.find(valuesList, raw) then
					return raw
				end
				return nil
			end
		end)(),
		Multi = Config.Multi or false,
		AutoDeselect = Config.AutoDeselect or false,
		Searchable = Config.Searchable or false,
		FocusSearch = if Config.FocusSearch ~= nil then Config.FocusSearch else false,
		SearchPlaceholder = Config.SearchPlaceholder or "Search...",
		Displayer = typeof(Config.Displayer) == "function" and Config.Displayer or function(Value)
			return typeof(Value) ~= "number" and tostring(Library.Utilities:Prettify(Value)) or Value
		end,
		CustomDisplayer = (typeof(Config.Displayer) == "function" and Config.Displayer and true) or false,
		Buttons = {},
		ButtonsList = {},
		Built = false,
		Opened = false,
		Type = "Dropdown",
		Callback = Config.Callback or function() end,
		Changed = Config.Changed or function() end
	}

	local DropdownFrame = require(Components.Element)(Config.Title, Config.Description, self.Container, false)
	DropdownFrame.DescLabel.Size = UDim2.new(1, -170, 0, 14)

	Dropdown.SetTitle = DropdownFrame.SetTitle
	Dropdown.SetDesc = DropdownFrame.SetDesc

	local DropdownDisplay = New("TextLabel", {
		FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
		Text = "Value",
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -30, 0, 14),
		Position = UDim2.new(0, 8, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	local DropdownIco = New("ImageLabel", {
		Image = "rbxassetid://10709790948",
		Size = UDim2.fromOffset(16, 16),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		BackgroundTransparency = 1,
		ThemeTag = {
			ImageColor3 = "SubText",
		}
	})

	local DropdownInner = New("TextButton", {
		Size = UDim2.fromOffset(160, 30),
		Position = UDim2.new(1, -10, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 0.9,
		Parent = DropdownFrame.Frame,
		ThemeTag = {
			BackgroundColor3 = "DropdownFrame"
		}
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 5),
		}),
		New("UIStroke", {
			Transparency = 0.5,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeTag = {
				Color = "InElementBorder",
			},
		}),
		DropdownIco,
		DropdownDisplay,
	})

	local DropdownListLayout = New("UIListLayout", {
		Padding = UDim.new(0, 3),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local DropdownScrollFrame = New("ScrollingFrame", {
		Size = UDim2.new(1, -5, 1, Dropdown.Searchable and -40 or -10),
		Position = UDim2.fromOffset(5, Dropdown.Searchable and 40 or 5),
		BackgroundTransparency = 1,
		BottomImage = "rbxassetid://6889812791",
		MidImage = "rbxassetid://6889812721",
		TopImage = "rbxassetid://6276641225",
		ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
		ScrollBarImageTransparency = 0.95,
		ScrollBarThickness = 4,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromScale(0, 0),
	}, {
		DropdownListLayout,
	})

	local DropdownHolderFrame = New("Frame", {
		Size = UDim2.fromScale(1, 0.6),
		ThemeTag = {
			BackgroundColor3 = "DropdownHolder",
		},
	}, {
		DropdownScrollFrame,
		New("UICorner", {
			CornerRadius = UDim.new(0, 7),
		}),
		New("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeTag = {
				Color = "DropdownBorder",
			},
		}),
		New("ImageLabel", {
			BackgroundTransparency = 1,
			Image = "http://www.roblox.com/asset/?id=5554236805",
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(23, 23, 277, 277),
			Size = UDim2.fromScale(1, 1) + UDim2.fromOffset(30, 30),
			Position = UDim2.fromOffset(-15, -15),
			ImageColor3 = Color3.fromRGB(0, 0, 0),
			ImageTransparency = 0.1,
		}),
	}) :: Frame

	local SearchableTextbox = require(Components.Textbox)(DropdownHolderFrame, true)
	SearchableTextbox.Frame.Visible = Dropdown.Searchable
	SearchableTextbox.Frame.AnchorPoint = Vector2.new(0.5, 0)
	SearchableTextbox.Frame.Position = UDim2.new(0.5, 0, 0, 5)
	SearchableTextbox.Frame.Size = UDim2.new(1, -5, 0, 32)
	SearchableTextbox.Input.PlaceholderText = Dropdown.SearchPlaceholder
	SearchableTextbox.Input.Text = ""

	local SearchBox = SearchableTextbox.Input

	local ButtonSelector_BuildList = New("Frame", {
		Size = UDim2.fromOffset(4, 14),
		BackgroundColor3 = Color3.fromRGB(76, 194, 255),
		Position = UDim2.fromOffset(-1, 16),
		AnchorPoint = Vector2.new(0, 0.5),
		ThemeTag = {
			BackgroundColor3 = "Accent",
		}
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 2),
		}),
	}) :: Frame

	local ButtonLabel_BuildList = New("TextLabel", {
		FontFace = Font.new("rbxasset://fonts/families/Montserrat.json"),
		TextColor3 = Color3.fromRGB(200, 200, 200),
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromOffset(10, 0),
		Name = "ButtonLabel",
		ThemeTag = {
			TextColor3 = "Text"
		}
	}) :: TextLabel

	local Button_BuildList = New("TextButton", {
		Size = UDim2.new(1, -5, 0, 32),
		BackgroundTransparency = 1,
		ZIndex = 23,
		Text = "",
		ThemeTag = {
			BackgroundColor3 = "DropdownOption"
		}
	}, {
		ButtonSelector_BuildList,
		ButtonLabel_BuildList,
		New("UICorner", {
			CornerRadius = UDim.new(0, 6),
		})
	}) :: TextButton

	local DropdownHolderCanvas = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(170, 300),
		Parent = self.Library.GUI,
		Visible = false,
	}, {
		DropdownHolderFrame,
		New("UISizeConstraint", {
			MinSize = Vector2.new(170, 0),
		}),
	})

	Library.OpenFrames[#Library.OpenFrames + 1] = DropdownHolderCanvas

	local ListSizeX = 0
	local function RecalculateListSizeAndPosition()
		local ViewH = Camera.ViewportSize.Y
		local ButtonY = DropdownInner.AbsolutePosition.Y
		local ButtonH = DropdownInner.AbsoluteSize.Y

		local Subtract = Dropdown.Searchable and 42 or 0
		local Add = Dropdown.Searchable and 35 or 0
		local TargetHeight = DropdownListLayout.AbsoluteContentSize.Y + 10 + Add

		local SpaceBelow = math.max(100, ViewH - (ButtonY + ButtonH) - 75)
		local SpaceAbove = math.max(100, ButtonY - 55)

		local PreferBelow = SpaceBelow >= 200 or SpaceBelow >= SpaceAbove

		local FinalHeight
		local PosY

		if PreferBelow then
			FinalHeight = math.min(math.min(392 - Subtract, TargetHeight), SpaceBelow)
			PosY = ButtonY + ButtonH + 2
		else
			FinalHeight = math.min(math.min(392 - Subtract, TargetHeight), SpaceAbove)
			PosY = ButtonY - FinalHeight - 2
		end

		DropdownHolderCanvas.Size = UDim2.fromOffset(ListSizeX, FinalHeight)
		DropdownHolderCanvas.Position = UDim2.fromOffset(DropdownInner.AbsolutePosition.X - 1, PosY)

		if Dropdown.Opened then
			DropdownHolderFrame.Size = UDim2.fromScale(1, 1)
		end
	end

	local function RecalculateCanvasSize()
		DropdownScrollFrame.CanvasSize = UDim2.fromOffset(0, DropdownListLayout.AbsoluteContentSize.Y + 10)
	end

	local function FilterDropdownList()
		if not Dropdown.Built then return end
		local Query = string.lower(SearchBox.Text)
		local IsFiltered = Dropdown.Searchable and Query ~= ""
		local MatchingCount = 0

		for _, item in ipairs(Dropdown.ButtonsList) do
			local text = tostring(Dropdown.Displayer(item.Value))
			local Matches = (not IsFiltered) or (string.find(string.lower(text), Query, 1, true) ~= nil)
			item.Button.Visible = Matches
			if Matches then
				MatchingCount += 1
			end
		end

		if Config.Multi and AllButton and NoneButton then
			local Show = MatchingCount > 0
			AllButton.Visible = Show
			NoneButton.Visible = Show
			if AllButtonLabel then
				AllButtonLabel.Text = IsFiltered and "[ Select Filtered ]" or "[ Select All ]"
			end
			if NoneButtonLabel then
				NoneButtonLabel.Text = IsFiltered and "[ Clear Filtered ]" or "[ Clear All ]"
			end
		end

		RecalculateCanvasSize()
		RecalculateListSizeAndPosition()
	end

	RecalculateListSizeAndPosition()

	dropdownConns[#dropdownConns + 1] = DropdownInner:GetPropertyChangedSignal("AbsolutePosition"):Connect(RecalculateListSizeAndPosition)
	if self.Library.WindowFrame then
		dropdownConns[#dropdownConns + 1] = self.Library.WindowFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
			if Dropdown.Opened then
				RecalculateListSizeAndPosition()
			end
		end)
	end
	dropdownConns[#dropdownConns + 1] = SearchBox:GetPropertyChangedSignal("Text"):Connect(FilterDropdownList)
	dropdownConns[#dropdownConns + 1] = DropdownListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		RecalculateCanvasSize()
		if Dropdown.Opened then
			RecalculateListSizeAndPosition()
		end
	end)

	local ScrollFrame = self.ScrollFrame
	function Dropdown:Open()
		Dropdown.Opened = true
		ScrollFrame.ScrollingEnabled = false
		DropdownHolderCanvas.Visible = true
		DropdownHolderFrame.Size = UDim2.fromScale(1, 1)

		TweenService:Create(DropdownIco, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Rotation = 180
		}):Play()

		if not Dropdown.Built then
			Dropdown:BuildDropdownList()
		end

		RecalculateListSizeAndPosition()

		if Dropdown.Searchable then
			SearchBox.Text = ""
			FilterDropdownList()
			
			if Dropdown.FocusSearch then
				SearchBox:CaptureFocus()
			end
		end
	end

	function Dropdown:Close()
		Dropdown.Opened = false
		ScrollFrame.ScrollingEnabled = true
		DropdownHolderFrame.Size = UDim2.fromScale(1, 0.6)
		DropdownHolderCanvas.Visible = false

		TweenService:Create(DropdownIco, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Rotation = 0
		}):Play()

		if Dropdown.Searchable then
			SearchBox.Text = ""
			SearchBox:ReleaseFocus()
		end
	end

	local function IsPointInGui(point: Vector2, gui: GuiObject): boolean
		if not gui then return false end
		local absPos = gui.AbsolutePosition
		local absSize = gui.AbsoluteSize
		return point.X >= absPos.X and point.X <= (absPos.X + absSize.X)
			and point.Y >= absPos.Y and point.Y <= (absPos.Y + absSize.Y)
	end

	dropdownConns[#dropdownConns + 1] = DropdownInner.MouseButton1Click:Connect(function()
		if Dropdown.Opened then
			Dropdown:Close()
		else
			Dropdown:Open()
		end
	end)

	dropdownConns[#dropdownConns + 1] = UserInputService.InputBegan:Connect(function(Input)
		if not Dropdown.Opened then return end

		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			local clickPos = Vector2.new(Input.Position.X, Input.Position.Y)
			if IsPointInGui(clickPos, DropdownHolderFrame) or IsPointInGui(clickPos, DropdownInner) then
				return
			end
			Dropdown:Close()
		end
	end)

	local Window = self.Library.CreatedWindow
	if Window and Window.Root then
		dropdownConns[#dropdownConns + 1] = Window.Root:GetPropertyChangedSignal("Visible"):Connect(function()
			if not Window.Root.Visible and Dropdown.Opened then
				Dropdown:Close()
			end
		end)
	end

	if self.Container then
		dropdownConns[#dropdownConns + 1] = self.Container:GetPropertyChangedSignal("Visible"):Connect(function()
			if not self.Container.Visible and Dropdown.Opened then
				Dropdown:Close()
			end
		end)
	end

	function Dropdown:Display()
		local Values = Dropdown.Values
		local Str = ""

		if Config.Multi then
			for Idx, Value in next, Values do
				if Dropdown.Value[Value] then
					Str = `{Str}{Dropdown.Displayer(Value)}, `
				end
			end
			Str = Str:sub(1, #Str - 2)
		else
			Str = Dropdown.Value and Dropdown.Displayer(Dropdown.Value) or ""
		end

		DropdownDisplay.Text = (Str == "" and "--" or Str)
	end

	function Dropdown:GetActiveValues()
		if Config.Multi then
			local Values = {}

			for Value, Bool in next, Dropdown.Value do
				Values[#Values + 1] = Value
			end

			return Values
		else
			return Dropdown.Value and 1 or 0
		end
	end

	function Dropdown:BuildDropdownList()
		local Values = Dropdown.Values

		for _, Element in next, DropdownScrollFrame:GetChildren() do
			if not Element:IsA("UIListLayout") then
				local data = optionCleanup[Element]
				if data then
					for _, obj in data.registry do
						Creator.Registry[obj] = nil
					end
					for _, conn in data.conns do
						conn:Disconnect()
					end
					optionCleanup[Element] = nil
				end
				Element:Destroy()
			end
		end

		table.clear(Dropdown.Buttons)
		table.clear(Dropdown.ButtonsList)
		AllButton = nil
		NoneButton = nil
		AllButtonLabel = nil
		NoneButtonLabel = nil

		local Query = (Dropdown.Searchable and SearchBox.Text ~= "") and string.lower(SearchBox.Text) or ""
		local IsFiltered = Query ~= ""

		if Config.Multi then
			-- Select All / Filtered Option
			AllButton = Button_BuildList:Clone()
			local AllButtonSelector = AllButton.Frame
			AllButtonLabel = AllButton.ButtonLabel
			AllButton.LayoutOrder = 1

			AllButtonSelector.BackgroundTransparency = 1
			AllButtonSelector.Size = UDim2.new(0, 0, 0, 0)
			AllButtonLabel.Text = IsFiltered and "[ Select Filtered ]" or "[ Select All ]"
			AllButtonLabel.TextColor3 = Color3.fromRGB(80, 180, 255)

			local AllConns = {}
			AllConns[#AllConns + 1] = AllButton.MouseEnter:Connect(function()
				AllButton.BackgroundTransparency = 0.89
			end)
			AllConns[#AllConns + 1] = AllButton.MouseLeave:Connect(function()
				AllButton.BackgroundTransparency = 1
			end)

			local function DoSelectAll()
				local tbl = {}
				for val, bool in next, Dropdown.Value do
					tbl[val] = true
				end
				local activeQuery = (Dropdown.Searchable and SearchBox.Text ~= "") and string.lower(SearchBox.Text) or ""
				for _, val in next, Dropdown.Values do
					local text = tostring(Dropdown.Displayer(val))
					if activeQuery == "" or string.find(string.lower(text), activeQuery, 1, true) then
						tbl[val] = true
					end
				end
				Dropdown:SetValue(tbl)
			end
			AllConns[#AllConns + 1] = AllButton.Activated:Connect(DoSelectAll)

			optionCleanup[AllButton] = {
				registry = { AllButton, AllButtonSelector, AllButtonLabel },
				conns = AllConns,
			}
			AllButton.Parent = DropdownScrollFrame

			-- Clear All / Filtered Option
			NoneButton = Button_BuildList:Clone()
			local NoneButtonSelector = NoneButton.Frame
			NoneButtonLabel = NoneButton.ButtonLabel
			NoneButton.LayoutOrder = 2

			NoneButtonSelector.BackgroundTransparency = 1
			NoneButtonSelector.Size = UDim2.new(0, 0, 0, 0)
			NoneButtonLabel.Text = IsFiltered and "[ Clear Filtered ]" or "[ Clear All ]"
			NoneButtonLabel.TextColor3 = Color3.fromRGB(255, 100, 100)

			local NoneConns = {}
			NoneConns[#NoneConns + 1] = NoneButton.MouseEnter:Connect(function()
				NoneButton.BackgroundTransparency = 0.89
			end)
			NoneConns[#NoneConns + 1] = NoneButton.MouseLeave:Connect(function()
				NoneButton.BackgroundTransparency = 1
			end)

			local function DoSelectNone()
				local tbl = {}
				for val, bool in next, Dropdown.Value do
					tbl[val] = true
				end
				local activeQuery = (Dropdown.Searchable and SearchBox.Text ~= "") and string.lower(SearchBox.Text) or ""
				for _, val in next, Dropdown.Values do
					local text = tostring(Dropdown.Displayer(val))
					if activeQuery == "" or string.find(string.lower(text), activeQuery, 1, true) then
						tbl[val] = nil
					end
				end
				Dropdown:SetValue(tbl)
			end
			NoneConns[#NoneConns + 1] = NoneButton.Activated:Connect(DoSelectNone)

			optionCleanup[NoneButton] = {
				registry = { NoneButton, NoneButtonSelector, NoneButtonLabel },
				conns = NoneConns,
			}
			NoneButton.Parent = DropdownScrollFrame
		end

		local MatchingCount = 0

		for Idx, Value in next, Values do
			local Button = Button_BuildList:Clone()
			local ButtonSelector, ButtonLabel = Button.Frame, Button.ButtonLabel
			Button.LayoutOrder = Idx + 2

			Creator.AddThemeObject(Button, {
				BackgroundColor3 = "DropdownOption"
			})

			Creator.AddThemeObject(ButtonSelector, {
				BackgroundColor3 = "Accent",
			})

			Creator.AddThemeObject(ButtonLabel, {
				TextColor3 = "Text"
			})

			local isSelected = false
			local function SetBackTransparency(val)
				Button.BackgroundTransparency = val
			end
			local function SetSelTransparency(val)
				ButtonSelector.BackgroundTransparency = val
			end
			local function SetSelectorSize(val)
				ButtonSelector.Size = UDim2.new(0, 4, 0, val)
			end

			local item = {}
			item.Button = Button
			item.Selector = ButtonSelector
			item.Label = ButtonLabel
			item.Value = Value

			function item:UpdateButton()
				if Config.Multi then
					isSelected = Dropdown.Value[Value] == true
				else
					isSelected = Dropdown.Value == Value
				end

				SetBackTransparency(isSelected and 0.89 or 1)
				SetSelectorSize(isSelected and 14 or 6)
				SetSelTransparency(isSelected and 0 or 1)
			end

			local optionConns = {}
			optionConns[#optionConns + 1] = Button.MouseEnter:Connect(function()
				SetBackTransparency(isSelected and 0.85 or 0.89)
			end)
			optionConns[#optionConns + 1] = Button.MouseLeave:Connect(function()
				SetBackTransparency(isSelected and 0.89 or 1)
			end)
			optionConns[#optionConns + 1] = Button.MouseButton1Down:Connect(function()
				SetBackTransparency(0.92)
			end)
			optionConns[#optionConns + 1] = Button.MouseButton1Up:Connect(function()
				SetBackTransparency(isSelected and 0.85 or 0.89)
			end)

			local function OnSelect()
				local try = not isSelected

				if Dropdown:GetActiveValues() == 1 and not try and not Config.AllowNull then
				else
					if Config.Multi then
						isSelected = try
						Dropdown.Value[Value] = isSelected and true or nil
						item:UpdateButton()
						Dropdown:Display()

						if typeof(Dropdown.Callback) == "function" then
							Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
						end
						if typeof(Dropdown.Changed) == "function" then
							Library:SafeCallback(Dropdown.Changed, Dropdown.Value)
						end
					else
						isSelected = try
						Dropdown:SetValue(isSelected and Value or nil)
					end
				end
			end
			optionConns[#optionConns + 1] = Button.InputEnded:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.Touch then
					SetBackTransparency(isSelected and 0.89 or 1)
				end
			end)
			optionConns[#optionConns + 1] = Button.Activated:Connect(OnSelect)

			optionCleanup[Button] = {
				registry = { Button, ButtonSelector, ButtonLabel },
				conns = optionConns,
			}

			local displayStr = tostring(Dropdown.Displayer(Value))
			ButtonLabel.Text = displayStr

			local isMatch = (not IsFiltered) or (string.find(string.lower(displayStr), Query, 1, true) ~= nil)
			Button.Visible = isMatch
			if isMatch then
				MatchingCount += 1
			end

			Button.Parent = DropdownScrollFrame

			item:UpdateButton()

			Dropdown.Buttons[Value] = item
			Dropdown.ButtonsList[#Dropdown.ButtonsList + 1] = item
		end

		if Config.Multi and AllButton and NoneButton then
			local Show = MatchingCount > 0
			AllButton.Visible = Show
			NoneButton.Visible = Show
		end

		ListSizeX = 0
		for _, item in ipairs(Dropdown.ButtonsList) do
			if item.Label and item.Label.TextBounds.X > ListSizeX then
				ListSizeX = item.Label.TextBounds.X
			end
		end

		ListSizeX = ListSizeX + 30
		Dropdown.Built = true

		RecalculateCanvasSize()
		RecalculateListSizeAndPosition()
	end

	function Dropdown:SetValues(NewValues)
		if NewValues then
			local Idxes = {}
			for _, v in next, NewValues do
				Idxes[#Idxes + 1] = v
			end
			rawset(Dropdown, "Values", Idxes)
		end

		if Dropdown.Opened then
			Dropdown:BuildDropdownList()
		else
			Dropdown.Built = false
			for _, Element in next, DropdownScrollFrame:GetChildren() do
				if not Element:IsA("UIListLayout") then
					local data = optionCleanup[Element]
					if data then
						for _, obj in data.registry do
							Creator.Registry[obj] = nil
						end
						for _, conn in data.conns do
							conn:Disconnect()
						end
						optionCleanup[Element] = nil
					end
					Element:Destroy()
				end
			end
			table.clear(Dropdown.Buttons)
			table.clear(Dropdown.ButtonsList)
		end

		Dropdown:Display()
	end

	function Dropdown:OnChanged(Func)
		Dropdown.Changed = Func
		Library:SafeCallback(Func, Dropdown.Value, Dropdown.Value)
	end

	function Dropdown:SetValue(Val)
		if Dropdown.Multi then
			local nTable = {}

			if Val then
				for Key, Value in next, Val do
					if type(Key) == "number" and type(Value) == "string" then
						if table.find(Dropdown.Values, Value) then
							nTable[Value] = true
						end
					elseif Value == true and table.find(Dropdown.Values, Key) then
						nTable[Key] = true
					end
				end
			end

			rawset(Dropdown, "Value", nTable)
		else
			if not Val then
				rawset(Dropdown, "Value", nil)
			elseif table.find(Dropdown.Values, Val) then
				rawset(Dropdown, "Value", Val)
			end
		end

		Dropdown:Display()

		if Dropdown.Built then
			for _, item in ipairs(Dropdown.ButtonsList) do
				item:UpdateButton()
			end
		end

		if typeof(Dropdown.Callback) == "function" then
			Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
		end
		if typeof(Dropdown.Changed) == "function" then
			Library:SafeCallback(Dropdown.Changed, Dropdown.Value)
		end
	end

	function Dropdown:Destroy()
		for _, conn in dropdownConns do
			conn:Disconnect()
		end
		table.clear(dropdownConns)

		for btn, data in optionCleanup do
			for _, obj in data.registry do
				Creator.Registry[obj] = nil
			end
			for _, conn in data.conns do
				conn:Disconnect()
			end
			optionCleanup[btn] = nil
		end
		table.clear(optionCleanup)
		table.clear(Dropdown.Buttons)
		table.clear(Dropdown.ButtonsList)

		for i, v in ipairs(Library.OpenFrames) do
			if v == DropdownHolderCanvas then
				table.remove(Library.OpenFrames, i)
				break
			end
		end

		DropdownHolderCanvas:Destroy()
		DropdownFrame:Destroy()
		Library.Options[Idx] = nil
	end

	Dropdown:Display()

	Library.Options[Idx] = Dropdown

	Dropdown.Instance = DropdownFrame

	return setmetatable(Dropdown, {
		__newindex = function(self, index, newvalue)
			if index == "Value" then
				task.spawn(Dropdown.SetValue, Dropdown, newvalue)
			elseif index == "Values" or index == "List" then
				task.spawn(Dropdown.SetValues, Dropdown, newvalue)
			end
			rawset(self, index, newvalue)
		end
	})
end

return Element
