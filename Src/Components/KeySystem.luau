local Root = script.Parent.Parent
local Creator = require(Root.Modules.Creator)
local Flipper = require(Root.Packages.Flipper)
local Services = require(Root.Modules.Services)
local ButtonFactory = require(Root.Components.Button)
local Icons = require(Root.Modules.Icons)

local New = Creator.New

local KeySystem = {}

function KeySystem.Show(Config, Library, Callback)
	local BaseContainer = Library.GUI
	local serviceInstances = {}
	local enteredKey = ""
	local isClosing = false

	local HasThumbnail = Config.Thumbnail and Config.Thumbnail.Image
	local ThumbnailWidth = HasThumbnail and (Config.Thumbnail.Width or 200) or 0
	local PaddingX = ThumbnailWidth + 20
	local TotalWidth = 400 + ThumbnailWidth

	local HasNote = Config.Note and Config.Note ~= ""
	local NoteHeight = 36                -- room for ~4 lines at TextSize 13
	local InputY = HasNote and (48 + NoteHeight + 10) or 60
	local RootHeight = InputY + 36 + 16 + 50 -- InputFrame bottom + tight gap + button row reserve

	local RootFrame = New("CanvasGroup", {
		Active = true,
		Size = UDim2.fromOffset(TotalWidth, RootHeight),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		GroupTransparency = 1,
		ZIndex = 11,
		Parent = BaseContainer,
		ThemeTag = { BackgroundColor3 = "Dialog" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		New("UIStroke", {
			Transparency = 0.5,
			ThemeTag = { Color = "DialogBorder" },
		}),
	})

	local RootMotor, RootTransparency = Creator.SpringMotor(1, RootFrame, "GroupTransparency")

	local function close()
		if isClosing then return end
		isClosing = true
		RootTransparency(1)
		task.delay(0.2, function()
			RootFrame:Destroy()
		end)
	end

	local CloseButton = New("ImageButton", {
		Image = "rbxassetid://9886659671",
		Size = UDim2.fromOffset(20, 20),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -18, 0, 20),
		BackgroundTransparency = 1,
		ZIndex = 12,
		Parent = RootFrame,
		ThemeTag = { ImageColor3 = "Text" },
	})

	Creator.AddSignal(CloseButton.MouseEnter, function()
		CloseButton.ImageTransparency = 0.3
	end)
	Creator.AddSignal(CloseButton.MouseLeave, function()
		CloseButton.ImageTransparency = 0
	end)
	Creator.AddSignal(CloseButton.MouseButton1Click, function()
		close()
		Callback(false)
	end)

	local TitleLabel = New("TextLabel", {
		FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
		Text = Config.Title or "Key System",
		TextSize = 20,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -PaddingX - 40, 0, 22),
		Position = UDim2.fromOffset(PaddingX, 20),
		BackgroundTransparency = 1,
		Parent = RootFrame,
		ThemeTag = { TextColor3 = "Text" },
	})

	if Config.Note and Config.Note ~= "" then
		New("TextLabel", {
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
			Text = Config.Note,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Top,
			TextWrapped = true,
			Size = UDim2.new(1, -PaddingX - 20, 0, NoteHeight),
			Position = UDim2.fromOffset(PaddingX, 48),
			BackgroundTransparency = 1,
			Parent = RootFrame,
			ThemeTag = { TextColor3 = "SubText" },
		})
	end

	local InputFrame = New("Frame", {
		Size = UDim2.new(1, -PaddingX - 20, 0, 36),
		Position = UDim2.fromOffset(PaddingX, InputY),
		BackgroundTransparency = 0,
		Parent = RootFrame,
		ThemeTag = { BackgroundColor3 = "DialogInput" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 4) }),
		New("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Transparency = 0.65,
			ThemeTag = { Color = "DialogButtonBorder" },
		}),
	})

	local InputBox = New("TextBox", {
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
		TextColor3 = Color3.fromRGB(200, 200, 200),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -20, 1, 0),
		Position = UDim2.fromOffset(10, 0),
		PlaceholderText = "Enter key...",
		Parent = InputFrame,
		ThemeTag = { TextColor3 = "Text", PlaceholderColor3 = "SubText" },
	})

	Creator.AddSignal(InputBox:GetPropertyChangedSignal("Text"), function()
		enteredKey = InputBox.Text
	end)

	local ButtonContainer = New("Frame", {
		Size = UDim2.new(1, -PaddingX - 20, 0, 34),
		Position = UDim2.new(0, PaddingX, 1, -50),
		BackgroundTransparency = 1,
		Parent = RootFrame,
	}, {
		New("UIListLayout", {
			Padding = UDim.new(0, 8),
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	local function handleSuccess(key)
		close()
		if Config.SaveKey then
			local hwid = gethwid and gethwid() or game:GetService("Players").LocalPlayer.UserId
			local folder = Config.KeyFolder or "FluentTemp"
			if writefile and isfolder and not isfolder(folder) and makefolder then
				makefolder(folder)
			end
			pcall(function()
				if writefile then
					writefile(folder .. "/" .. tostring(hwid) .. ".key", tostring(key))
				end
			end)
		end
		task.wait(0.3)
		Callback(true)
	end

	local function handleFail(message)
		Library:Notify({
			Title = "Key System",
			Content = message or "Invalid key.",
			Duration = 4,
		})
	end

	local function submitKey()
		local key = tostring(enteredKey or "")
		if key == "" then
			handleFail("Please enter a key.")
			return
		end

		if Config.KeyValidator then
			local success, result = pcall(Config.KeyValidator, key)
			if success and result then
				handleSuccess(key)
			else
				handleFail(result or "Invalid key.")
			end
		elseif Config.API then
			if #serviceInstances == 0 then
				handleFail("No API services available in this environment.")
				return
			end
			local isSuccess, result
			for _, service in next, serviceInstances do
				local pcallOk, verifyOk, verifyMsg = pcall(service.Verify, key)
				if pcallOk and verifyOk then
					isSuccess = true
					result = verifyMsg or ""
					break
				elseif pcallOk then
					result = (verifyMsg and #verifyMsg > 0) and verifyMsg or "Key validation failed."
				else
					result = "API error: " .. tostring(verifyOk)
				end
			end
			if isSuccess then
				handleSuccess(key)
			else
				handleFail(result or "Key validation failed.")
			end
		elseif Config.Key then
			local isMatch = type(Config.Key) == "table" and table.find(Config.Key, key) or Config.Key == key
			if isMatch then
				handleSuccess(key)
			else
				handleFail("Invalid key.")
			end
		else
			handleFail("No key validation configured.")
		end
	end

	Creator.AddSignal(InputBox.FocusLost, function(enterPressed)
		if enterPressed then
			submitKey()
		end
	end)

	if Config.URL then
		local GetKeyButton = ButtonFactory("", ButtonContainer, true)
		GetKeyButton.Title.Text = "Get Key"
		GetKeyButton.Frame.Size = UDim2.fromOffset(80, 32)
		GetKeyButton.Frame.LayoutOrder = 1
		Creator.AddSignal(GetKeyButton.Frame.MouseButton1Click, function()
			local clip = setclipboard or toclipboard
			if clip then
				clip(Config.URL)
			end
			Library:Notify({
				Title = "Key System",
				Content = clip and "Key link copied to clipboard." or "Clipboard not available in this environment.",
				Duration = 3,
			})
		end)
	end

	if Config.API then
		local serviceList = {}
		for _, entry in next, Config.API do
			local serviceDef = Services[entry.Type]
			if serviceDef then
				local args = {}
				for _, argName in next, serviceDef.Args do
					table.insert(args, entry[argName])
				end
				local success, instance = pcall(serviceDef.New, table.unpack(args))
				if success and instance then
					table.insert(serviceInstances, instance)
					table.insert(serviceList, {
						Instance = instance,
						Def = serviceDef,
						Config = entry,
					})
				end
			end
		end

		if #serviceList > 0 then
			local DropdownOpen = false
			local DropdownWidth = 220

			local GetKeyButton = ButtonFactory("", ButtonContainer, true)
			GetKeyButton.Title.Text = "Get Key"
			GetKeyButton.Frame.Size = UDim2.fromOffset(100, 32)
			GetKeyButton.Frame.LayoutOrder = 1

			local ChevronIcon = New("ImageLabel", {
				Image = Icons["chevron-down"].Image,
				ImageRectSize = Icons["chevron-down"].ImageRectSize,
				ImageRectOffset = Icons["chevron-down"].ImageRectOffset,
				Size = UDim2.fromOffset(14, 14),
				BackgroundTransparency = 1,
				Parent = GetKeyButton.Frame,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -4, 0.5, 0),
				ThemeTag = { ImageColor3 = "Text" },
			})

			local DropdownFrame = New("Frame", {
				Size = UDim2.fromOffset(DropdownWidth, 0),
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.new(1, 0, 0, -4),
				BackgroundTransparency = 1,
				ClipsDescendants = true,
				ZIndex = 12,
				Parent = GetKeyButton.Frame,
			})

			local DropdownInner = New("Frame", {
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Position = UDim2.fromOffset(0, 0),
				BackgroundTransparency = 0,
				ThemeTag = { BackgroundColor3 = "DialogHolder" },
				Parent = DropdownFrame,
			}, {
				New("UICorner", { CornerRadius = UDim.new(0, 6) }),
				New("UIStroke", {
					Transparency = 0.5,
					ThemeTag = { Color = "DialogBorder" },
				}),
				New("UIListLayout", {
					Padding = UDim.new(0, 2),
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
				New("UIPadding", {
					PaddingTop = UDim.new(0, 6),
					PaddingBottom = UDim.new(0, 6),
					PaddingLeft = UDim.new(0, 6),
					PaddingRight = UDim.new(0, 6),
				}),
			})

			local function toggleDropdown()
				DropdownOpen = not DropdownOpen
				local targetHeight = DropdownOpen and DropdownInner.AbsoluteSize.Y or 0
				local chevronTarget = DropdownOpen and 180 or 0

				RootMotor:stop()
				local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint)
				game:GetService("TweenService"):Create(DropdownFrame, tweenInfo, {
					Size = UDim2.fromOffset(DropdownWidth, targetHeight),
				}):Play()

				game:GetService("TweenService"):Create(ChevronIcon, tweenInfo, {
					Rotation = chevronTarget,
				}):Play()
			end

			for _, item in next, serviceList do
				local ItemBtn = New("TextButton", {
					Text = "",
					Size = UDim2.new(1, 0, 0, 36),
					BackgroundTransparency = 1,
					Parent = DropdownInner,
				})

				local defIcon = item.Def.Icon
				local ico = nil

				if type(defIcon) == "string" and defIcon:find("^rbxassetid://") then
					ico = { Image = defIcon }
				elseif type(defIcon) == "string" then
					local found = Icons[defIcon]
					if type(found) == "string" then
						ico = { Image = found }
					elseif type(found) == "table" then
						ico = found
					end
				end
				if not ico then
					ico = Icons.key
				end

				local ItemIcon = New("ImageLabel", {
					Image = ico.Image,
					ImageRectSize = ico.ImageRectSize,
					ImageRectOffset = ico.ImageRectOffset,
					Size = UDim2.fromOffset(18, 18),
					Position = UDim2.fromOffset(8, 9),
					BackgroundTransparency = 1,
					Parent = ItemBtn,
					ThemeTag = { ImageColor3 = "Text" },
				})

				local ItemLabel = New("TextLabel", {
					FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
					Text = item.Config.Title or item.Def.Name,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
					Size = UDim2.new(1, -34, 1, 0),
					Position = UDim2.fromOffset(32, 0),
					BackgroundTransparency = 1,
					Parent = ItemBtn,
					ThemeTag = { TextColor3 = "Text" },
				})

				Creator.AddSignal(ItemBtn.MouseEnter, function()
					ItemBtn.BackgroundTransparency = 0.9
					ItemBtn.BackgroundColor3 = Creator.GetThemeProperty("Hover")
				end)
				Creator.AddSignal(ItemBtn.MouseLeave, function()
					ItemBtn.BackgroundTransparency = 1
				end)
				Creator.AddSignal(ItemBtn.MouseButton1Click, function()
					local ok, msg = pcall(item.Instance.Copy)
					local content
					if item.Instance.Unavailable then
						content = "Service unavailable in this environment."
					elseif not ok then
						content = "Copy failed: " .. tostring(msg)
					elseif msg ~= nil and msg ~= true then
						content = tostring(msg)
					else
						content = "Key link copied to clipboard."
					end
					Library:Notify({
						Title = "Key System",
						Content = content,
						Duration = 3,
					})
					toggleDropdown()
				end)
			end

			Creator.AddSignal(GetKeyButton.Frame.MouseButton1Click, toggleDropdown)
		end
	end

	local SubmitButton = ButtonFactory("", ButtonContainer, true)
	SubmitButton.Title.Text = "Submit"
	SubmitButton.Frame.Size = UDim2.fromOffset(90, 32)
	SubmitButton.Frame.LayoutOrder = 2

	Creator.OverrideTag(SubmitButton.Frame, {
		BackgroundColor3 = "Accent",
	})
	SubmitButton.Title.TextColor3 = Color3.fromRGB(0, 0, 0)

	Creator.AddSignal(SubmitButton.Frame.MouseButton1Click, submitKey)

	if HasThumbnail then
		local ThumbnailFrame = New("ImageLabel", {
			Image = Config.Thumbnail.Image,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, ThumbnailWidth - 12, 1, -12),
			Position = UDim2.fromOffset(6, 6),
			Parent = RootFrame,
			ScaleType = Enum.ScaleType.Crop,
		}, {
			New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		})

		if Config.Thumbnail.Title then
			New("TextLabel", {
				Text = Config.Thumbnail.Title,
				TextSize = 18,
				FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.XY,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Parent = ThumbnailFrame,
				ThemeTag = { TextColor3 = "Text" },
			})
		end
	end

	RootTransparency(0)
end

return KeySystem
