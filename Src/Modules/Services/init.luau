--[[
	Service provider registry for the key system.
	Each entry maps a Type string to { Name, Icon, Args, New }.
	Args lists the config keys the service expects from API[] entries.
]]

local RunService = game:GetService("RunService")
local IsStudio = RunService:IsStudio()

local mockNew = function()
	return {
		Verify = function() return true, "Studio Mode" end,
		Copy = function() end,
	}
end

local Services = {
	platoboost = {
		Name = "Platoboost",
		Icon = "rbxassetid://75920162824531",
		Args = { "ServiceId", "Secret" },
		New = (not IsStudio) and require(script.Platoboost).New or mockNew,
	},
	pandadevelopment = {
		Name = "Panda Development",
		Icon = "cat",
		Args = { "ServiceId" },
		New = (not IsStudio) and require(script.PandaDevelopment).New or mockNew,
	},
	luarmor = {
		Name = "Luarmor",
		Icon = "rbxassetid://130918283130165",
		Args = { "ScriptId", "Discord" },
		New = (not IsStudio) and require(script.Luarmor).New or mockNew,
	},
	junkiedevelopment = {
		Name = "Junkie Development",
		Icon = "rbxassetid://106310347705078",
		Args = { "ServiceId", "ApiKey", "Provider" },
		New = (not IsStudio) and require(script.JunkieDevelopment).New or mockNew,
	},
}

return Services
