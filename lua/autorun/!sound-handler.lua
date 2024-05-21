local sub, match, Split = string.sub, string.match, string.Split
local KeyValuesToTable = util.KeyValuesToTable
local AsyncRead, Find = file.AsyncRead, file.Find
local FSASYNC_OK = FSASYNC_OK
local Add = sound.Add
local IsMounted = IsMounted
local isstring = isstring
local isnumber = isnumber
local tonumber = tonumber
local pairs = pairs
local mapName = game.GetMap()
local mapNameShort = match(mapName, "^%w+_(%w+)_?")
local channels = {
	CHAN_REPLACE = -1,
	CHAN_AUTO = 0,
	CHAN_WEAPON = 1,
	CHAN_VOICE = 2,
	CHAN_ITEM = 3,
	CHAN_BODY = 4,
	CHAN_STREAM = 5,
	CHAN_STATIC = 6,
	CHAN_VOICE2 = 7,
	CHAN_VOICE_BASE = 8,
	CHAN_USER_BASE = 136
}
local pitchs = {
	PITCH_NORM = 100,
	PITCH_LOW = 95,
	PITCH_HIGH = 120
}
local soundLevels = {
	SNDLVL_NONE = 0,
	SNDLVL_25dB = 25,
	SNDLVL_30dB = 30,
	SNDLVL_35dB = 35,
	SNDLVL_40dB = 40,
	SNDLVL_45dB = 45,
	SNDLVL_50dB = 50,
	SNDLVL_55dB = 55,
	SNDLVL_IDLE = 60,
	SNDLVL_TALKING = 60,
	SNDLVL_60dB = 60,
	SNDLVL_65dB = 65,
	SNDLVL_STATIC = 66,
	SNDLVL_70dB = 70,
	SNDLVL_NORM = 75,
	SNDLVL_75dB = 75,
	SNDLVL_80dB = 80,
	SNDLVL_85dB = 85,
	SNDLVL_90dB = 90,
	SNDLVL_95dB = 95,
	SNDLVL_100dB = 100,
	SNDLVL_105dB = 105,
	SNDLVL_120dB = 120,
	SNDLVL_130dB = 130,
	SNDLVL_GUNFIRE = 140,
	SNDLVL_140dB = 140,
	SNDLVL_150dB = 150
}
local _class_0
local _base_0 = {
	MapName = mapName,
	MapNameShort = mapNameShort,
	SoundLevels = soundLevels,
	Channels = channels,
	Pitchs = pitchs,
	Perform = function(self, content)
		local sounds = KeyValuesToTable(content)
		if not sounds then
			return
		end
		for name, data in pairs(sounds) do
			local soundData = {
				name = name,
				channel = channels[data.channel or "CHAN_AUTO"] or 0,
				volume = tonumber(data.volume or 1) or 1,
				level = soundLevels[data.soundlevel or "SNDLVL_NORM"] or 75,
				sound = data.wave,
				pitch = 100
			}
			local rndwave = data.rndwave
			if rndwave then
				local tbl, len = { }, 0
				for _, value in pairs(rndwave) do
					len = len + 1
					tbl[len] = value
				end
				soundData.sound = tbl
			end
			local pitch = data.pitch
			if pitch then
				if isstring(pitch) then
					local common = pitchs[pitch]
					if common then
						soundData.pitch = common
					else
						pitch = Split(pitch, ",")
						soundData.pitch = pitch
						for index = 1, #pitch do
							pitch[index] = tonumber(pitch[index])
						end
					end
				elseif isnumber(pitch) then
					soundData.pitch = pitch
				end
			end
			Add(soundData)
		end
	end
}
if _base_0.__index == nil then
	_base_0.__index = _base_0
end
_class_0 = setmetatable({
	__init = function(self, gameName)
		if not IsMounted(gameName) then
			return
		end
		local _list_0 = Find("scripts/soundscapes_*.txt", gameName)
		for _index_0 = 1, #_list_0 do
			local fileName = _list_0[_index_0]
			local mapNameIdent = sub(fileName, 13)
			mapNameIdent = sub(mapNameIdent, 1, #mapNameIdent - 4)
			if mapNameIdent == mapName or mapNameIdent == mapNameShort then
				AsyncRead("scripts/" .. fileName, gameName, function(_, __, status, content)
					if status == FSASYNC_OK then
						self:Perform("File\n{" .. content .. "}")
						return
					end
				end)
			end
		end
		local _list_1 = Find("scripts/game_sounds*.txt", gameName)
		for _index_0 = 1, #_list_1 do
			local fileName = _list_1[_index_0]
			AsyncRead("scripts/" .. fileName, gameName, function(_, __, status, content)
				if status == FSASYNC_OK then
					self:Perform("File\n{" .. content .. "}")
					return
				end
			end)
		end
	end,
	__base = _base_0,
	__name = "SoundHandler"
}, {
	__index = _base_0,
	__call = function(cls, ...)
		local _self_0 = setmetatable({ }, _base_0)
		cls.__init(_self_0, ...)
		return _self_0
	end
})
_base_0.__class = _class_0
SoundHandler = _class_0
