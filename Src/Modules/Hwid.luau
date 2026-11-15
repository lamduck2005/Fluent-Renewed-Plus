local Players = game:GetService("Players")
local Analytics = game:GetService("RbxAnalyticsService")

local Hwid = {}

local function normalize(value: any): string?
	local text = tostring(value)
	if text ~= "" and text ~= "nil" then
		return text
	end
	return nil
end

function Hwid.Get(): string
	local ok, id = pcall(gethwid)
	local hwid = ok and normalize(id)
	if hwid then
		return hwid
	end

	local ok2, id2 = pcall(get_hwid)
	hwid = ok2 and normalize(id2)
	if hwid then
		return hwid
	end

	local ok3, id3 = pcall(function()
		return Analytics:GetClientId()
	end)
	hwid = ok3 and normalize(id3)
	if hwid then
		return hwid
	end

	local ok4, userId = pcall(function()
		return Players.LocalPlayer.UserId
	end)
	return if ok4 and userId ~= nil then tostring(userId) else "0"
end

return Hwid
