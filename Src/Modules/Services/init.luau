--[[
	Service provider registry for the key system.
	Each entry maps a Type string to { Name, Icon, Args, New }.
	Args lists the config keys the service expects from API[] entries.
]]

local Services = {
	platoboost = {
		Name = "Platoboost",
		Icon = "rbxassetid://75920162824531",
		Args = { "ServiceId", "Secret" },
		New = require(script.Platoboost).New,
	},
	pandadevelopment = {
		Name = "Panda Development",
		Icon = "cat",
		Args = { "ServiceId" },
		New = require(script.PandaDevelopment).New,
	},
	luarmor = {
		Name = "Luarmor",
		Icon = "rbxassetid://130918283130165",
		Args = { "ScriptId", "Discord" },
		New = require(script.Luarmor).New,
	},
	junkiedevelopment = {
		Name = "Junkie Development",
		Icon = "rbxassetid://106310347705078",
		Args = { "ServiceId", "ApiKey", "Provider" },
		New = require(script.JunkieDevelopment).New,
	},
}

return Services
