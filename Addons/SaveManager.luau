local httpService = game:GetService("HttpService")


type Dropdown = {Value: any, Values: {i: any}, Multi: boolean, Displayer: (v) -> (n)?, SetValue: (any) -> ()}

local DisplayerParser = {
	Encode = function(Value)
		local Encoded = {}

		for Val: any, Bool: boolean in Value do
			table.insert(Encoded, Val)
		end

		return Encoded
	end,
}

local function TableEqual(Table, Reflect)
	for Index, Value in Table do 
		if Reflect[Index] ~= Value then return false end 
	end 

	return true
end  

local function SetDisplayerDropdownValue(Dropdown: Dropdown, Value)
	if Dropdown.Multi then
		local Values = {}
		
		for _, DataValue in Value do 
			for _, DropdownValue in Dropdown.Values do 
				if typeof(DropdownValue) ~= 'table' or not TableEqual(DataValue, DropdownValue) then continue end 
				
				Values[DropdownValue] = true
				break
			end
		end
		
		Dropdown:SetValue(Values)
	else
		for _, DropdownValue in Dropdown.Values do 
			if typeof(DropdownValue) ~= 'table' or not TableEqual(Value, DropdownValue) then continue end 
			
			Dropdown:SetValue(DropdownValue)
			break
		end	
	end
end

