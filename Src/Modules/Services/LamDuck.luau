-- LamDuck API | https://lamduck.vercel.app

local Clone = (cloneref or clonereference or function(instance)
	return instance
end)
local HttpService = Clone(game:GetService("HttpService"))
local Hwid = require(script.Parent.Parent.Hwid)

local fRequest = request or http_request or (syn and syn.request)
local fSetClipboard = setclipboard or toclipboard
local fHmac = (crypt and crypt.custom_hmac)
	or (syn and syn.crypt and syn.crypt.custom_hmac)
	or (fluxus and fluxus.crypt and fluxus.crypt.custom_hmac)

local MISSING_SECRET = "LamDuck Error: Missing VerifySecret in KeySystem configuration."
local SIGNATURE_FAILED = "Signature verification failed (invalid VerifySecret or tampered response)."

local SHA256_K = {
	0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
	0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
	0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
	0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
	0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
	0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
	0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
	0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
}

local function sha256Digest(message: string): string
	local H = { 0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19 }
	local length = #message
	local bitLength = length * 8
	local padded = message .. "\128" .. string.rep("\0", (56 - (length + 1) % 64) % 64) .. string.char(
		0, 0, 0, 0,
		math.floor(bitLength / 0x1000000) % 256,
		math.floor(bitLength / 0x10000) % 256,
		math.floor(bitLength / 0x100) % 256,
		bitLength % 256
	)

	for offset = 1, #padded, 64 do
		local W = {}
		for t = 0, 15 do
			local i = offset + t * 4
			W[t] = string.byte(padded, i) * 0x1000000
				+ string.byte(padded, i + 1) * 0x10000
				+ string.byte(padded, i + 2) * 0x100
				+ string.byte(padded, i + 3)
		end
		for t = 16, 63 do
			local w15, w2 = W[t - 15], W[t - 2]
			local s0 = bit32.bxor(bit32.rrotate(w15, 7), bit32.rrotate(w15, 18), bit32.rshift(w15, 3))
			local s1 = bit32.bxor(bit32.rrotate(w2, 17), bit32.rrotate(w2, 19), bit32.rshift(w2, 10))
			W[t] = (W[t - 16] + s0 + W[t - 7] + s1) % 0x100000000
		end

		local a, b, c, d, e, f, g, h = H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8]
		for t = 0, 63 do
			local S1 = bit32.bxor(bit32.rrotate(e, 6), bit32.rrotate(e, 11), bit32.rrotate(e, 25))
			local ch = bit32.bxor(bit32.band(e, f), bit32.band(bit32.bnot(e), g))
			local S0 = bit32.bxor(bit32.rrotate(a, 2), bit32.rrotate(a, 13), bit32.rrotate(a, 22))
			local maj = bit32.bxor(bit32.band(a, b), bit32.band(a, c), bit32.band(b, c))
			local temp1 = (h + S1 + ch + SHA256_K[t + 1] + W[t]) % 0x100000000
			local temp2 = (S0 + maj) % 0x100000000
			h, g, f, e = g, f, e, (d + temp1) % 0x100000000
			d, c, b, a = c, b, a, (temp1 + temp2) % 0x100000000
		end

		H[1] = (H[1] + a) % 0x100000000
		H[2] = (H[2] + b) % 0x100000000
		H[3] = (H[3] + c) % 0x100000000
		H[4] = (H[4] + d) % 0x100000000
		H[5] = (H[5] + e) % 0x100000000
		H[6] = (H[6] + f) % 0x100000000
		H[7] = (H[7] + g) % 0x100000000
		H[8] = (H[8] + h) % 0x100000000
	end

	local out = {}
	for i = 1, 8 do
		local value = H[i]
		out[i] = string.char(
			math.floor(value / 0x1000000) % 256,
			math.floor(value / 0x10000) % 256,
			math.floor(value / 0x100) % 256,
			value % 256
		)
	end
	return table.concat(out)
end

local function toHex(digest: string): string
	return (digest:gsub(".", function(char)
		return string.format("%02x", string.byte(char))
	end))
end

