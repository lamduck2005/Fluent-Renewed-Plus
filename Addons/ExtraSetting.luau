local httpService = game:GetService("HttpService")
local players = game:GetService("Players")
local player = players.LocalPlayer
local virtualUser = game:GetService("VirtualUser")
local virtualInputManager = game:GetService("VirtualInputManager")
local guiService = game:GetService("GuiService")
local teleportService = game:GetService("TeleportService")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")

local ExtraSetting = {} do
	ExtraSetting.Folder = "FluentSettings"
	ExtraSetting.Library = nil
	ExtraSetting.Window = nil
	ExtraSetting.Discord = nil
	ExtraSetting.AutoExecuteUrl = nil

	ExtraSetting.SavedConfig = {
		EnableUnlockFPS = false,
		EnableFPSBoost = false,
		AutoAFKTime = 300,
		EnableAutoAFK = false,
		EnableAutoRejoin = false,
		AutoRejoinMinutes = 60,
		EnableAutoExecute = true,
		AutoExecuteUrl = "",
		EnableAntiAFK = true,
		EnableAutoReconnect = true,
	}

	local isFPSBoostApplied = false
	local isAFKModeEnabled = false
	local isAutoAFKEnabled = false
	local autoAFKTimeThreshold = 300
	local lastActivityTime = tick()
	local lastMouseMoveTime = 0
	local lastClickTime = 0
	local afkStartTime = 0
	local isAutoAFKLoopRunning = false
	local afkInfoThread = nil
	local isAutoRejoinTimerRunning = false
	local autoRejoinTimerStartTime = tick()
	local isAntiAfkFiring = false
	local afkExtraInfo = {}
	local afkToggleRef = nil
	local connIdled = nil
	local connErrorMessage = nil
	local connInputBegan = nil
	local connInputChanged = nil
	local inited = false

	local function ConfigPath()
		return ExtraSetting.Folder .. "/settings/extra_config.json"
	end

	local function SaveConfig()
		pcall(function()
			local path = ConfigPath()
			local folder = ExtraSetting.Folder .. "/settings"
			if not isfolder(folder) then
				makefolder(folder)
			end
			writefile(path, httpService:JSONEncode(ExtraSetting.SavedConfig))
		end)
	end

	local function LoadConfig()
		pcall(function()
			local path = ConfigPath()
			if isfile(path) then
				local data = httpService:JSONDecode(readfile(path))
				if data then
					for k, v in pairs(data) do
						ExtraSetting.SavedConfig[k] = v
					end
				end
			end
		end)
	end

	local function ExecuteRejoin()
		local placeId = game.PlaceId
		local jobId = game.JobId
		if #players:GetPlayers() <= 1 then
			player:Kick("\nRejoining... Don't click anything!")
			task.wait(1)
			teleportService:Teleport(placeId, player)
		else
			pcall(function()
				teleportService:TeleportToPlaceInstance(placeId, jobId, player)
			end)
		end
	end

	local function ApplyFPSBoost()
		local lighting = game:GetService("Lighting")
		pcall(function()
			lighting.GlobalShadows = false
			lighting.FogEnd = 9e9
			lighting.ShadowSoftness = 0
			lighting.Brightness = 1
			for _, child in ipairs(lighting:GetChildren()) do
				if child:IsA("PostEffect") or child:IsA("BlurEffect") or child:IsA("SunRaysEffect") or child:IsA("ColorCorrectionEffect") or child:IsA("BloomEffect") or child:IsA("DepthOfFieldEffect") then
					pcall(function() child:Destroy() end)
				end
			end
		end)

		pcall(function()
			local terrain = workspace:FindFirstChildOfClass("Terrain")
			if terrain then
				terrain.WaterWaveSize = 0
				terrain.WaterWaveSpeed = 0
				terrain.WaterReflectance = 0
				terrain.WaterTransparency = 0
				terrain.Decoration = false
			end
		end)

		task.spawn(function()
			local descendants = workspace:GetDescendants()
			for i, obj in ipairs(descendants) do
				pcall(function()
					if obj:IsA("BasePart") and not obj:IsA("Terrain") then
						obj.Material = Enum.Material.SmoothPlastic
						obj.Reflectance = 0
						obj.CastShadow = false
					elseif obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
						obj:Destroy()
					end
				end)
				if i % 200 == 0 then task.wait() end
			end
		end)
	end

	local function ToggleAFKMode(enable)
		local playerGui = player:FindFirstChild("PlayerGui")
		local stats = game:GetService("Stats")

		pcall(function()
			runService:Set3dRenderingEnabled(not enable)
		end)

		if not enable then
			if afkInfoThread then
				pcall(task.cancel, afkInfoThread)
				afkInfoThread = nil
			end
			if playerGui then
				local blackout = playerGui:FindFirstChild("AFKBlackoutScreenGui")
				if blackout then blackout.Enabled = false end
			end
			return
		end

		if not playerGui then return end
		local blackoutScreenGui = playerGui:FindFirstChild("AFKBlackoutScreenGui")
		if not blackoutScreenGui then
			blackoutScreenGui = Instance.new("ScreenGui")
			blackoutScreenGui.Name = "AFKBlackoutScreenGui"
			blackoutScreenGui.IgnoreGuiInset = true
			blackoutScreenGui.DisplayOrder = 2147483647

			local backgroundFrame = Instance.new("TextButton")
			backgroundFrame.Name = "Background"
			backgroundFrame.Size = UDim2.new(1, 0, 1, 0)
			backgroundFrame.BackgroundColor3 = Color3.new(0, 0, 0)
			backgroundFrame.Text = ""
			backgroundFrame.AutoButtonColor = false
			backgroundFrame.Active = true
			backgroundFrame.Parent = blackoutScreenGui

			backgroundFrame.MouseButton1Click:Connect(function()
				local now = tick()
				if now - lastClickTime < 0.5 then
					isAFKModeEnabled = false
					ToggleAFKMode(false)
					pcall(function() afkToggleRef:SetValue(false) end)
					lastActivityTime = tick()
				end
				lastClickTime = now
			end)

			local statusLabel = Instance.new("TextLabel")
			statusLabel.Name = "StatusLabel"
			statusLabel.Size = UDim2.new(0.9, 0, 0.9, 0)
			statusLabel.Position = UDim2.new(0.05, 0, 0.05, 0)
			statusLabel.BackgroundTransparency = 1
			statusLabel.TextColor3 = Color3.new(1, 1, 1)
			statusLabel.Font = Enum.Font.GothamBold
			statusLabel.RichText = true
			statusLabel.TextScaled = true
			statusLabel.Text = "<b><font color='#00E5FF'>[ AFK MODE ACTIVE ]</font></b>\nLoading..."
			statusLabel.Parent = backgroundFrame

			local textConstraint = Instance.new("UITextSizeConstraint")
			textConstraint.MaxTextSize = 24
			textConstraint.MinTextSize = 12
			textConstraint.Parent = statusLabel

			pcall(function() blackoutScreenGui.Parent = playerGui end)
		else
			blackoutScreenGui.Enabled = true
		end

		if afkInfoThread then
			pcall(task.cancel, afkInfoThread)
			afkInfoThread = nil
		end

		afkStartTime = os.time()
		afkInfoThread = task.spawn(function()
			while isAFKModeEnabled and blackoutScreenGui and blackoutScreenGui.Enabled do
				local duration = os.time() - afkStartTime
				local cfg = ExtraSetting.SavedConfig
				local actualFps = math.floor(stats.Workspace.Heartbeat:GetValue())
				local ramUsage = math.floor(stats:GetTotalMemoryUsageMb())
				local hours = math.floor(duration / 3600)
				local minutes = math.floor((duration % 3600) / 60)
				local seconds = duration % 60
				local timeStr = string.format("%02d:%02d:%02d", hours, minutes, seconds)

				local statusParts = {}
				if cfg.EnableAutoRejoin and isAutoRejoinTimerRunning then
					local remain = math.max(0, (cfg.AutoRejoinMinutes * 60) - math.floor(tick() - autoRejoinTimerStartTime))
					local rh = math.floor(remain / 3600)
					local rm = math.floor((remain % 3600) / 60)
					local rs = remain % 60
					table.insert(statusParts, string.format("<font color='#FF5252'>REJOIN IN: %02d:%02d:%02d</font>", rh, rm, rs))
				end
				local statusLine = #statusParts > 0 and table.concat(statusParts, "   |   ") .. "\n\n" or ""

				local label = blackoutScreenGui:FindFirstChild("StatusLabel", true)
				if label then
					local extraParts = {}
					for _, cb in pairs(afkExtraInfo) do
						local ok, title, val = pcall(cb)
						if ok and title and val then
							table.insert(extraParts, string.format("<font color='#B0BEC5'>%s:</font> <b>%s</b>", title, val))
						end
					end
					local extraText = #extraParts > 0 and "\n\n" .. table.concat(extraParts, "   |   ") or ""
					label.Text = string.format(
						"<b><font color='#00E5FF'>[ AFK MODE ACTIVE ]</font></b>\n\n" ..
						"<font color='#B0BEC5'>TIME:</font> <b>%s</b>   |   <font color='#B0BEC5'>FPS:</font> <b><font color='#00E5FF'>%d</font></b>   |   <font color='#B0BEC5'>RAM:</font> <b><font color='#FF5252'>%d MB</font></b>%s\n\n" ..
						"%s" ..
						"<font color='#78909C' size='14'>(Double tap to wake)</font>",
						timeStr, actualFps, ramUsage, extraText, statusLine
					)
				end

				pcall(function() collectgarbage("collect") end)
				task.wait(1)
			end
		end)
	end

	local function StartAutoAFKLoop()
		if isAutoAFKLoopRunning or not isAutoAFKEnabled then return end
		isAutoAFKLoopRunning = true
		task.spawn(function()
			while isAutoAFKEnabled do
				if not isAFKModeEnabled then
					local idleTime = tick() - lastActivityTime
					if idleTime >= autoAFKTimeThreshold then
						isAFKModeEnabled = true
						ToggleAFKMode(true)
						pcall(function() afkToggleRef:SetValue(true) end)
					end
				end
				task.wait(1)
			end
			isAutoAFKLoopRunning = false
		end)
	end

	local function StartAutoRejoinTimerLoop()
		if isAutoRejoinTimerRunning or not ExtraSetting.SavedConfig.EnableAutoRejoin then return end
		isAutoRejoinTimerRunning = true
		task.spawn(function()
			autoRejoinTimerStartTime = tick()
			while ExtraSetting.SavedConfig.EnableAutoRejoin do
				local elapsed = (tick() - autoRejoinTimerStartTime) / 60
				if elapsed >= (ExtraSetting.SavedConfig.AutoRejoinMinutes or 60) then
					print("[ExtraSetting] Auto Rejoin triggered.")
					ExtraSetting.Library:Notify({
						Title = "Auto Rejoin",
						Content = "Rejoining to refresh RAM...",
						Duration = 10,
					})
					task.wait(5)
					ExecuteRejoin()
					break
				end
				task.wait(10)
			end
			isAutoRejoinTimerRunning = false
		end)
	end

	local function InitAntiAFK()
		pcall(function()
			for _, v in pairs(getconnections(player.Idled)) do v:Disable() end
		end)
		connIdled = player.Idled:Connect(function()
			isAntiAfkFiring = true
			pcall(function()
				virtualUser:CaptureController()
				virtualUser:ClickButton2(Vector2.new())
			end)
			pcall(function()
				virtualInputManager:SendKeyEvent(true, Enum.KeyCode.RightShift, false, game)
				virtualInputManager:SendKeyEvent(false, Enum.KeyCode.RightShift, false, game)
			end)
			pcall(function()
				virtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
				virtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
			end)
			pcall(function() player.Character:FindFirstChildOfClass("Humanoid").Jump = true end)
			isAntiAfkFiring = false
		end)
	end

	local function InitAutoRejoin()
		connErrorMessage = guiService.ErrorMessageChanged:Connect(function(msg)
			if not msg or msg == "" then return end
			local low = string.lower(msg)
			if string.find(low, "exploiting") or string.find(low, "banned") then return end
			print("[ExtraSetting] Disconnected: " .. tostring(msg))
			print("[ExtraSetting] Rejoining...")
			ExecuteRejoin()
		end)
	end

	local function InitActivityTracking()
		connInputBegan = userInputService.InputBegan:Connect(function(input, processed)
			if not processed and not isAntiAfkFiring then
				lastActivityTime = tick()
			end
		end)
		connInputChanged = userInputService.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				local now = tick()
				if now - lastMouseMoveTime > 1 then
					lastActivityTime = now
					lastMouseMoveTime = now
				end
			end
		end)
	end

	local function SetupQueueOnTeleport()
		if not ExtraSetting.AutoExecuteUrl then return end
		local q = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
		if not q then return end
		local code = string.format([[
			local ok, data = pcall(function()
				local fs = readfile("%s/settings/extra_config.json")
				return game:GetService("HttpService"):JSONDecode(fs)
			end)
			if ok and data and data.EnableAutoExecute then
				local s, r = pcall(function() return game:HttpGet("%s") end)
				if s and r then loadstring(r)() end
			end
		]], ExtraSetting.Folder, ExtraSetting.AutoExecuteUrl)
		q(code)
	end

	function ExtraSetting:SetWindow(win)
		self.Window = win
	end

	function ExtraSetting:SetLibrary(lib)
		self.Library = lib
		function lib:Rejoin()
			ExecuteRejoin()
		end
	end

	function ExtraSetting:SetAFKInfo(key, cb)
		afkExtraInfo[key] = cb
	end

	function ExtraSetting:RemoveAFKInfo(key)
		afkExtraInfo[key] = nil
	end

	function ExtraSetting:SetFolder(folder)
		self.Folder = folder
	end

	function ExtraSetting:Init()
		if inited then return end
		inited = true
		LoadConfig()

		autoAFKTimeThreshold = self.SavedConfig.AutoAFKTime
		isAutoAFKEnabled = self.SavedConfig.EnableAutoAFK

		if self.SavedConfig.EnableAntiAFK then
			InitAntiAFK()
		end
		if self.SavedConfig.EnableAutoReconnect then
			InitAutoRejoin()
		end
		InitActivityTracking()
		SetupQueueOnTeleport()

		if self.SavedConfig.EnableUnlockFPS and setfpscap then
			pcall(function() setfpscap(999) end)
		end

		if self.SavedConfig.EnableFPSBoost then
			isFPSBoostApplied = true
			task.spawn(function()
				task.wait(5)
				ApplyFPSBoost()
				local lib = self.Library
				if lib then
					lib:Notify({ Title = "Performance", Content = "FPS Boost applied!", Duration = 3 })
				end
			end)
		end

		if self.SavedConfig.EnableAutoAFK then
			StartAutoAFKLoop()
		end

		if self.SavedConfig.EnableAutoRejoin then
			StartAutoRejoinTimerLoop()
		end
	end

	function ExtraSetting:BuildExtraSection(tab)
		assert(self.Library, "Must set ExtraSetting.Library")
		if not inited then self:Init() end
		local lib = self.Library
		local cfg = self.SavedConfig

		if self.Discord then
			local section = tab:AddSection("Discord")
			section:AddButton({
				Title = "Join Discord",
				Callback = function()
					local ok = pcall(function() setclipboard(self.Discord) end)
					lib:Notify({
						Title = "Discord",
						Content = ok and "Link copied to clipboard!" or "Clipboard not available",
						Duration = 3,
					})
				end,
			})
		end

		do
			local section = tab:AddSection("Anti-AFK")

			section:AddToggle("ExtraSetting_AntiAFK", {
				Title = "Anti-AFK",
				Description = "Prevents Roblox from kicking you for being idle",
				Default = cfg.EnableAntiAFK,
				Callback = function(v)
					cfg.EnableAntiAFK = v
					SaveConfig()
					if v then
						InitAntiAFK()
					elseif connIdled then
						connIdled:Disconnect()
						connIdled = nil
					end
				end,
			})

			section:AddToggle("ExtraSetting_AutoReconnect", {
				Title = "Auto Reconnect",
				Description = "Automatically rejoins when disconnected due to error (e.g. kicked, server closed)",
				Default = cfg.EnableAutoReconnect,
				Callback = function(v)
					cfg.EnableAutoReconnect = v
					SaveConfig()
					if v then
						InitAutoRejoin()
					elseif connErrorMessage then
						connErrorMessage:Disconnect()
						connErrorMessage = nil
					end
				end,
			})
		end

		do
			local section = tab:AddSection("Performance")

			if setfpscap then
				section:AddToggle("ExtraSetting_UnlockFPS", {
					Title = "Unlock FPS",
					Default = cfg.EnableUnlockFPS,
					Callback = function(v)
						cfg.EnableUnlockFPS = v
						SaveConfig()
						if v then
							pcall(function() setfpscap(999) end)
						else
							pcall(function() setfpscap(60) end)
						end
					end,
				})
			end

			section:AddToggle("ExtraSetting_FPSBoost", {
				Title = "Enable FPS Boost",
				Default = cfg.EnableFPSBoost,
				Callback = function(v)
					if v then
						if not isFPSBoostApplied then
							isFPSBoostApplied = true
							cfg.EnableFPSBoost = true
							SaveConfig()
							ApplyFPSBoost()
							lib:Notify({ Title = "Performance", Content = "FPS Boost applied!", Duration = 3 })
						end
					else
						cfg.EnableFPSBoost = false
						SaveConfig()
						if isFPSBoostApplied then
							lib:Notify({ Title = "Performance", Content = "Please Rejoin to restore graphics.", Duration = 4 })
						end
					end
				end,
			})
		end

		do
			local section = tab:AddSection("AFK Mode")

			local afkToggle = section:AddToggle("ExtraSetting_AFKMode", {
				Title = "Enable AFK Mode",
				Default = false,
				Callback = function(v)
					isAFKModeEnabled = v
					ToggleAFKMode(v)
				end,
			})
			afkToggleRef = afkToggle

			section:AddInput("ExtraSetting_AutoAFKTime", {
				Title = "Auto AFK Time",
				Description = "seconds, min: 10",
				Placeholder = "300",
				Default = tostring(cfg.AutoAFKTime),
				Callback = function(val)
					local parsed = tonumber(val) or 10
					if parsed < 10 then parsed = 10 end
					autoAFKTimeThreshold = parsed
					cfg.AutoAFKTime = parsed
					SaveConfig()
					lastActivityTime = tick()
				end,
			})

			section:AddToggle("ExtraSetting_AutoEnterAFK", {
				Title = "Auto Enter AFK Mode",
				Default = cfg.EnableAutoAFK,
				Callback = function(v)
					isAutoAFKEnabled = v
					cfg.EnableAutoAFK = v
					SaveConfig()
					if v then
						lastActivityTime = tick()
						StartAutoAFKLoop()
					end
				end,
			})
		end

		do
			local section = tab:AddSection("Auto Rejoin - Exectute")

			section:AddInput("ExtraSetting_AutoRejoinTime", {
				Title = "Auto Rejoin Time",
				Description = "minutes, min: 5",
				Placeholder = "60",
				Default = tostring(cfg.AutoRejoinMinutes or 60),
				Callback = function(val)
					local parsed = tonumber(val) or 60
					if parsed < 5 then parsed = 60 end
					cfg.AutoRejoinMinutes = parsed
					SaveConfig()
					if isAutoRejoinTimerRunning then
						autoRejoinTimerStartTime = tick()
					end
				end,
			})

			section:AddToggle("ExtraSetting_AutoRejoin", {
				Title = "Enable Auto Rejoin Timer",
				Description = "Not recommended on PC — executor may crash",
				Default = cfg.EnableAutoRejoin,
				Callback = function(v)
					cfg.EnableAutoRejoin = v
					SaveConfig()
					if v then
						autoRejoinTimerStartTime = tick()
						StartAutoRejoinTimerLoop()
					end
				end,
			})

			local hasQueue = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
			if hasQueue and ExtraSetting.AutoExecuteUrl then
				section:AddToggle("ExtraSetting_AutoExecute", {
					Title = "Auto Execute on Rejoin",
					Default = cfg.EnableAutoExecute,
					Callback = function(v)
						cfg.EnableAutoExecute = v
						SaveConfig()
					end,
				})
			end
		end
	end

end

return ExtraSetting
