-- Panda Development API | https://pandadevelopment.net/

local Clone = (cloneref or clonereference or function(instance)
	return instance
end)
local HttpService = Clone(game:GetService("HttpService"))
local Players = Clone(game:GetService("Players"))

local fRequest = request or http_request or syn_request
local fSetClipboard = setclipboard or toclipboard
local fGetHwid = gethwid or function()
	return Players.LocalPlayer.UserId
end

local PandaDevelopment = {}

function PandaDevelopment.New(serviceId: string)
	if not fRequest then
		return {
			Unavailable = true,
			Verify = function()
				return false, "HTTP unavailable in this environment"
			end,
			Copy = function() return false end,
		}
	end

	local hwid = tostring(fGetHwid())

	local function verifyKey(key)
		local payload = HttpService:JSONEncode({
			ServiceID = serviceId,
			HWID = hwid,
			Key = tostring(key),
		})

		local success, response = pcall(function()
			return fRequest({
				Url = "https://api.pandauth.com/api/v1/keys/validate",
				Method = "POST",
				Headers = {
					["User-Agent"] = "Roblox/Exploit",
					["Content-Type"] = "application/json",
				},
				Body = payload,
			})
		end)

		if success and response then
			if response.Success then
				local decodeSuccess, jsonData = pcall(function()
					return HttpService:JSONDecode(response.Body)
				end)
				if decodeSuccess and jsonData then
					if jsonData.Authenticated_Status == "Success" then
						return true, "Authenticated"
					end
					return false, "Authentication failed: " .. (jsonData.Note or "Unknown reason")
				end
				return false, "JSON decode error"
			end
			return false, "HTTP request failed: " .. response.StatusMessage
		end
		return false, "Request error"
	end

	local function copyLink()
		fSetClipboard("https://new.pandadevelopment.net/getkey/" .. tostring(serviceId) .. "?hwid=" .. hwid)
		return true
	end

	return {
		Verify = verifyKey,
		Copy = copyLink,
	}
end

return PandaDevelopment