local function hmacSha256Raw(message: string, key: string): string
	if #key > 64 then
		key = sha256Digest(key)
	end
	local inner, outer = {}, {}
	for i = 1, 64 do
		local byte = string.byte(key, i) or 0
		inner[i] = string.char(bit32.bxor(byte, 0x36))
		outer[i] = string.char(bit32.bxor(byte, 0x5c))
	end
	return sha256Digest(table.concat(outer) .. sha256Digest(table.concat(inner) .. message))
end

local function computeHmac(message: string, key: string): string
	if fHmac then
		local ok, result = pcall(fHmac, "sha256", message, key)
		if ok and type(result) == "string" and result ~= "" then
			return result
		end
	end
	return toHex(hmacSha256Raw(message, key))
end

local function reasonMessage(reason: any): string
	local text = tostring(reason or "")
	local known = {
		BANNED = "Your HWID or IP has been blacklisted.",
		MAINTENANCE = "LamDuck verification is under maintenance, please try again later.",
		HWID_MISMATCH = "This key is bound to another device. Reset your HWID on the LamDuck website.",
		INVALID_OR_EXPIRED = "Key is invalid or expired, please get a new one.",
	}
	return known[text] or ("Key validation failed" .. (text ~= "" and (": " .. text) or "."))
end

local LamDuck = {}

function LamDuck.New(baseUrl: string?, verifySecret: string?)
	local host = if baseUrl and tostring(baseUrl) ~= "" then tostring(baseUrl) else "https://lamduck.vercel.app"
	host = host:gsub("/+$", "")
	local secret = (tostring(verifySecret or ""):gsub("^%s*(.-)%s*$", "%1"))
	local hwid = Hwid.Get()

	local function copyLink(): (boolean, string)
		if secret == "" then
			return false, MISSING_SECRET
		end
		local url = host .. "/getkey?hwid=" .. HttpService:UrlEncode(hwid)
		if fSetClipboard then
			fSetClipboard(url)
		end
		return true, url
	end

	local function verifyKey(key: string?): (boolean, string)
		if secret == "" then
			return false, MISSING_SECRET
		end
		local normalizedKey = if typeof(key) == "string" then key else ""

		local success, response = pcall(function()
			if fRequest then
				return fRequest({
					Url = host .. "/api/verify",
					Method = "POST",
					Headers = { ["Content-Type"] = "application/json" },
					Body = HttpService:JSONEncode({
						hwid = hwid,
						key = (#normalizedKey > 0) and normalizedKey or nil,
					}),
				})
			end

			local url = host .. "/api/verify?hwid=" .. HttpService:UrlEncode(hwid)
			if #normalizedKey > 0 then
				url ..= "&key=" .. HttpService:UrlEncode(normalizedKey)
			end
			return game:HttpGet(url)
		end)

		if not success or response == nil then
			return false, "LamDuck request failed."
		end

		local body = if type(response) == "table" then response.Body else response
		if type(body) ~= "string" or body == "" then
			return false, "LamDuck server returned an empty response."
		end

		local decodeOk, data = pcall(function()
			return HttpService:JSONDecode(body)
		end)
		if not decodeOk or type(data) ~= "table" then
			return false, "Failed to parse LamDuck response."
		end

		if data.valid ~= true then
			return false, reasonMessage(data.reason)
		end

		if type(data.signature) ~= "string" or data.signature == "" then
			return false, SIGNATURE_FAILED
		end

		local timestamp = tonumber(data.timestamp)
		if not timestamp or math.abs(os.time() - timestamp) > 120 then
			return false, "Verification timed out, please try again."
		end

		local payload = string.format(
			"%s:%s:%s:%s:%s",
			hwid,
			normalizedKey,
			tostring(data.valid),
			tostring(data.mode or data.reason or ""),
			tostring(data.timestamp)
		)
		if string.lower(computeHmac(payload, secret)) ~= string.lower(data.signature) then
			return false, SIGNATURE_FAILED
		end

		return true, "Access granted (" .. tostring(data.mode or "KEY") .. ")"
	end

	return {
		Verify = verifyKey,
		Copy = copyLink,
	}
end

return LamDuck
