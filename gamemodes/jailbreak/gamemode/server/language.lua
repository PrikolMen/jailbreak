local char, sub, gsub, gmatch, find
do
	local _obj_0 = string
	char, sub, gsub, gmatch, find = _obj_0.char, _obj_0.sub, _obj_0.gsub, _obj_0.gmatch, _obj_0.find
end
local Jailbreak = Jailbreak
local IsValid = IsValid
language = language or { }
local getPhrase
getPhrase = function(languageCode, placeholder)
	local phrases = language[languageCode]
	if not phrases then
		return placeholder
	end
	return phrases[placeholder] or placeholder
end
language.GetPhrase = getPhrase
local add
add = function(languageCode, placeholder, fulltext)
	local phrases = language[languageCode]
	if not phrases then
		phrases = { }
		language[languageCode] = phrases
	end
	phrases[placeholder] = fulltext
end
language.Add = add
do
	local parseUnicode = nil
	do
		local bor, band, rshift
		do
			local _obj_0 = bit
			bor, band, rshift = _obj_0.bor, _obj_0.band, _obj_0.rshift
		end
		local tonumber = tonumber
		parseUnicode = function(str)
			return gsub(str, "\\u([0-9a-f][0-9a-f][0-9a-f][0-9a-f])", function(value)
				local byte = tonumber(value, 16)
				if byte < 0x80 then
					return char(byte)
				elseif byte < 0x800 then
					local b1 = bor(0xC0, band(rshift(byte, 6), 0x1F))
					local b2 = bor(0x80, band(byte, 0x3F))
					return char(b1, b2)
				elseif byte < 0x10000 then
					local b1 = bor(0xE0, band(rshift(byte, 12), 0x0F))
					local b2 = bor(0x80, band(rshift(byte, 6), 0x3F))
					local b3 = bor(0x80, band(byte, 0x3F))
					return char(b1, b2, b3)
				else
					local b1 = bor(0xF0, band(rshift(byte, 18), 0x07))
					local b2 = bor(0x80, band(rshift(byte, 12), 0x3F))
					local b3 = bor(0x80, band(rshift(byte, 6), 0x3F))
					local b4 = bor(0x80, band(byte, 0x3F))
					return char(b1, b2, b3, b4)
				end
			end)
		end
	end
	string.ParseUnicode = parseUnicode
	local parseEscapedChars = nil
	do
		local escapedChars = {
			["\\n"] = "\n",
			["\\t"] = "\t",
			["\\0"] = "\0"
		}
		parseEscapedChars = function(str)
			return gsub(str, "\\.", function(value)
				return escapedChars[value] or value[2]
			end)
		end
	end
	string.ParseEscapedChars = parseEscapedChars
	local loadLocalization = nil
	do
		local AsyncRead, Find
		do
			local _obj_0 = file
			AsyncRead, Find = _obj_0.AsyncRead, _obj_0.Find
		end
		local select = select
		local print = print
		loadLocalization = function(folderPath)
			local _list_0 = select(2, Find(folderPath .. "/*", "GAME"))
			for _index_0 = 1, #_list_0 do
				local languageCode = _list_0[_index_0]
				if Jailbreak.Developer then
					print("[Jailbreak] Loading '" .. languageCode .. "' localization...")
				end
				local _list_1 = Find(folderPath .. "/" .. languageCode .. "/*.properties", "GAME")
				for _index_1 = 1, #_list_1 do
					local fileName = _list_1[_index_1]
					AsyncRead(folderPath .. "/" .. languageCode .. "/" .. fileName, "GAME", function(_, __, status, data)
						if status ~= 0 or not data or #data < 3 then
							return
						end
						for line in gmatch(data, "(.-)\n") do
							if #line >= 3 then
								local separatorPos = find(line, "=")
								if not separatorPos then
									goto _continue_0
								end
								add(languageCode, sub(line, 1, separatorPos - 1), parseEscapedChars(parseUnicode(sub(line, separatorPos + 1))))
							end
							::_continue_0::
						end
					end)
				end
			end
		end
		Jailbreak.LoadLocalization = loadLocalization
	end
	Jailbreak.ReloadLocalization = function()
		loadLocalization("resource/localization")
		return loadLocalization("gamemodes/jailbreak/content/resource/localization")
	end
end
Jailbreak.GetPhrase = function(self, placeholder)
	local languageCode = self:GetInfo("gmod_language")
	if not languageCode or #languageCode == 0 then
		return placeholder
	end
	local fulltext = getPhrase(languageCode, placeholder)
	if fulltext == placeholder and sub(placeholder, 1, 3) == "jb." then
		return sub(placeholder, 4)
	end
	return fulltext
end
Jailbreak.Translate = function(self, str)
	if not (IsValid(self) and self:IsPlayer()) then
		return str
	end
	return gsub(str, "#([%w%.-_]+)", function(placeholder)
		local fulltext = getPhrase(languageCode, placeholder)
		if fulltext == placeholder and sub(placeholder, 1, 3) == "jb." then
			return sub(placeholder, 4)
		end
		return fulltext
	end)
end
