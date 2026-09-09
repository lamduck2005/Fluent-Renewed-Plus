local httpService = game:GetService("HttpService")
local players = game:GetService("Players")
local player = players.LocalPlayer
local virtualUser = game:GetService("VirtualUser")
local virtualInputManager = game:GetService("VirtualInputManager")
local guiService = game:GetService("GuiService")
local teleportService = game:GetService("TeleportService")
local runService = game:GetService("RunService")
local statsService = game:GetService("Stats")

local ExtraSetting = {} do
	ExtraSetting.Folder = "FluentSettings"
	ExtraSetting.Library = nil
	ExtraSetting.Discord = nil
	ExtraSetting.AutoExecuteUrl = nil

	ExtraSetting.SavedConfig = {
		EnableUnlockFPS = false,
		EnableFPSBoost = false,
		EnableFPSOverlay = false,
		AutoAFKTime = 300,
		EnableAutoAFK = false,
		EnableAutoRejoin = false,
		AutoRejoinMinutes = 60,
		EnableAutoExecute = true,
		AutoExecuteUrl = "",
		EnableAntiAFK = true,
		EnableAutoReconnect = true,
		DisablePurchasePrompts = true,
	}

	local isFPSBoostApplied = false
	local isAFKModeEnabled = false
	local isAutoAFKEnabled = false
	local autoAFKTimeThreshold = 300
	local lastActivityTime = tick()
	local lastClickTime = 0
	local afkStartTime = 0
	local isAutoAFKLoopRunning = false
	local afkInfoThread = nil
	local OriginalVolume = 1
	local HasMutedAudio = false
	local isAutoRejoinTimerRunning = false
	local autoRejoinTimerStartTime = tick()
	local afkExtraInfo = {}
	local afkToggleRef = nil
	local connIdled = nil
	local connErrorMessage = nil
	local fpsOverlayConn
	local fpsCount, fpsTime, currentFps = 0, 0, 0
	local perfStartTime, lastLogTime, lastLuaMb, lastTotalMb = 0, 0, 0, 0
	local fpsOverlayGui
	local fpsOverlayLabel
	local inited = false

	local function ConfigPath()
		return ExtraSetting.Folder .. "/extra/extra_config.json"
	end

	local function SaveConfig()
		pcall(function()
			local path = ConfigPath()
			local root = ExtraSetting.Folder
			if not isfolder(root) then
				makefolder(root)
			end
			local extra = root .. "/extra"
			if not isfolder(extra) then
				makefolder(extra)
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

	local purchasePromptConnection = nil

	local function TogglePurchasePrompts(disable)
		pcall(function()
			game.CoreGui.PurchasePromptApp.Enabled = not disable
		end)

		local foundationOverlay = game.CoreGui:FindFirstChild("FoundationOverlay")
		if disable then
			if not foundationOverlay then
				if not purchasePromptConnection then
					purchasePromptConnection = game.CoreGui.ChildAdded:Connect(function(ins)
						if ins.Name == "FoundationOverlay" then
							pcall(function() ins.Enabled = false end)
							if purchasePromptConnection then
								purchasePromptConnection:Disconnect()
								purchasePromptConnection = nil
							end
						end
					end)
				end
			else
				pcall(function() foundationOverlay.Enabled = false end)
			end
		else
			if purchasePromptConnection then
				purchasePromptConnection:Disconnect()
				purchasePromptConnection = nil
			end
			if foundationOverlay then
				pcall(function() foundationOverlay.Enabled = true end)
			end
		end
	end

	local function ToggleAFKMode(enable)
		local playerGui = player:FindFirstChild("PlayerGui")
		local stats = game:GetService("Stats")

		pcall(function()
			runService:Set3dRenderingEnabled(not enable)
		end)

		if not enable then
			if HasMutedAudio then
				pcall(function()
					UserSettings():GetService("UserGameSettings").MasterVolume = OriginalVolume
				end)
				HasMutedAudio = false
			end

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

		pcall(function()
			local userGameSettings = UserSettings():GetService("UserGameSettings")
			OriginalVolume = userGameSettings.MasterVolume
			userGameSettings.MasterVolume = 0
			HasMutedAudio = true
		end)

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

				task.wait(1)
			end
		end)
	end

	local function StartAutoAFKLoop()
		if isAutoAFKLoopRunning or not isAutoAFKEnabled then return end
		isAutoAFKLoopRunning = true
		task.spawn(function()
			lastActivityTime = tick()
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
		if not ExtraSetting.AutoExecuteUrl then return end
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
				task.wait(1)
			end
			isAutoRejoinTimerRunning = false
		end)
	end

	local function InitAntiAFK()
		pcall(function()
			for _, v in pairs(getconnections(player.Idled)) do v:Disable() end
		end)
		connIdled = player.Idled:Connect(function()
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

	local function SetFpsOverlay(enabled)
		if not fpsOverlayGui then return end
		fpsOverlayGui.Enabled = enabled
		if enabled then
			if fpsOverlayConn then return end
			fpsCount, fpsTime = 0, tick()
			perfStartTime = os.clock()
			lastLogTime = os.clock()
			lastLuaMb = gcinfo() / 1024
			lastTotalMb = statsService and statsService:GetTotalMemoryUsageMb() or 0
			fpsOverlayConn = runService.RenderStepped:Connect(function()
				fpsCount += 1
				local now = tick()
				if now - fpsTime >= 1 then
					currentFps = math.floor(fpsCount / (now - fpsTime))
					fpsCount, fpsTime = 0, now
					local curLuaMb = gcinfo() / 1024
					fpsOverlayLabel.Text = string.format("FPS: %d | Mem: %d MB", currentFps, math.floor(curLuaMb))

					local nowClock = os.clock()
					if nowClock - lastLogTime >= 30 then
						local curTotalMb = statsService and statsService:GetTotalMemoryUsageMb() or 0
						local elapsedMins = (nowClock - perfStartTime) / 60
						local luaDelta = curLuaMb - lastLuaMb
						local totalDelta = curTotalMb - lastTotalMb

						print(string.format("[Perf %.1fm] %d FPS | Lua: %.1fMB (%+.1fMB) | RAM: %dMB (%+.1fMB)", elapsedMins, currentFps, curLuaMb, luaDelta, curTotalMb, totalDelta))

						lastLuaMb = curLuaMb
						lastTotalMb = curTotalMb
						lastLogTime = nowClock
					end
				end
			end)
		elseif fpsOverlayConn then
			fpsOverlayConn:Disconnect()
			fpsOverlayConn = nil
		end
	end

	local function Cleanup()
		if purchasePromptConnection then
			purchasePromptConnection:Disconnect()
			purchasePromptConnection = nil
		end
		pcall(function()
			game.CoreGui.PurchasePromptApp.Enabled = true
			local foundationOverlay = game.CoreGui:FindFirstChild("FoundationOverlay")
			if foundationOverlay then
				foundationOverlay.Enabled = true
			end
		end)

		if fpsOverlayGui then
			fpsOverlayGui:Destroy()
			fpsOverlayGui = nil
		end
		if fpsOverlayConn then
			fpsOverlayConn:Disconnect()
			fpsOverlayConn = nil
		end

		if afkInfoThread then
			pcall(task.cancel, afkInfoThread)
			afkInfoThread = nil
		end

		if connIdled then
			connIdled:Disconnect()
			connIdled = nil
		end
		if connErrorMessage then
			connErrorMessage:Disconnect()
			connErrorMessage = nil
		end

		pcall(function()
			local pg = player:FindFirstChild("PlayerGui")
			if pg then
				local b = pg:FindFirstChild("AFKBlackoutScreenGui")
				if b then b:Destroy() end
			end
		end)
		pcall(function()
			runService:Set3dRenderingEnabled(true)
		end)

		isAutoAFKLoopRunning = false
		isAutoAFKEnabled = false
		isAFKModeEnabled = false
		isAutoRejoinTimerRunning = false
		isFPSBoostApplied = false
		inited = false
	end

	local function SetupQueueOnTeleport()
		if not ExtraSetting.AutoExecuteUrl then return end
		local q = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
		if not q then return end
		local code = string.format([[
			local ok, data = pcall(function()
				local fs = readfile("%s/extra/extra_config.json")
				return game:GetService("HttpService"):JSONDecode(fs)
			end)
			if ok and data and data.EnableAutoExecute then
				print("[Auto Execute] Rejoined. Waiting 10s for game to load...")
				task.wait(10)
				print("[Auto Execute] Fetching script from URL...")
				local s, r = pcall(function() return game:HttpGet("%s") end)
				if s and r then
					print("[Auto Execute] Script downloaded successfully. Running...")
					loadstring(r)()
				else
					warn("[Auto Execute] Failed to download script: " .. tostring(r))
				end
			end
		]], ExtraSetting.Folder, ExtraSetting.AutoExecuteUrl)
		q(code)
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
		SetupQueueOnTeleport()

		pcall(function()
			local playerGui = player:FindFirstChild("PlayerGui")
			if not playerGui then return end
			fpsOverlayGui = Instance.new("ScreenGui")
			fpsOverlayGui.Name = "FluentFPSOverlay"
			fpsOverlayGui.ResetOnSpawn = false
			fpsOverlayGui.Enabled = false

			local bg = Instance.new("Frame")
			bg.Size = UDim2.fromOffset(175, 22)
			bg.Position = UDim2.new(1, -10, 0, 10)
			bg.AnchorPoint = Vector2.new(1, 0)
			bg.BackgroundColor3 = Color3.new(0, 0, 0)
			bg.BackgroundTransparency = 0.35
			bg.BorderSizePixel = 0
			bg.Parent = fpsOverlayGui

			fpsOverlayLabel = Instance.new("TextLabel")
			fpsOverlayLabel.Size = UDim2.fromScale(1, 1)
			fpsOverlayLabel.BackgroundTransparency = 1
			fpsOverlayLabel.TextColor3 = Color3.new(1, 1, 1)
			fpsOverlayLabel.TextSize = 13
			fpsOverlayLabel.Font = Enum.Font.Code
			fpsOverlayLabel.TextXAlignment = Enum.TextXAlignment.Right
			fpsOverlayLabel.Position = UDim2.fromOffset(0, 0)
			fpsOverlayLabel.Text = "FPS: -- | MEM: -- MB"
			fpsOverlayLabel.Parent = bg

			fpsOverlayGui.Parent = playerGui
		end)

		if self.SavedConfig.EnableFPSOverlay then
			SetFpsOverlay(true)
		end

		if self.SavedConfig.DisablePurchasePrompts then
			TogglePurchasePrompts(true)
		end

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

		if self.SavedConfig.EnableAutoRejoin and ExtraSetting.AutoExecuteUrl then
			StartAutoRejoinTimerLoop()
		end

		if self.Library and self.Library.OnUnload then
			self.Library.OnUnload:Once(Cleanup)
		end
	end

	function ExtraSetting:BuildExtraSection(tab)
		assert(self.Library, "Must set ExtraSetting.Library")
		if not inited then self:Init() end
		local lib = self.Library
		local cfg = self.SavedConfig

		do
			local section = tab:AddSection("Utilities")

			section:AddButton({
				Title = "Fluent Renewed Plus",
				Description = "Lamduck2005 > Fluent-Renewed-Plus",
				Callback = function()
					local ok = pcall(function() setclipboard("https://github.com/lamduck2005/Fluent-Renewed-Plus") end)
					lib:Notify({
						Title = "Links",
						Content = ok and "Link copied to clipboard!" or "Clipboard not available",
						Duration = 3,
					})
				end,
			})

			if self.Discord then
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

			section:AddDivider()

			section:AddToggle("ExtraSetting_DisablePurchasePrompts", {
				Title = "Disable Purchase Prompts",
				Description = "Block Robux and gamepass purchase popups",
				Default = cfg.DisablePurchasePrompts,
				Callback = function(Value)
					cfg.DisablePurchasePrompts = Value
					SaveConfig()
					TogglePurchasePrompts(Value)
				end,
			})

			section:AddToggle("ExtraSetting_AntiAFK", {
				Title = "Anti-AFK",
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
			local section = tab:AddSection("Performance & Automation")

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
				Title = "FPS Boost",
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

			section:AddToggle("ExtraSetting_FPSOverlay", {
				Title = "FPS Overlay",
				Description = "Shows FPS and Lua memory usage on screen",
				Default = cfg.EnableFPSOverlay,
				Callback = function(v)
					cfg.EnableFPSOverlay = v
					SaveConfig()
					SetFpsOverlay(v)
				end,
			})

			section:AddDivider()

			local afkToggle = section:AddToggle("ExtraSetting_AFKMode", {
				Title = "AFK Mode",
				Description = "Disables 3D rendering and mutes audio to reduce resource usage",
				Default = false,
				Callback = function(v)
					isAFKModeEnabled = v
					ToggleAFKMode(v)
				end,
			})
			afkToggleRef = afkToggle

			local afkOptions = { "Disabled", "10 Seconds", "1 Minute", "3 Minutes", "5 Minutes", "10 Minutes", "15 Minutes", "30 Minutes" }
			local afkMap = {
				["Disabled"] = 0,
				["10 Seconds"] = 10,
				["1 Minute"] = 60,
				["3 Minutes"] = 180,
				["5 Minutes"] = 300,
				["10 Minutes"] = 600,
				["15 Minutes"] = 900,
				["30 Minutes"] = 1800,
			}
			local defaultAfkOption = "Disabled"
			if cfg.EnableAutoAFK then
				for label, sec in pairs(afkMap) do
					if sec == (cfg.AutoAFKTime or 300) then
						defaultAfkOption = label
						break
					end
				end
			end

			section:AddDropdown("ExtraSetting_AutoAFKTimer", {
				Title = "Auto AFK Mode",
				Values = afkOptions,
				Default = defaultAfkOption,
				Callback = function(val)
					local sec = afkMap[val] or 0
					if sec == 0 then
						isAutoAFKEnabled = false
						cfg.EnableAutoAFK = false
					else
						isAutoAFKEnabled = true
						cfg.EnableAutoAFK = true
						cfg.AutoAFKTime = sec
						autoAFKTimeThreshold = sec
						lastActivityTime = tick()
						StartAutoAFKLoop()
					end
					SaveConfig()
				end,
			})

			local hasQueue = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
			if hasQueue and ExtraSetting.AutoExecuteUrl then
				section:AddDivider()

				local rejoinOptions = { "Disabled", "15 Minutes", "30 Minutes", "1 Hour", "2 Hours", "4 Hours", "6 Hours", "8 Hours", "12 Hours" }
				local rejoinMap = {
					["Disabled"] = 0,
					["15 Minutes"] = 15,
					["30 Minutes"] = 30,
					["1 Hour"] = 60,
					["2 Hours"] = 120,
					["4 Hours"] = 240,
					["6 Hours"] = 360,
					["8 Hours"] = 480,
					["12 Hours"] = 720,
				}
				local defaultRejoinOption = "Disabled"
				if cfg.EnableAutoRejoin then
					for label, mins in pairs(rejoinMap) do
						if math.abs(mins - (cfg.AutoRejoinMinutes or 60)) < 0.01 then
							defaultRejoinOption = label
							break
						end
					end
				end

				section:AddDropdown("ExtraSetting_AutoRejoinTimer", {
					Title = "Auto Rejoin",
					Description = "Not recommended",
					Values = rejoinOptions,
					Default = defaultRejoinOption,
					Callback = function(val)
						local mins = rejoinMap[val] or 0
						if mins == 0 then
							cfg.EnableAutoRejoin = false
						else
							cfg.EnableAutoRejoin = true
							cfg.AutoRejoinMinutes = mins
							cfg.EnableAutoExecute = true
							local autoExecOption = lib.Options and lib.Options.ExtraSetting_AutoExecute
							if autoExecOption then
								autoExecOption:SetValue(true)
							end
							autoRejoinTimerStartTime = tick()
							StartAutoRejoinTimerLoop()
						end
						SaveConfig()
					end,
				})

				section:AddToggle("ExtraSetting_AutoExecute", {
					Title = "Auto Execute",
					Description = "Only takes effect after rejoining",
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
