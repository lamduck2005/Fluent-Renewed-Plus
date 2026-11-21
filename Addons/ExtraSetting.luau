local httpService = game:GetService("HttpService")
local players = game:GetService("Players")
local player = players.LocalPlayer
local virtualUser = game:GetService("VirtualUser")
local guiService = game:GetService("GuiService")
local teleportService = game:GetService("TeleportService")
local runService = game:GetService("RunService")
local statsService = game:GetService("Stats")
local userInputService = game:GetService("UserInputService")

local DISCONNECT_ERROR_CODES = {
	[260] = true,
	[261] = true,
	[262] = true,
	[266] = true,
	[274] = true,
	[275] = true,
	[277] = true,
	[278] = true,
	[279] = true,
	[282] = true,
	[284] = true,
	[286] = true,
	[288] = true,
}

local RECONNECT_TRIGGER_PHRASES = {
	"idle",
	"inactivity",
	"278",
	"lost connection",
	"check your internet",
	"reconnect",
	"connection attempt failed",
	"error receiving data",
	"error sending data",
	"problem sending data",
	"server has shut down",
	"experience has shut down",
	"server is full",
	"unexpected client behavior",
	"277",
	"266",
	"279",
}

local RECONNECT_IGNORE_PHRASES = {
	"auto reconnecting",
	"saveinstance",
	"saving",
	"banned",
	"exploiting",
	"cheat",
}