local SaveManager = {} do
	SaveManager.Folder = "FluentSettings"
	SaveManager.Ignore = {}
	SaveManager.DefaultsCaptured = false
	SaveManager.DefaultValues = {}
	SaveManager.Options, SaveManager.Library = {} :: { [string]: {Type: string, Value: any, SetValues: (self: any, NewValue: { [any]: any }) -> nil, SetValue: (self: any, NewValue: any, ...any) -> nil, SetValueRGB: (self: any, NewValue: Color3, Transparency: number?) -> nil} }, {}
	SaveManager.Parser = {
		Toggle = {
			Save = function(idx, object) 
				return { type = "Toggle", idx = idx, value = object.Value, Timestamp = object.Instance.CreatedAt } 
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValue(data.value)
				end
			end,
		},
		Slider = {
			Save = function(idx, object)
				return { type = "Slider", idx = idx, value = object.Value, Timestamp = object.Instance.CreatedAt }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValue(data.value)
				end
			end,
		},
		Dropdown = {
			Save = function(idx, object)
				local HasDisplayer = object.CustomDisplayer
				
				return { type = "Dropdown", idx = idx, value = (HasDisplayer and object.Multi and DisplayerParser.Encode(object.Value) or object.Value), mutli = object.Multi, Timestamp = object.Instance.CreatedAt, displayer = HasDisplayer}
			end,
			Load = function(idx, data)
				if data.value == nil then return end
				
				local DropdownElement = SaveManager.Options[idx]
				if not DropdownElement then return end
				
				local Value = data.value 
				if typeof(Value) ~= 'table' or (not data.displayer) then
					DropdownElement:SetValue(Value)
					return
				end
				
				SetDisplayerDropdownValue(DropdownElement, Value)
			end,
		},
		Colorpicker = {
			Save = function(idx, object)
				return { type = "Colorpicker", idx = idx, value = object.Value:ToHex(), transparency = object.Transparency, Timestamp = object.Instance.CreatedAt }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValueRGB(Color3.fromHex(data.value), data.transparency)
				end
			end,
		},
		Keybind = {
			Save = function(idx, object)
				return { type = "Keybind", idx = idx, mode = object.Mode, key = object.Value, Timestamp = object.Instance.CreatedAt }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValue(data.key, data.mode)
				end
			end,
		},

		Input = {
			Save = function(idx, object)
				return { type = "Input", idx = idx, text = object.Value, Timestamp = object.Instance.CreatedAt }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] and type(data.text) == "string" then
					SaveManager.Options[idx]:SetValue(data.text)
				end
			end,
		},
	}

	function SaveManager:SetIgnoreIndexes(list)
		for _, key in next, list do
			self.Ignore[key] = true
		end
	end

	function SaveManager:CaptureDefaults()
		if self.DefaultsCaptured then return end
		self.DefaultsCaptured = true
		for Idx, Option in next, self.Options do
			if not self.Ignore[Idx] then
				self.DefaultValues[Idx] = {
					Value = Option.Value,
					Mode = Option.Type == "Keybind" and Option.Mode or nil
				}
			end
		end
	end

	function SaveManager:SetFolder(folder)
		self.Folder = folder
		self:BuildFolderTree()
	end

	function SaveManager:Save(name): (boolean, string?)
		if (not name) then
			return false, "No config file is selected"
		end

		local fullPath = `{self.Folder}/settings/{name}.json`

		local data = {
			objects = {}
		}

		for idx, option in next, SaveManager.Options do
			if not self.Parser[option.Type] then continue end
			if self.Ignore[idx] or (type(idx) == "string" and idx:sub(1, 13) == "ExtraSetting_") then continue end

			data.objects[#data.objects + 1] = self.Parser[option.Type].Save(idx, option)
		end

		table.sort(data.objects, function(v1: { Timestamp: number }, v2: { Timestamp: number })
			return v1.Timestamp < v2.Timestamp
		end)

		local success, encoded = pcall(httpService.JSONEncode, httpService, data)
		if not success then
			return false, "Failed to JSON-Encode data"
		end

		writefile(fullPath, encoded)
		return true
	end

	function SaveManager:Load(name): (boolean, string?)
		if (not name) then
			return false, "No config file is selected"
		end

		local file = `{self.Folder}/settings/{name}.json`
		if not isfile(file) then return false, "invalid file" end

		local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(file))
		if not success then return false, "decode error" end

		for _, option in next, decoded.objects do
			if self.Parser[option.type] then
				task.spawn(self.Library.SafeCallback, self.Library, self.Parser[option.type].Load, option.idx, option)
			end
		end

		self.Library:SetTheme(self.Library.Theme)

		return true
	end

	function SaveManager:Delete(name): (boolean, string?)
		if not name then
			return false, "No config selected"
		end

		local path = `{self.Folder}/settings/{name}.json`
		if not isfile(path) then
			return false, "Config not found"
		end

		delfile(path)

		local autoPath = `{self.Folder}/settings/autoload.txt`
		if isfile(autoPath) and readfile(autoPath) == name then
			delfile(autoPath)
		end

		return true
	end

	function SaveManager:IgnoreThemeSettings()
		self:SetIgnoreIndexes({ 
			"InterfaceManager_InterfaceTheme", "InterfaceManager_AcrylicToggle", "InterfaceManager_TransparentToggle", "InterfaceManager_MenuKeybind"
		})
	end

	function SaveManager:BuildFolderTree()
		local paths = {
			self.Folder,
			`{self.Folder}/settings`
		}

		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then
				makefolder(str)
			end
		end
	end

	function SaveManager:RefreshConfigList()
		local list = listfiles(`{self.Folder}/settings`)

		local out = {}
		for i = 1, #list do
			local file = list[i]
			if file:sub(-5) == ".json" then
				local pos = file:find(".json", 1, true)
				local start = pos

				if typeof(pos) == "number" and typeof(start) == "number" then
					local char = file:sub(pos, pos)
					while char ~= "/" and char ~= "\\" and char ~= "" do
						pos = pos - 1
						char = file:sub(pos, pos)
					end

					if char == "/" or char == "\\" then
						local name = file:sub(pos + 1, start - 1)
						if name ~= "options" then
							out[#out + 1] = name
						end
					end
				end
			end
		end

		return out
	end

	function SaveManager:SetLibrary(library)
		self.Library = library
		self.Options = library.Options
	end

	function SaveManager:LoadAutoloadConfig()
		self:CaptureDefaults()
		if isfile(`{self.Folder}/settings/autoload.txt`) then
			local name = readfile(`{self.Folder}/settings/autoload.txt`)

			local success, err = self:Load(name)
			if not success then
				return self.Library:Notify({
					Title = "Interface",
					Content = "Config loader",
					SubContent = `Failed to load autoload config: {err}`,
					Duration = 7
				})
			end

			return self.Library:Notify({
				Title = "Interface",
				Content = "Config loader",
				SubContent = string.format("Auto loaded config %q", name),
				Duration = 7
			})
		end

		return nil
	end

	function SaveManager:BuildConfigSection(tab)
		assert(self.Library, "Must set SaveManager.Library")
		self:CaptureDefaults()

		local Section = tab:AddSection("Configuration")

		Section:AddInput("SaveManager_ConfigName",    { Title = "Config name" })
		Section:AddDropdown("SaveManager_ConfigList", { Title = "Config list", Values = self:RefreshConfigList(), AllowNull = true })

			Section:AddButton({
			Title = "Create config",
			Callback = function()
				local Name = SaveManager.Options.SaveManager_ConfigName.Value

				if Name:gsub(" ", "") == "" then 
					return self.Library:Notify({
						Title = "Interface",
						Content = "Config loader",
						SubContent = "Invalid config name (empty)",
						Duration = 7
					})
				end

				local Path = `{self.Folder}/settings/{Name}.json`
				local Exists = isfile(Path)

				local function SaveConfiguration()
					local Success, Err = self:Save(Name)
					if not Success then
						return self.Library:Notify({
							Title = "Interface",
							Content = "Config loader",
							SubContent = "Failed to save config: " .. Err,
							Duration = 7
						})
					end

					SaveManager.Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
					SaveManager.Options.SaveManager_ConfigList:SetValue(nil)

					self.Library:Notify({
						Title = "Interface",
						Content = "Config loader",
						SubContent = Exists and string.format("Overwrote config %q", Name) or string.format("Created config %q", Name),
						Duration = 7
					})
				end

				if Exists then
					self.Library.CreatedWindow:Dialog({
						Title = "Confirm Overwrite",
						Content = string.format("Are you sure you want to overwrite config %q?", Name),
						Buttons = {
							{
								Title = "Confirm",
								Callback = SaveConfiguration
							},
							{
								Title = "Cancel"
							}
						}
					})
				else
					SaveConfiguration()
				end
			end
		})

		Section:AddButton({Title = "Load config", Callback = function()
			local Name = SaveManager.Options.SaveManager_ConfigList.Value

			local Success, Err = self:Load(Name)
			if not Success then
				return self.Library:Notify({
					Title = "Interface",
					Content = "Config loader",
					SubContent = "Failed to load config: " .. Err,
					Duration = 7
				})
			end

			return self.Library:Notify({
				Title = "Interface",
				Content = "Config loader",
				SubContent = string.format("Loaded config %q", Name),
				Duration = 7
			})
		end})

		local AutoloadButton
		Section:AddButton({Title = "Delete config", Callback = function()
			local Name = SaveManager.Options.SaveManager_ConfigList.Value

			if not Name then
				return self.Library:Notify({
					Title = "Interface",
					Content = "Config loader",
					SubContent = "No config selected",
					Duration = 7
				})
			end

			self.Library.CreatedWindow:Dialog({
				Title = "Confirm Delete",
				Content = string.format("Are you sure you want to delete config %q?", Name),
				Buttons = {
					{
						Title = "Confirm",
						Callback = function()
							local Success, Err = self:Delete(Name)
							if not Success then
								return self.Library:Notify({
									Title = "Interface",
									Content = "Config loader",
									SubContent = "Failed to delete config: " .. Err,
									Duration = 7
								})
							end

							SaveManager.Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
							SaveManager.Options.SaveManager_ConfigList:SetValue(nil)

							if AutoloadButton then
								if isfile(`{self.Folder}/settings/autoload.txt`) then
									local AutoName = readfile(`{self.Folder}/settings/autoload.txt`)
									AutoloadButton:SetDesc("Current autoload config: " .. AutoName)
								else
									AutoloadButton:SetDesc("Current autoload config: none")
								end
							end

							self.Library:Notify({
								Title = "Interface",
								Content = "Config loader",
								SubContent = string.format("Deleted config %q", Name),
								Duration = 7
							})
						end
					},
					{
						Title = "Cancel"
					}
				}
			})
		end})

		Section:AddButton({Title = "Refresh list", Callback = function()
			SaveManager.Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
			SaveManager.Options.SaveManager_ConfigList:SetValue(nil)
		end})

		Section:AddButton({Title = "Reset to default", Callback = function()
			self.Library.CreatedWindow:Dialog({
				Title = "Confirm Reset",
				Content = "Are you sure you want to reset all options to default?",
				Buttons = {
					{
						Title = "Confirm",
						Callback = function()
							for Idx, Option in next, SaveManager.Options do
								if SaveManager.Ignore[Idx] then continue end
								local Default = SaveManager.DefaultValues[Idx]
								if Default ~= nil then
									if Option.Type == "Keybind" then
										Option:SetValue(Default.Value, Default.Mode)
									else
										Option:SetValue(Default.Value)
									end
								end
							end
							self.Library:Notify({
								Title = "Interface",
								Content = "Config loader",
								SubContent = "Reset all options to default",
								Duration = 7
							})
						end
					},
					{
						Title = "Cancel"
					}
				}
			})
		end})

		AutoloadButton = Section:AddButton({Title = "Set as autoload", Description = "Current autoload config: none", Callback = function()
			local Name = SaveManager.Options.SaveManager_ConfigList.Value

			if not Name then
				return self.Library:Notify({
					Title = "Interface",
					Content = "Config loader",
					SubContent = "No config selected",
					Duration = 7
				})
			end

			if not isfile(`{self.Folder}/settings/{Name}.json`) then
				return self.Library:Notify({
					Title = "Interface",
					Content = "Config loader",
					SubContent = string.format("Config %q no longer exists", Name),
					Duration = 7
				})
			end

			writefile(`{self.Folder}/settings/autoload.txt`, Name)
			AutoloadButton:SetDesc("Current autoload config: " .. Name)
			self.Library:Notify({
				Title = "Interface",
				Content = "Config loader",
				SubContent = string.format("Set %q to auto load", Name),
				Duration = 7
			})
		end})

		Section:AddButton({Title = "Clear autoload", Callback = function()
			local AutoPath = `{self.Folder}/settings/autoload.txt`
			if not isfile(AutoPath) then
				return self.Library:Notify({
					Title = "Interface",
					Content = "Config loader",
					SubContent = "No autoload config set",
					Duration = 7
				})
			end

			self.Library.CreatedWindow:Dialog({
				Title = "Confirm Clear Autoload",
				Content = "Are you sure you want to disable autoload?",
				Buttons = {
					{
						Title = "Confirm",
						Callback = function()
							delfile(AutoPath)
							AutoloadButton:SetDesc("Current autoload config: none")
							self.Library:Notify({
								Title = "Interface",
								Content = "Config loader",
								SubContent = "Cleared autoload config",
								Duration = 7
							})
						end
					},
					{
						Title = "Cancel"
					}
				}
			})
		end})

		if isfile(`{self.Folder}/settings/autoload.txt`) then
			local Name = readfile(`{self.Folder}/settings/autoload.txt`)
			AutoloadButton:SetDesc("Current autoload config: " .. Name)
		end

		SaveManager:SetIgnoreIndexes({ "SaveManager_ConfigList", "SaveManager_ConfigName" })
	end

	SaveManager:BuildFolderTree()
end

return SaveManager
