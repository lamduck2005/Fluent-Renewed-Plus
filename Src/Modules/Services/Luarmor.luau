-- Luarmor API | https://luarmor.net

local Luarmor = {}

function Luarmor.New(scriptId: string, discord: string?)
	local fSetClipboard = setclipboard or toclipboard

	local ok, API = pcall(function()
		local APIURL = "https://sdkapi-public.luarmor.net/library.lua"
		local source = game.HttpGet and game:HttpGet(APIURL) or game:GetService("HttpService"):GetAsync(APIURL)
		return loadstring(source)()
	end)

	if not ok then
		return {
			Verify = function()
				return false, "Luarmor API unavailable in this environment"
			end,
			Copy = function()
				if discord and fSetClipboard then
					fSetClipboard(tostring(discord))
					return true
				end
				return false
			end,
		}
	end

	API.script_id = scriptId

	local function verifyKey(key)
		local status = API.check_key(key)

		if status.code == "KEY_VALID" then
			return true, "Whitelisted!"
		elseif status.code == "KEY_HWID_LOCKED" then
			return false, "Key linked to a different HWID. Please reset it using our bot"
		elseif status.code == "KEY_INCORRECT" then
			return false, "Key is wrong or deleted!"
		end
		return false, "Key check failed: " .. status.message .. " Code: " .. status.code
	end

	local function copyLink()
		if fSetClipboard and discord then
			fSetClipboard(tostring(discord))
			return true
		end
		return false
	end

	return {
		Verify = verifyKey,
		Copy = copyLink,
	}
end

return Luarmor