local ExtraSetting = {} do
	ExtraSetting.Folder = "FluentSettings"
	ExtraSetting.Library = nil
	ExtraSetting.Links = {}
	ExtraSetting.AutoExecuteUrl = nil
	ExtraSetting.RandomNotifyConfig = nil

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
		EnableRandomNotify = true,
		DisablePurchasePrompts = true,
		WalkSpeed = 30,
		EnableWalkSpeed = false,
		JumpPower = 50,
		EnableJumpPower = false,
		EnableNoclip = false,
	}

	local isFPSBoostApplied = false
	local isAFKModeEnabled = false
	local isAutoAFKEnabled = false
	local autoAFKTimeThreshold = 300
	local lastActivityTime = os.clock()
	local lastClickTime = 0
	local afkStartTime = 0
	local isAutoAFKLoopRunning = false
	local afkInfoThread = nil
	local OriginalVolume = 1
	local HasMutedAudio = false
	local isAutoRejoinTimerRunning = false
	local autoRejoinTimerStartTime = os.clock()
	local isReconnecting = false
	local reconnectThread = nil
	local connTeleportFailed = nil
	local afkExtraInfo = {}
	local afkToggleRef = nil
	local connIdled = nil
	local antiAfkThread = nil
	local connErrorMessage = nil
	local originalWalkSpeed = nil
	local originalJumpPower = nil
	local originalJumpHeight = nil
	local isWalkSpeedLoopRunning = false
	local isJumpPowerLoopRunning = false
	local connNoclip = nil
	local connNoclipChar = nil
	local connNoclipDescendant = nil
	local connNoclipRemoving = nil
	local noclipParts = {}
	local fpsOverlayConn
	local fpsCount, fpsTime, currentFps = 0, 0, 0
	local perfStartTime, lastLogTime, lastLuaMb, lastTotalMb = 0, 0, 0, 0
	local fpsOverlayGui
	local fpsOverlayLabel
	local inited = false
	local saveConfigThread = nil
	local randomNotifyThread = nil
	local isRandomNotifyRunning = false

	local function GetGuiContainer()
		local success, result = pcall(function()
			return (gethui or get_hidden_ui)()
		end)
		if success and result then return result end

		success, result = pcall(function()
			local coreGui = game:GetService("CoreGui")
			coreGui:GetFullName()
			return coreGui
		end)
		if success and result then return result end

		return player:FindFirstChild("PlayerGui")
	end

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

	local function DebouncedSaveConfig()
		if saveConfigThread then
			task.cancel(saveConfigThread)
		end
		saveConfigThread = task.delay(0.5, function()
			saveConfigThread = nil
			SaveConfig()
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

	local function ExecuteReconnect()
		if isReconnecting then return end
		isReconnecting = true

		local placeId = game.PlaceId
		local jobId = game.JobId

		if #players:GetPlayers() <= 1 then
			pcall(function()
				player:Kick("\nAuto Reconnecting... Don't click anything!")
			end)
		end

		if not connTeleportFailed then
			connTeleportFailed = teleportService.TeleportInitFailed:Connect(function()
				task.wait(2)
				pcall(function()
					teleportService:Teleport(placeId, player)
				end)
			end)
		end

		reconnectThread = task.spawn(function()
			while true do
				pcall(function()
					if #players:GetPlayers() <= 1 then
						teleportService:Teleport(placeId, player)
					else
						local success = pcall(function()
							teleportService:TeleportToPlaceInstance(placeId, jobId, player)
						end)
						if not success then
							teleportService:Teleport(placeId, player)
						end
					end
				end)
				task.wait(30)
			end
		end)
	end

	local function ExecuteRejoin()
		ExecuteReconnect()
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
		local container = GetGuiContainer()

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
			if container then
				local blackout = container:FindFirstChild("AFKBlackoutScreenGui")
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

		if not container then return end
		local blackoutScreenGui = container:FindFirstChild("AFKBlackoutScreenGui")
		if not blackoutScreenGui then
			blackoutScreenGui = Instance.new("ScreenGui")
			blackoutScreenGui.Name = "AFKBlackoutScreenGui"
			blackoutScreenGui.IgnoreGuiInset = true
			blackoutScreenGui.DisplayOrder = 2147483646
			blackoutScreenGui.ResetOnSpawn = false

			local backgroundFrame = Instance.new("TextButton")
			backgroundFrame.Name = "Background"
			backgroundFrame.Size = UDim2.new(1, 0, 1, 0)
			backgroundFrame.BackgroundColor3 = Color3.new(0, 0, 0)
			backgroundFrame.Text = ""
			backgroundFrame.AutoButtonColor = false
			backgroundFrame.Active = true
			backgroundFrame.Parent = blackoutScreenGui

			backgroundFrame.MouseButton1Click:Connect(function()
				local now = os.clock()
				if now - lastClickTime < 0.5 then
					isAFKModeEnabled = false
					ToggleAFKMode(false)
					pcall(function() afkToggleRef:SetValue(false) end)
					lastActivityTime = os.clock()
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

			pcall(function() blackoutScreenGui.Parent = container end)
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
				local actualFps = 0
				pcall(function()
					actualFps = math.floor(statsService.Workspace.Heartbeat:GetValue())
				end)
				local ramUsage = 0
				pcall(function()
					ramUsage = math.floor(statsService:GetTotalMemoryUsageMb())
				end)
				local hours = math.floor(duration / 3600)
				local minutes = math.floor((duration % 3600) / 60)
				local seconds = duration % 60
				local timeStr = string.format("%02d:%02d:%02d", hours, minutes, seconds)

				local statusParts = {}
				if cfg.EnableAutoRejoin and isAutoRejoinTimerRunning then
					local remain = math.max(0, (cfg.AutoRejoinMinutes * 60) - math.floor(os.clock() - autoRejoinTimerStartTime))
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
			lastActivityTime = os.clock()
			while isAutoAFKEnabled do
				if not isAFKModeEnabled then
					local idleTime = os.clock() - lastActivityTime
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
			autoRejoinTimerStartTime = os.clock()
			while ExtraSetting.SavedConfig.EnableAutoRejoin do
				local elapsed = (os.clock() - autoRejoinTimerStartTime) / 60
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

	local function SendAntiAFKInput()
		print(string.format("[Anti-AFK] Triggered at %s", os.date("%X")))

		pcall(function()
			virtualUser:CaptureController()
			virtualUser:ClickButton2(Vector2.new())
		end)

		pcall(function()
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				humanoid:Move(Vector3.new(0, 0, -0.001), false)
			end
		end)
	end

	local function StopAntiAFK()
		if connIdled then
			connIdled:Disconnect()
			connIdled = nil
		end
		if antiAfkThread then
			pcall(task.cancel, antiAfkThread)
			antiAfkThread = nil
		end
	end

	local function InitAntiAFK()
		StopAntiAFK()

		pcall(function()
			for _, v in pairs(getconnections(player.Idled)) do v:Disable() end
		end)
		connIdled = player.Idled:Connect(function()
			SendAntiAFKInput()
		end)

		antiAfkThread = task.spawn(function()
			while ExtraSetting.SavedConfig.EnableAntiAFK do
				task.wait(600)
				if not ExtraSetting.SavedConfig.EnableAntiAFK then break end
				SendAntiAFKInput()
			end
		end)
	end

	local function InitAutoReconnect()
		if connErrorMessage then
			connErrorMessage:Disconnect()
			connErrorMessage = nil
		end

		connErrorMessage = guiService.ErrorMessageChanged:Connect(function(msg)
			if isReconnecting then return end
			if not msg or msg == "" then return end

			local low = string.lower(msg)
			for _, phrase in ipairs(RECONNECT_IGNORE_PHRASES) do
				if string.find(low, phrase) then
					return
				end
			end

			local shouldReconnect = false

			local code = nil
			pcall(function()
				local errEnum = guiService:GetErrorCode()
				if errEnum and errEnum.Value then
					code = errEnum.Value
				end
			end)

			if code and DISCONNECT_ERROR_CODES[code] then
				shouldReconnect = true
			else
				for _, phrase in ipairs(RECONNECT_TRIGGER_PHRASES) do
					if string.find(low, phrase) then
						shouldReconnect = true
						break
					end
				end
			end

			if not shouldReconnect then return end

			print("[ExtraSetting] Disconnected / AFK: " .. tostring(msg))
			print("[ExtraSetting] Reconnecting...")
			ExecuteReconnect()
		end)
	end

	local function SetFpsOverlay(enabled)
		if not fpsOverlayGui then return end
		fpsOverlayGui.Enabled = enabled
		if enabled then
			if fpsOverlayConn then return end
			fpsCount, fpsTime = 0, os.clock()
			perfStartTime = os.clock()
			lastLogTime = os.clock()
			lastLuaMb = gcinfo() / 1024
			lastTotalMb = statsService and statsService:GetTotalMemoryUsageMb() or 0
			fpsOverlayConn = runService.RenderStepped:Connect(function()
				fpsCount += 1
				local now = os.clock()
				if now - fpsTime >= 1 then
					currentFps = math.floor(fpsCount / (now - fpsTime))
					fpsCount, fpsTime = 0, now
					local curLuaMb = gcinfo() / 1024
					fpsOverlayLabel.Text = string.format("FPS: %d | Mem: %d MB", currentFps, math.floor(curLuaMb))

					local nowClock = os.clock()
					if nowClock - lastLogTime >= 300 then
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

	local function StartWalkSpeedLoop()
		if isWalkSpeedLoopRunning then return end
		isWalkSpeedLoopRunning = true

		task.spawn(function()
			while not (ExtraSetting.Library and ExtraSetting.Library.Unloaded) and ExtraSetting.SavedConfig.EnableWalkSpeed do
				local char = player.Character
				local hum = char and char:FindFirstChildWhichIsA("Humanoid")
				if hum then
					if originalWalkSpeed == nil then
						originalWalkSpeed = hum.WalkSpeed
					end
					local targetSpeed = ExtraSetting.SavedConfig.WalkSpeed or 30
					if hum.WalkSpeed ~= targetSpeed then
						hum.WalkSpeed = targetSpeed
					end
				end
				task.wait(0.1)
			end

			local char = player.Character
			local hum = char and char:FindFirstChildWhichIsA("Humanoid")
			if hum and originalWalkSpeed then
				hum.WalkSpeed = originalWalkSpeed
			end
			isWalkSpeedLoopRunning = false
		end)
	end

	local function SetWalkSpeed(enabled)
		if enabled then
			StartWalkSpeedLoop()
		else
			local char = player.Character
			local hum = char and char:FindFirstChildWhichIsA("Humanoid")
			if hum and originalWalkSpeed then
				hum.WalkSpeed = originalWalkSpeed
			end
		end
	end

	local function StartJumpPowerLoop()
		if isJumpPowerLoopRunning then return end
		isJumpPowerLoopRunning = true

		task.spawn(function()
			while not (ExtraSetting.Library and ExtraSetting.Library.Unloaded) and ExtraSetting.SavedConfig.EnableJumpPower do
				local char = player.Character
				local hum = char and char:FindFirstChildWhichIsA("Humanoid")
				if hum then
					local targetPower = ExtraSetting.SavedConfig.JumpPower or 50
					if hum.UseJumpPower then
						if originalJumpPower == nil then
							originalJumpPower = hum.JumpPower
						end
						if hum.JumpPower ~= targetPower then
							hum.JumpPower = targetPower
						end
					else
						if originalJumpHeight == nil then
							originalJumpHeight = hum.JumpHeight
						end
						if hum.JumpHeight ~= targetPower then
							hum.JumpHeight = targetPower
						end
					end
				end
				task.wait(0.1)
			end

			local char = player.Character
			local hum = char and char:FindFirstChildWhichIsA("Humanoid")
			if hum then
				if hum.UseJumpPower and originalJumpPower then
					hum.JumpPower = originalJumpPower
				elseif not hum.UseJumpPower and originalJumpHeight then
					hum.JumpHeight = originalJumpHeight
				end
			end
			isJumpPowerLoopRunning = false
		end)
	end

	local function SetJumpPower(enabled)
		if enabled then
			StartJumpPowerLoop()
		else
			local char = player.Character
			local hum = char and char:FindFirstChildWhichIsA("Humanoid")
			if hum then
				if hum.UseJumpPower and originalJumpPower then
					hum.JumpPower = originalJumpPower
				elseif not hum.UseJumpPower and originalJumpHeight then
					hum.JumpHeight = originalJumpHeight
				end
			end
		end
	end

	local function UpdateNoclipCache(char)
		table.clear(noclipParts)
		if connNoclipDescendant then
			connNoclipDescendant:Disconnect()
			connNoclipDescendant = nil
		end
		if connNoclipRemoving then
			connNoclipRemoving:Disconnect()
			connNoclipRemoving = nil
		end
		if not char then return end

		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				table.insert(noclipParts, part)
			end
		end

		connNoclipDescendant = char.DescendantAdded:Connect(function(part)
			if part:IsA("BasePart") then
				table.insert(noclipParts, part)
			end
		end)

		connNoclipRemoving = char.DescendantRemoving:Connect(function(part)
			if part:IsA("BasePart") then
				local idx = table.find(noclipParts, part)
				if idx then
					table.remove(noclipParts, idx)
				end
			end
		end)
	end

	local function SetNoclip(enabled)
		if connNoclip then
			connNoclip:Disconnect()
			connNoclip = nil
		end
		if connNoclipChar then
			connNoclipChar:Disconnect()
			connNoclipChar = nil
		end
		if connNoclipDescendant then
			connNoclipDescendant:Disconnect()
			connNoclipDescendant = nil
		end
		if connNoclipRemoving then
			connNoclipRemoving:Disconnect()
			connNoclipRemoving = nil
		end

		if enabled then
			UpdateNoclipCache(player.Character)
			connNoclipChar = player.CharacterAdded:Connect(function(char)
				UpdateNoclipCache(char)
			end)

			connNoclip = runService.Stepped:Connect(function()
				if (ExtraSetting.Library and ExtraSetting.Library.Unloaded) or not ExtraSetting.SavedConfig.EnableNoclip then
					SetNoclip(false)
					return
				end
				for _, part in ipairs(noclipParts) do
					if part.Parent and part.CanCollide then
						part.CanCollide = false
					end
				end
			end)
		else
			for _, part in ipairs(noclipParts) do
				if part.Parent then
					part.CanCollide = true
				end
			end
			table.clear(noclipParts)
		end
	end

	local function StopRandomNotify()
		if randomNotifyThread then
			pcall(task.cancel, randomNotifyThread)
			randomNotifyThread = nil
		end
		isRandomNotifyRunning = false
	end

	local function StartRandomNotifyLoop()
		StopRandomNotify()
		local cfg = ExtraSetting.RandomNotifyConfig
		if not cfg or not cfg.Messages or #cfg.Messages == 0 then return end
		if not ExtraSetting.SavedConfig.EnableRandomNotify then return end

		isRandomNotifyRunning = true
		randomNotifyThread = task.spawn(function()
			local interval = cfg.Interval or {}
			local minTime = math.max(5, interval.Min or interval.min or 300)
			local maxTime = math.max(minTime, interval.Max or interval.max or 600)
			local lastIdx = nil

			while isRandomNotifyRunning and not (ExtraSetting.Library and ExtraSetting.Library.Unloaded) and ExtraSetting.SavedConfig.EnableRandomNotify do
				local waitSec = math.random(minTime, maxTime)
				task.wait(waitSec)

				if not isRandomNotifyRunning or not ExtraSetting.SavedConfig.EnableRandomNotify or (ExtraSetting.Library and ExtraSetting.Library.Unloaded) then
					break
				end

				local msgs = cfg.Messages
				if msgs and #msgs > 0 and ExtraSetting.Library then
					local idx = math.random(1, #msgs)
					if #msgs > 1 and idx == lastIdx then
						idx = (idx % #msgs) + 1
					end
					lastIdx = idx

					local msg = msgs[idx]
					if msg and msg.Content then
						ExtraSetting.Library:Notify({
							Title = msg.Title or "Notification",
							SubTitle = msg.SubTitle,
							Content = msg.Content,
							Duration = msg.Duration or cfg.Duration or 6,
						})
					end
				end
			end
			isRandomNotifyRunning = false
		end)
	end

	local function Cleanup()
		if saveConfigThread then
			task.cancel(saveConfigThread)
			saveConfigThread = nil
			SaveConfig()
		end

		if connTeleportFailed then
			connTeleportFailed:Disconnect()
			connTeleportFailed = nil
		end

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

		StopAntiAFK()
		StopRandomNotify()
		if connErrorMessage then
			connErrorMessage:Disconnect()
			connErrorMessage = nil
		end

		SetWalkSpeed(false)
		SetJumpPower(false)
		SetNoclip(false)
		originalWalkSpeed = nil
		originalJumpPower = nil
		originalJumpHeight = nil

		pcall(function()
			local container = GetGuiContainer()
			if container then
				local b = container:FindFirstChild("AFKBlackoutScreenGui")
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
		if reconnectThread then
			task.cancel(reconnectThread)
			reconnectThread = nil
		end
		isReconnecting = false
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
				print("[Auto Execute] Rejoined. Waiting 5s for game to load...")
				task.wait(5)
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

	function ExtraSetting:AddLink(linkData)
		table.insert(self.Links, linkData)
	end

	function ExtraSetting:SetLinks(links)
		self.Links = links or {}
	end

	function ExtraSetting:SetRandomNotify(config)
		if type(config) == "table" then
			if config.Messages then
				self.RandomNotifyConfig = config
			elseif #config > 0 then
				self.RandomNotifyConfig = { Messages = config }
			else
				self.RandomNotifyConfig = config
			end
		else
			self.RandomNotifyConfig = nil
		end

		if inited and self.SavedConfig.EnableRandomNotify then
			StartRandomNotifyLoop()
		end
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
			InitAutoReconnect()
		end
		SetupQueueOnTeleport()

		pcall(function()
			local container = GetGuiContainer()
			if not container then return end
			fpsOverlayGui = Instance.new("ScreenGui")
			fpsOverlayGui.Name = "FluentFPSOverlay"
			fpsOverlayGui.ResetOnSpawn = false
			fpsOverlayGui.IgnoreGuiInset = true
			fpsOverlayGui.DisplayOrder = 2147483647
			fpsOverlayGui.Enabled = false

			local bg = Instance.new("Frame")
			bg.Size = UDim2.fromOffset(175, 22)
			bg.Position = UDim2.new(1, -10, 0, 10)
			bg.AnchorPoint = Vector2.new(1, 0)
			bg.BackgroundColor3 = Color3.new(0, 0, 0)
			bg.BackgroundTransparency = 0.35
			bg.BorderSizePixel = 0
			bg.ZIndex = 2147483647
			bg.Parent = fpsOverlayGui

			fpsOverlayLabel = Instance.new("TextLabel")
			fpsOverlayLabel.Size = UDim2.fromScale(1, 1)
			fpsOverlayLabel.BackgroundTransparency = 1
			fpsOverlayLabel.TextColor3 = Color3.new(1, 1, 1)
			fpsOverlayLabel.TextSize = 13
			fpsOverlayLabel.Font = Enum.Font.Code
			fpsOverlayLabel.TextXAlignment = Enum.TextXAlignment.Right
			fpsOverlayLabel.Position = UDim2.fromOffset(0, 0)
			fpsOverlayLabel.ZIndex = 2147483647
			fpsOverlayLabel.Text = "FPS: -- | MEM: -- MB"
			fpsOverlayLabel.Parent = bg

			fpsOverlayGui.Parent = container
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

		if self.SavedConfig.EnableWalkSpeed then
			SetWalkSpeed(true)
		end
		if self.SavedConfig.EnableJumpPower then
			SetJumpPower(true)
		end
		if self.SavedConfig.EnableNoclip then
			SetNoclip(true)
		end

		if self.SavedConfig.EnableAutoRejoin and ExtraSetting.AutoExecuteUrl then
			StartAutoRejoinTimerLoop()
		end

		if self.SavedConfig.EnableRandomNotify and self.RandomNotifyConfig then
			StartRandomNotifyLoop()
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

			if type(self.Links) == "table" and #self.Links > 0 then
				for _, link in ipairs(self.Links) do
					if type(link) == "table" and link.Url then
						section:AddButton({
							Title = link.Title or "Link",
							Description = link.Description,
							Callback = function()
								local ok = pcall(function() setclipboard(link.Url) end)
								lib:Notify({
									Title = link.Title or "Links",
									Content = ok and "Link copied to clipboard!" or "Clipboard not available",
									Duration = 3,
								})
							end,
						})
					end
				end
				section:AddDivider()
			end

			section:AddSlider("ExtraSetting_WalkSpeed", {
				Title = "WalkSpeed",
				Default = cfg.WalkSpeed or 30,
				Min = 20,
				Max = 200,
				Rounding = 0,
				Callback = function(value)
					cfg.WalkSpeed = value
					DebouncedSaveConfig()
					if cfg.EnableWalkSpeed then
						local char = player.Character
						local hum = char and char:FindFirstChildWhichIsA("Humanoid")
						if hum then
							hum.WalkSpeed = value
						end
					end
				end,
			})

			section:AddToggle("ExtraSetting_EnableWalkSpeed", {
				Title = "Enable WalkSpeed",
				Default = cfg.EnableWalkSpeed,
				Callback = function(value)
					cfg.EnableWalkSpeed = value
					SaveConfig()
					SetWalkSpeed(value)
				end,
			})

			section:AddDivider()

			section:AddSlider("ExtraSetting_JumpPower", {
				Title = "JumpPower",
				Default = cfg.JumpPower or 50,
				Min = 20,
				Max = 200,
				Rounding = 0,
				Callback = function(value)
					cfg.JumpPower = value
					DebouncedSaveConfig()
					if cfg.EnableJumpPower then
						local char = player.Character
						local hum = char and char:FindFirstChildWhichIsA("Humanoid")
						if hum then
							if hum.UseJumpPower then
								hum.JumpPower = value
							else
								hum.JumpHeight = value
							end
						end
					end
				end,
			})

			section:AddToggle("ExtraSetting_EnableJumpPower", {
				Title = "Enable JumpPower",
				Default = cfg.EnableJumpPower,
				Callback = function(value)
					cfg.EnableJumpPower = value
					SaveConfig()
					SetJumpPower(value)
				end,
			})

			section:AddDivider()

			section:AddToggle("ExtraSetting_Noclip", {
				Title = "Noclip",
				Default = cfg.EnableNoclip,
				Callback = function(value)
					cfg.EnableNoclip = value
					SaveConfig()
					SetNoclip(value)
				end,
			})

			section:AddDivider()

			section:AddToggle("ExtraSetting_DisablePurchasePrompts", {
				Title = "Disable Purchase Prompts",
				Default = cfg.DisablePurchasePrompts,
				Callback = function(Value)
					cfg.DisablePurchasePrompts = Value
					SaveConfig()
					TogglePurchasePrompts(Value)
				end,
			})

			if self.RandomNotifyConfig and self.RandomNotifyConfig.Messages and #self.RandomNotifyConfig.Messages > 0 then
				section:AddToggle("ExtraSetting_RandomNotify", {
					Title = "Tips & Announcements",
					Default = cfg.EnableRandomNotify,
					Callback = function(v)
						cfg.EnableRandomNotify = v
						SaveConfig()
						if v then
							StartRandomNotifyLoop()
						else
							StopRandomNotify()
						end
					end,
				})
			end

			section:AddToggle("ExtraSetting_AutoReconnect", {
				Title = "Auto Reconnect",
				Default = cfg.EnableAutoReconnect,
				Callback = function(v)
					cfg.EnableAutoReconnect = v
					SaveConfig()
					if v then
						InitAutoReconnect()
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
				Description = "Disables 3D rendering + mutes",
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
						lastActivityTime = os.clock()
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
							autoRejoinTimerStartTime = os.clock()
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
