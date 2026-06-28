local Creator = require(script.Parent.Parent.Modules.Creator)
local KeyServices = require(script.Parent.KeyServices)
local Icons = require(script.Parent.Parent.Modules.Icons)

local New = Creator.New

local setClipboard = setclipboard or set_clipboard or (Clipboard and Clipboard.set) or (syn and syn.write_clipboard) or function() end
local writeFile = writefile or function() end
local readFile = readfile or function() return "" end
local isFile = isfile or function() return false end
local delFile = delfile or function() end

local function getIconData(name)
	if typeof(name) ~= "string" then
		return "", Vector2.new(0, 0), Vector2.new(0, 0)
	end
	local data = name ~= "SetIcon" and Icons[name] or nil
	if data then
		return data.Image, data.ImageRectSize, data.ImageRectOffset
	end
	return "", Vector2.new(0, 0), Vector2.new(0, 0)
end

local KeySystem = {}

function KeySystem.new(Library, Config, Filename, callback)
	local Services = {}
	local EnteredKey

	local ThumbnailSize = (Config.KeySystem.Thumbnail and Config.KeySystem.Thumbnail.Width) or 200

	local UISize = 430
	if Config.KeySystem.Thumbnail and Config.KeySystem.Thumbnail.Image then
		UISize = 430 + (ThumbnailSize / 2)
	end

	local TintFrame = New("TextButton", {
		Text = "",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		Parent = Library.GUI,
		ZIndex = 1000,
	})

	local DialogScale = New("UIScale", {
		Scale = 1,
	})

	local DialogContent = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	})

	local MainDialog = New("CanvasGroup", {
		Size = UDim2.fromOffset(UISize, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(35, 35, 35),
		BackgroundTransparency = 0.05,
		GroupTransparency = 1,
		Parent = TintFrame,
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
		New("UIStroke", {
			Color = Color3.fromRGB(50, 50, 50),
			Transparency = 0.5,
		}),
		DialogScale,
		DialogContent,
	})

	local function updateDialogSize()
		local h = DialogContent.AbsoluteSize.Y
		if h > 0 then
			MainDialog.Size = UDim2.fromOffset(UISize, h)
		end
	end

	local TintMotor, SetTint = Creator.SpringMotor(1, TintFrame, "BackgroundTransparency", true)
	local RootMotor, SetRoot = Creator.SpringMotor(1, MainDialog, "GroupTransparency")
	local ScaleMotor, SetScale = Creator.SpringMotor(1.1, DialogScale, "Scale")

	local function openDialog()
		DialogScale.Scale = 1.1
		SetTint(0.75)
		SetRoot(0)
		SetScale(1)
	end

	local function closeDialog()
		SetTint(1)
		SetRoot(1)
		SetScale(1.1)
		task.wait(0.15)
		TintFrame:Destroy()
	end

	local IconFrame

	if Config.Icon then
		local iconImg, iconSize, iconOffset = getIconData(Config.Icon)
		IconFrame = New("ImageLabel", {
			Image = iconImg,
			ImageRectSize = iconSize,
			ImageRectOffset = iconOffset,
			Size = UDim2.new(0, 24, 0, 24),
			BackgroundTransparency = 1,
			LayoutOrder = -1,
			ThemeTag = {
				ImageColor3 = "Text",
			},
		})
	end

	local Title = New("TextLabel", {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		Text = Config.KeySystem.Title or Config.Title,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
		TextSize = 20,
		RichText = true,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	local KeySystemTitle = New("TextLabel", {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		Text = "Key System",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		TextTransparency = 1,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
		TextSize = 16,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	local IconAndTitleContainer = New("Frame", {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
	}, {
		New("UIListLayout", {
			Padding = UDim.new(0, 14),
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
		IconFrame,
		Title,
	})

	local TitleContainer = New("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
	}, {
		IconAndTitleContainer,
		KeySystemTitle,
	})

	local InputRow = New("Frame", {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
	}, {
		New("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 6),
		}),
	})

	local InputFrame = New("Frame", {
		Size = UDim2.new(0.6, 0, 1, 0),
		BackgroundTransparency = 1,
		Parent = InputRow,
	})

	local InputBorder = New("Frame", {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Parent = InputFrame,
		ThemeTag = {
			BackgroundColor3 = "DialogInput",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 4),
		}),
		New("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Transparency = 0.65,
			ThemeTag = {
				Color = "DialogButtonBorder",
			},
		}),
	})

	local InputTextBox = New("TextBox", {
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
		TextColor3 = Color3.fromRGB(200, 200, 200),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -12, 1, 0),
		Position = UDim2.fromOffset(10, 0),
		PlaceholderText = "Enter Key",
		PlaceholderColor3 = Color3.fromRGB(160, 160, 160),
		ClearTextOnFocus = false,
		Parent = InputBorder,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	local InputIndicator = New("Frame", {
		Size = UDim2.new(1, -4, 0, 1),
		Position = UDim2.new(0, 2, 1, 0),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 0.5,
		ThemeTag = {
			BackgroundColor3 = "DialogInputLine",
		},
		Parent = InputBorder,
	})

	Creator.AddSignal(InputTextBox.Focused, function()
		InputIndicator.Size = UDim2.new(1, -2, 0, 2)
		InputIndicator.Position = UDim2.new(0, 1, 1, 0)
		InputIndicator.BackgroundTransparency = 0
		Creator.OverrideTag(InputBorder, { BackgroundColor3 = "DialogHolder" })
		Creator.OverrideTag(InputIndicator, { BackgroundColor3 = "Accent" })
	end)

	Creator.AddSignal(InputTextBox.FocusLost, function()
		InputIndicator.Size = UDim2.new(1, -4, 0, 1)
		InputIndicator.Position = UDim2.new(0, 2, 1, 0)
		InputIndicator.BackgroundTransparency = 0.5
		Creator.OverrideTag(InputBorder, { BackgroundColor3 = "DialogInput" })
		Creator.OverrideTag(InputIndicator, { BackgroundColor3 = "DialogInputLine" })
	end)

	Creator.AddSignal(InputTextBox:GetPropertyChangedSignal("Text"), function()
		EnteredKey = InputTextBox.Text
	end)

	local NoteText
	if Config.KeySystem.Note and Config.KeySystem.Note ~= "" then
		NoteText = New("TextLabel", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = Config.KeySystem.Note,
			TextSize = 18,
			TextTransparency = 0.4,
			BackgroundTransparency = 1,
			RichText = true,
			TextWrapped = true,
			ThemeTag = {
				TextColor3 = "Text",
			},
		})
	end

	local ButtonsContainer = New("Frame", {
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundTransparency = 1,
	}, {
		New("Frame", {
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 1, 0),
		}, {
			New("UIListLayout", {
				Padding = UDim.new(0, 9),
				FillDirection = Enum.FillDirection.Horizontal,
			}),
		}),
	})

	local function CreateKeyButton(title, iconName, callback, parent, sizeOverride)
		local iconImg, iconSize, iconOffset = getIconData(iconName)
		local hasIcon = iconImg ~= ""
		local Button = New("TextButton", {
			Text = "",
			AutomaticSize = sizeOverride and Enum.AutomaticSize.None or Enum.AutomaticSize.X,
			Size = sizeOverride or UDim2.new(0, 0, 1, 0),
			BackgroundTransparency = 1,
			Parent = parent,
		})

		local BtnFrame = New("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			AutomaticSize = sizeOverride and Enum.AutomaticSize.None or Enum.AutomaticSize.X,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Parent = Button,
			ThemeTag = {
				BackgroundColor3 = "DialogButton",
			},
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 4),
			}),
			New("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Transparency = 0.65,
				ThemeTag = {
					Color = "DialogButtonBorder",
				},
			}),
		})

		local contentList = {}
		if hasIcon then
			contentList[#contentList + 1] = New("ImageLabel", {
				Image = iconImg,
				ImageRectSize = iconSize,
				ImageRectOffset = iconOffset,
				Size = UDim2.new(0, 16, 0, 16),
				BackgroundTransparency = 1,
				ThemeTag = {
					ImageColor3 = "Text",
				},
			})
		end

		contentList[#contentList + 1] = New("TextLabel", {
			Text = title,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
			TextSize = 14,
			TextColor3 = Color3.fromRGB(200, 200, 200),
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.X,
			TextXAlignment = Enum.TextXAlignment.Left,
			ThemeTag = {
				TextColor3 = "Text",
			},
		})

		local ButtonContent = New("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			AutomaticSize = sizeOverride and Enum.AutomaticSize.None or Enum.AutomaticSize.X,
			Parent = BtnFrame,
		}, {
			New("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 6),
			}),
			New("UIPadding", {
				PaddingTop = UDim.new(0, 4),
				PaddingBottom = UDim.new(0, 4),
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
			}),
			table.unpack(contentList),
		})

		local HoverFrame = New("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Parent = BtnFrame,
			ThemeTag = {
				BackgroundColor3 = "Hover",
			},
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 4),
			}),
		})

		local HoverMotor, HoverSet = Creator.SpringMotor(1, HoverFrame, "BackgroundTransparency", true)
		Creator.AddSignal(Button.MouseEnter, function()
			HoverSet(0.97)
		end)
		Creator.AddSignal(Button.MouseLeave, function()
			HoverSet(1)
		end)
		Creator.AddSignal(Button.MouseButton1Down, function()
			HoverSet(1)
		end)
		Creator.AddSignal(Button.MouseButton1Up, function()
			HoverSet(0.97)
		end)

		if callback then
			Creator.AddSignal(Button.MouseButton1Click, callback)
		end

		return Button, BtnFrame, ButtonContent
	end

	local function handleSuccess(key)
		closeDialog()
		if Config.KeySystem.SaveKey then
			writeFile((Config.Folder or "Temp") .. "/" .. Filename .. ".key", tostring(key))
		end
		task.wait(0.4)
		callback(true)
	end

	local ThumbnailFrame
	if Config.KeySystem.Thumbnail and Config.KeySystem.Thumbnail.Image then
		local ThumbnailTitle
		if Config.KeySystem.Thumbnail.Title then
			ThumbnailTitle = New("TextLabel", {
				Text = Config.KeySystem.Thumbnail.Title,
				TextSize = 18,
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.XY,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				ThemeTag = {
					TextColor3 = "Text",
				},
			})
		end

		ThumbnailFrame = New("ImageLabel", {
			Image = Config.KeySystem.Thumbnail.Image,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, ThumbnailSize, 1, -12),
			Position = UDim2.new(0, 6, 0, 6),
			Parent = DialogContent,
			ScaleType = Enum.ScaleType.Crop,
		}, {
			ThumbnailTitle,
			New("UICorner", {
				CornerRadius = UDim.new(0, 20),
			}),
		})
	end

	local MainFrame = New("Frame", {
		Size = UDim2.new(1, ThumbnailFrame and -ThumbnailSize or 0, 0, 0),
		Position = UDim2.new(0, ThumbnailFrame and ThumbnailSize or 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = DialogContent,
	}, {
		New("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
		}, {
			New("UIListLayout", {
				Padding = UDim.new(0, 18),
				FillDirection = Enum.FillDirection.Vertical,
			}),
			TitleContainer,
			NoteText,
			InputRow,
			ButtonsContainer,
			New("UIPadding", {
				PaddingTop = UDim.new(0, 16),
				PaddingLeft = UDim.new(0, 16),
				PaddingRight = UDim.new(0, 16),
				PaddingBottom = UDim.new(0, 16),
			}),
		}),
	})

	local ExitButton
	do
		local btn, _ = CreateKeyButton("Exit", "log-out", function()
			closeDialog()
		end, ButtonsContainer.Frame)
		ExitButton = btn
	end

	if ThumbnailFrame then
		ExitButton.Parent = ThumbnailFrame
		ExitButton.Size = UDim2.new(0, 0, 0, 42)
		ExitButton.Position = UDim2.new(0, 10, 1, -10)
		ExitButton.AnchorPoint = Vector2.new(0, 1)
	end

	if Config.KeySystem.URL then
		CreateKeyButton("Get key", "key", function()
			setClipboard(Config.KeySystem.URL)
			Library:Notify({
				Title = "Key System",
				Content = "Key link copied to clipboard.",
				Duration = 5,
			})
		end, ButtonsContainer.Frame)
	end

	if Config.KeySystem.API then
		local Width = 240
		local Opened = false
		local GetKeyBtn, GetKeyBtnFrame, GetKeyBtnContent = CreateKeyButton("Get key", "key", nil, ButtonsContainer.Frame)

		local Divider = New("Frame", {
			Size = UDim2.new(0, 1, 1, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.9,
			Parent = GetKeyBtnContent,
			ThemeTag = {
				BackgroundColor3 = "Text",
			},
		})

		local ChevronDownIcon
		do
			local cdImg, cdSize, cdOffset = getIconData("chevron-down")
			ChevronDownIcon = New("ImageLabel", {
				Image = cdImg,
				ImageRectSize = cdSize,
				ImageRectOffset = cdOffset,
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				ThemeTag = {
					ImageColor3 = "Text",
				},
			})
		end

		local IconContainer = New("Frame", {
			Size = UDim2.new(0, 21, 0, 21),
			Parent = GetKeyBtnContent,
			BackgroundTransparency = 1,
		}, {
			ChevronDownIcon,
		})

		local DropdownFrame = New("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
			New("UIPadding", {
				PaddingTop = UDim.new(0, 5),
				PaddingLeft = UDim.new(0, 5),
				PaddingRight = UDim.new(0, 5),
				PaddingBottom = UDim.new(0, 5),
			}),
			New("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 5),
			}),
		})

		local DropdownContainer = New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, Width, 0, 0),
			ClipsDescendants = true,
			AnchorPoint = Vector2.new(1, 0.5),
			Parent = GetKeyBtn,
			Position = UDim2.new(1, 0, 0.5, 0),
			ZIndex = 10,
		}, {
			DropdownFrame,
		})

		New("TextLabel", {
			Text = "Select Service",
			BackgroundTransparency = 1,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
			TextSize = 16,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTransparency = 0.2,
			Parent = DropdownFrame,
			ThemeTag = { TextColor3 = "Text" },
		}, {
			New("UIPadding", {
				PaddingTop = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
			}),
		})

		for _, i in next, Config.KeySystem.API do
			local serviceDef = KeyServices[i.Type]
			if serviceDef then
				local args = {}
				for _, argName in next, serviceDef.Args do
					table.insert(args, i[argName])
				end

				local serviceInstance = serviceDef.New(table.unpack(args))
				serviceInstance.Type = i.Type
				table.insert(Services, serviceInstance)

				local srvIconImg, srvIconSize, srvIconOffset = getIconData(i.Icon or serviceDef.Icon or "user")
				local SvcIconFrame = New("ImageLabel", {
					Image = srvIconImg,
					ImageRectSize = srvIconSize,
					ImageRectOffset = srvIconOffset,
					Size = UDim2.new(0, 24, 0, 24),
					BackgroundTransparency = 1,
					ThemeTag = {
						ImageColor3 = "Text",
					},
				})

			local APIFrame = New("TextButton", {
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Text = "",
				Parent = DropdownFrame,
			}, {
					New("UICorner", {
						CornerRadius = UDim.new(0, 5),
					}),
					New("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						Padding = UDim.new(0, 10),
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),
					SvcIconFrame,
					New("UIPadding", {
						PaddingTop = UDim.new(0, 10),
						PaddingLeft = UDim.new(0, 10),
						PaddingRight = UDim.new(0, 10),
						PaddingBottom = UDim.new(0, 10),
					}),
					New("Frame", {
						BackgroundTransparency = 1,
						Size = UDim2.new(1, -24 - 10, 0, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
					}, {
						New("UIListLayout", {
							FillDirection = Enum.FillDirection.Vertical,
							Padding = UDim.new(0, 5),
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
						}),
						New("TextLabel", {
							Text = i.Title or serviceDef.Name,
							BackgroundTransparency = 1,
							FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
							TextSize = 18,
							Size = UDim2.new(1, 0, 0, 0),
							AutomaticSize = Enum.AutomaticSize.Y,
							TextWrapped = true,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextTransparency = 0.05,
							ThemeTag = { TextColor3 = "Text" },
						}),
						New("TextLabel", {
							Text = i.Desc or "",
							BackgroundTransparency = 1,
							FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular),
							TextSize = 16,
							Size = UDim2.new(1, 0, 0, 0),
							AutomaticSize = Enum.AutomaticSize.Y,
							TextWrapped = true,
							Visible = i.Desc and true or false,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextTransparency = 0.2,
							ThemeTag = { TextColor3 = "Text" },
						}),
					}),
				})

				Creator.AddSignal(APIFrame.MouseEnter, function()
					APIFrame.BackgroundTransparency = 0.95
				end)
				Creator.AddSignal(APIFrame.InputEnded, function()
					APIFrame.BackgroundTransparency = 1
				end)
				Creator.AddSignal(APIFrame.MouseButton1Click, function()
					serviceInstance.Copy()
					Library:Notify({
						Title = "Key System",
						Content = "Key link copied to clipboard.",
						Duration = 5,
					})
				end)

				Creator.AddThemeObject(APIFrame, {
					BackgroundColor3 = "Text",
				})
			end
		end

		Creator.AddSignal(GetKeyBtn.MouseButton1Click, function()
			if not Opened then
				DropdownContainer.Size = UDim2.new(0, Width, 0, DropdownFrame.AbsoluteSize.Y + 1)
				ChevronDownIcon.Rotation = 180
			else
				DropdownContainer.Size = UDim2.new(0, Width, 0, 0)
				ChevronDownIcon.Rotation = 0
			end
			Opened = not Opened
		end)
	end

	local SubmitButton
	do
		local btn, _ = CreateKeyButton("Submit", "arrow-right", function()
			local key = tostring(EnteredKey or "empty")

			if Config.KeySystem.KeyValidator then
				local isValid = Config.KeySystem.KeyValidator(key)
				if isValid then
					handleSuccess(key)
				else
					Library:Notify({
						Title = "Key System",
						Content = "Invalid key.",
						Duration = 5,
					})
				end
			elseif not Config.KeySystem.API then
				local isKey = (type(Config.KeySystem.Key) == "table" and table.find(Config.KeySystem.Key, key))
					or Config.KeySystem.Key == key

				if isKey then
					handleSuccess(key)
				else
					Library:Notify({
						Title = "Key System",
						Content = "Invalid key.",
						Duration = 5,
					})
				end
			else
				local isSuccess, result
				for _, service in next, Services do
					local success, res = service.Verify(key)
					if success then
						isSuccess, result = true, res
						break
					end
					result = res
				end

				if isSuccess then
					handleSuccess(key)
				else
					Library:Notify({
						Title = "Key System",
						Content = tostring(result or "Invalid key."),
						Duration = 5,
					})
				end
			end
		end, InputRow, UDim2.new(0.4, 0, 1, 0))
		SubmitButton = btn
	end

	openDialog()
	task.spawn(function()
		task.wait()
		updateDialogSize()
	end)
end

return KeySystem
