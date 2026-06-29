-- Luarmor API | https://luarmor.net

local Luarmor = {}

function Luarmor.New(scriptId: string, discord: string?)
	local fSetClipboard = setclipboard or toclipboard

	local APIURL = "https://sdkapi-public.luarmor.net/library.lua"

	if not fRequest then
		return {
			Unavailable = true,
			Verify = function()
				return false, "Luarmor SDK unavailable in this environment"
			end,
			Copy = function()
				if fSetClipboard then fSetClipboard(tostring(discord)) end
				return true
			end,
		}
	end

	local function httpGet(url: string)
		if game.HttpGet then
			return game:HttpGet(url)
		end
		return game:GetService("HttpService"):GetAsync(url)
	end

	local initError = nil
	local API = nil
	local ok, result = pcall(function()
		local source = httpGet(APIURL)
		return loadstring(source)()
	end)
	if ok then
		API = result
	else
		initError = tostring(result)
	end

	if not API then
		return {
			Unavailable = false,
			Verify = function()
				return false, "Luarmor SDK failed: " .. initError
			end,
			Copy = function()
				fSetClipboard(tostring(discord))
				return true
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
		fSetClipboard(tostring(discord))
		return true
	end

	return {
		Verify = verifyKey,
		Copy = copyLink,
	}
end

return Luarmor
