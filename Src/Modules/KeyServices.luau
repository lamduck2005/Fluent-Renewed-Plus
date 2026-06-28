local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local httpRequest = syn and syn.request or http_request or request or function()
	return { Success = false, StatusCode = 0, Body = "No HTTP library available" }
end

local function getHwid()
	return gethwid and gethwid() or Players.LocalPlayer.UserId
end

local function setClipboard(text)
	local fn = setclipboard or function() end
	fn(text)
end

local KeyServices = {}

do
	local Platoboost = {}

	function Platoboost.New(Service, Secret)
		local cachedLink = ""

		local function cacheLink()
			local ok, result = pcall(httpRequest, {
				Url = "https://api.platoboost.com/v1/keys/link",
				Method = "POST",
				Headers = { ["Content-Type"] = "application/json" },
				Body = HttpService:JSONEncode({
					service = Service,
					secret = Secret
				})
			})
			if ok and result.Success and result.StatusCode == 200 then
				local data = HttpService:JSONDecode(result.Body)
				cachedLink = data.link or ""
			end
		end

		local function verifyKey(key)
			local ok, result = pcall(httpRequest, {
				Url = "https://api.platoboost.com/v1/keys/validate",
				Method = "POST",
				Headers = { ["Content-Type"] = "application/json" },
				Body = HttpService:JSONEncode({
					key = key,
					service = Service,
					secret = Secret
				})
			})
			if ok and result.Success and result.StatusCode == 200 then
				local data = HttpService:JSONDecode(result.Body)
				return true, data.message or ""
			end
			return false, (result and result.Body) or "Failed to validate key"
		end

		local function copyLink()
			cacheLink()
			if cachedLink ~= "" then
				setClipboard(cachedLink)
			end
		end

		return {
			Verify = verifyKey,
			Copy = copyLink
		}
	end

	KeyServices.platoboost = {
		Name = "Platoboost",
		Icon = "rbxassetid://75920162824531",
		Args = { "ServiceId", "Secret" },
		New = Platoboost.New
	}
end

do
	local PandaDevelopment = {}

	function PandaDevelopment.New(serviceId)
		local hwid = getHwid()

		local function ValidateKey(key)
			local ok, result = pcall(httpRequest, {
				Url = "https://new.pandadevelopment.net/api/v1/keys/validate",
				Method = "POST",
				Headers = { ["Content-Type"] = "application/json" },
				Body = HttpService:JSONEncode({
					key = key,
					serviceId = serviceId,
					hwid = hwid
				})
			})
			if ok and result.Success and result.StatusCode == 200 then
				local data = HttpService:JSONDecode(result.Body)
				return data.success or false, data.message or ""
			end
			return false, (result and result.Body) or "Failed to validate key"
		end

		local function CopyLink()
			setClipboard("https://new.pandadevelopment.net/getkey/" .. serviceId .. "?hwid=" .. tostring(hwid))
		end

		return {
			Verify = ValidateKey,
			Copy = CopyLink
		}
	end

	KeyServices.pandadevelopment = {
		Name = "Panda Development",
		Icon = "panda",
		Args = { "ServiceId" },
		New = PandaDevelopment.New
	}
end

do
	local JunkieDevelopment = {}

	function JunkieDevelopment.New(ServiceId, ApiKey, Provider)
		local function ValidateKey(key)
			if not JunkieProtected then
				return false, "JunkieProtected is not available"
			end
			local success, result = pcall(JunkieProtected.ValidateKey, JunkieProtected, key)
			if success and result then
				return true, "Key is valid!"
			end
			return false, tostring(result or "Invalid key")
		end

		local function copyLink()
			if JunkieProtected and JunkieProtected.GetKeyLink then
				local success, link = pcall(JunkieProtected.GetKeyLink, JunkieProtected)
				if success and link then
					setClipboard(link)
				end
			end
		end

		return {
			Verify = ValidateKey,
			Copy = copyLink
		}
	end

	KeyServices.junkiedevelopment = {
		Name = "Junkie Development",
		Icon = "rbxassetid://106310347705078",
		Args = { "ServiceId", "ApiKey", "Provider" },
		New = JunkieDevelopment.New
	}
end

do
	local Luarmor = {}

	function Luarmor.New(scriptId, discord)
		local function ValidateKey(key)
			if not API then
				return false, "Luarmor API is not available"
			end
			local success, result = pcall(API.check_key, API, key)
			if success and result then
				return true, "Whitelisted!"
			end
			return false, tostring(result or "Invalid key")
		end

		local function CopyLink()
			if discord then
				setClipboard(discord)
			end
		end

		return {
			Verify = ValidateKey,
			Copy = CopyLink
		}
	end

	KeyServices.luarmor = {
		Name = "Luarmor",
		Icon = "rbxassetid://130918283130165",
		Args = { "ScriptId", "Discord" },
		New = Luarmor.New
	}
end

return KeyServices
