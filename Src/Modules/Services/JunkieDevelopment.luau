-- Junkie Development API

local JunkieDevelopment = {}

function JunkieDevelopment.New(serviceId: string, apiKey: string, provider: string)
	if not JunkieProtected then
		return {
			Verify = function()
				return false, "JunkieProtected not available"
			end,
			Copy = function() return false end,
		}
	end

	JunkieProtected.API_KEY = apiKey
	JunkieProtected.PROVIDER = provider
	JunkieProtected.SERVICE_ID = serviceId

	local function verifyKey(key)
		if not key or key == "" then
			return false, "No key provided. Please get a key."
		end

		local keylessCheck = JunkieProtected.IsKeylessMode()
		if keylessCheck and keylessCheck.keyless_mode then
			return true, "Keyless mode enabled. Starting script..."
		end

		local result = JunkieProtected.ValidateKey({ Key = key })
		if result == "valid" then
			return true, "Key is valid!"
		end
		return false, "Invalid key. Get one from: " .. JunkieProtected.GetKeyLink()
	end

	local function copyLink()
		local link = JunkieProtected.GetKeyLink()
		local clip = setclipboard or toclipboard
		if clip then
			clip(link)
			return true
		end
		return false
	end

	return {
		Verify = verifyKey,
		Copy = copyLink,
	}
end

return JunkieDevelopment
