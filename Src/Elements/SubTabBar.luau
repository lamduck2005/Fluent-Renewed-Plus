-- Placed in Elements instead of Components to leverage Fluent's automatic element registration without modifying core framework files.
local Root = script.Parent.Parent
local Creator = require(Root.Modules.Creator)
local New = Creator.New

local TweenService = game:GetService("TweenService")

local Element = {}
Element.__index = Element
Element.__type = "SubTabBar"

function Element:New(Idx, Config)
	if Config == nil then
		Config = Idx
		Idx = nil
	end

	local Options = Config.SubTabs or Config.Values
	assert(Options and #Options > 0, "SubTabBar - Missing SubTabs or Values")
	local Default = Config.Default or Options[1]

	local Library = self.Library
	local Elements = Library.Elements

	local NavigationWrapper = New("Frame", {
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1,
		LayoutOrder = 7,
		Parent = self.Container,
	})

	local NavigationBar = New("ScrollingFrame", {
		Size = UDim2.new(1, 0, 0, 36),
		Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Parent = NavigationWrapper,
		ScrollingDirection = Enum.ScrollingDirection.X,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ClipsDescendants = true,
		BorderSizePixel = 0,
	}, {
		New("UIListLayout", {
			FillDirection = "Horizontal",
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		New("UIPadding", {
			PaddingTop = UDim.new(0, 2),
			PaddingBottom = UDim.new(0, 2),
			PaddingLeft = UDim.new(0, 2),
			PaddingRight = UDim.new(0, 2),
		})
	})

	local NavigationLayout = NavigationBar:FindFirstChildOfClass("UIListLayout")
	Creator.AddSignal(NavigationLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		NavigationBar.CanvasSize = UDim2.new(0, NavigationLayout.AbsoluteContentSize.X + 4, 0, 0)
	end)

	local ContentWrapper = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = "Y",
		BackgroundTransparency = 1,
		LayoutOrder = 7,
		Parent = self.Container,
	})

	local SubTabContainers = {}
	local Buttons = {}

	local function SelectSubTab(selectedOption)
		for option, container in pairs(SubTabContainers) do
			if option ~= selectedOption and container.Container.Visible then
				local frame = container.Container
				local tween = TweenService:Create(frame, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					GroupTransparency = 1,
					Position = UDim2.fromOffset(-15, 0)
				})
				tween:Play()
				task.delay(0.12, function()
					if Default ~= option then
						frame.Visible = false
					end
				end)
			end
		end

		local activeContainer = SubTabContainers[selectedOption].Container
		activeContainer.Visible = true
		activeContainer.Position = UDim2.fromOffset(15, 0)
		activeContainer.GroupTransparency = 1

		TweenService:Create(activeContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			GroupTransparency = 0,
			Position = UDim2.fromOffset(0, 0)
		}):Play()

		for option, button in pairs(Buttons) do
			local isSelected = (option == selectedOption)
			local stroke = button:FindFirstChildOfClass("UIStroke")
			if stroke then
				Creator.OverrideTag(stroke, { Color = isSelected and "Accent" or "InElementBorder" })
				TweenService:Create(stroke, TweenInfo.new(0.15), {
					Transparency = isSelected and 0 or 0.6
				}):Play()
			end

			local text = button:FindFirstChildOfClass("TextLabel")
			if text then
				TweenService:Create(text, TweenInfo.new(0.15), {
					TextTransparency = isSelected and 0 or 0.4
				}):Play()
			end
		end
	end

	for index, option in ipairs(Options) do
		local ContainerFrame = New("CanvasGroup", {
			Name = option .. "Container",
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = "Y",
			BackgroundTransparency = 1,
			GroupTransparency = 1,
			Parent = ContentWrapper,
			Visible = false,
		}, {
			New("UIListLayout", {
				Padding = UDim.new(0, 5),
				SortOrder = Enum.SortOrder.LayoutOrder,
			})
		})

		local SubTabObject = {
			Container = ContainerFrame,
			ScrollFrame = self.ScrollFrame,
			Type = "SubTabContainer",
		}

		function SubTabObject:Section(SectionTitle)
			local Section = {
				Type = "Section"
			}
			local SectionFrame = require(Root.Components.Section)(SectionTitle, ContainerFrame)
			Section.Container = SectionFrame.Container
			Section.ScrollFrame = self.ScrollFrame
			setmetatable(Section, Elements)
			return Section
		end

		SubTabObject.CreateSection = SubTabObject.Section
		SubTabObject.AddSection = SubTabObject.Section

		setmetatable(SubTabObject, Elements)
		SubTabContainers[option] = SubTabObject

		local Button = New("TextButton", {
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = "X",
			BackgroundTransparency = 1,
			Text = "",
			LayoutOrder = index,
			Parent = NavigationBar,
		}, {
			New("UICorner", { CornerRadius = UDim.new(1, 0) }),
			New("UIStroke", {
				Thickness = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Transparency = 0.6,
				ThemeTag = {
					Color = "InElementBorder",
				}
			}),
			New("UIPadding", {
				PaddingLeft = UDim.new(0, 12),
				PaddingRight = UDim.new(0, 12),
			}),
			New("TextLabel", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Text = option,
				TextSize = 12,
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
				ThemeTag = {
					TextColor3 = "Text",
				}
			})
		})

		Buttons[option] = Button

		Creator.AddSignal(Button.MouseEnter, function()
			if Default ~= option then
				TweenService:Create(Button, TweenInfo.new(0.15), { BackgroundTransparency = 0.95 }):Play()
			end
		end)
		Creator.AddSignal(Button.MouseLeave, function()
			if Default ~= option then
				TweenService:Create(Button, TweenInfo.new(0.15), { BackgroundTransparency = 1 }):Play()
			end
		end)

		Creator.AddSignal(Button.MouseButton1Click, function()
			Default = option
			SelectSubTab(option)
		end)
	end

	task.defer(SelectSubTab, Default)

	return SubTabContainers
end

return Element
