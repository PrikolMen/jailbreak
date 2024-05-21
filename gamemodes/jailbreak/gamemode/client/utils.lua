local Jailbreak = Jailbreak
local Simple = timer.Simple
local ENTITY = ENTITY
local PLAYER = PLAYER
local max = math.max
local Run = hook.Run
local GetNW2Var = ENTITY.GetNW2Var
do
	local String = cvars.String
	cvars.AddChangeCallback("gmod_language", function(_, __, value)
		return timer.Create("Jailbreak::LanguageChanged", 0.025, 1, function()
			return Run("LanguageChanged", String("gmod_language", "en"), value)
		end)
	end, "Jailbreak::LanguageChanged")
end
do
	local RunConsoleCommand = RunConsoleCommand
	Jailbreak.ChangeTeam = function(teamID)
		return RunConsoleCommand("changeteam", teamID)
	end
end
do
	local sub, gsub
	do
		local _obj_0 = string
		sub, gsub = _obj_0.sub, _obj_0.gsub
	end
	local GetPhrase = language.GetPhrase
	local filter
	filter = function(placeholder)
		local fulltext = GetPhrase(placeholder)
		if fulltext == placeholder and sub(placeholder, 1, 3) == "jb." then
			return GetPhrase(sub(placeholder, 4))
		end
		return fulltext
	end
	Jailbreak.GetPhrase = filter
	Jailbreak.Translate = function(str)
		return gsub(str, "#([%w%.-_]+)", filter)
	end
end
do
	local ScrW, ScrH = ScrW, ScrH
	local min, ceil
	do
		local _obj_0 = math
		min, ceil = _obj_0.min, _obj_0.ceil
	end
	local width, height = ScrW(), ScrH()
	local vmin, vmax = min(width, height) / 100, max(width, height) / 100
	Jailbreak.ScreenWidth, Jailbreak.ScreenHeight = width, height
	Jailbreak.ScreenCenterX, Jailbreak.ScreenCenterY = width / 2, height / 2
	hook.Add("OnScreenSizeChanged", "Jailbreak::OnScreenSizeChanged", function()
		width, height = ScrW(), ScrH()
		vmin, vmax = min(width, height) / 100, max(width, height) / 100
		Jailbreak.ScreenWidth, Jailbreak.ScreenHeight = width, height
		Jailbreak.ScreenCenterX, Jailbreak.ScreenCenterY = width / 2, height / 2
		return Run("ScreenResolutionChanged", width, height)
	end)
	Jailbreak.VMin = function(number)
		if number ~= nil then
			return ceil(vmin * number)
		end
		return vmin
	end
	Jailbreak.VMax = function(number)
		if number ~= nil then
			return ceil(vmax * number)
		end
		return vmax
	end
end
do
	local fonts = Jailbreak.Fonts
	if not istable(fonts) then
		fonts = { }
		Jailbreak.Fonts = fonts
	end
	local CreateFont = surface.CreateFont
	local VMin = Jailbreak.VMin
	local remove = table.remove
	local fontData = {
		extended = true,
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false
	}
	Jailbreak.Font = function(fontName, font, size)
		fontData.font, fontData.size = font, VMin(size)
		for index = 1, #fonts do
			if fonts[index].fontName == fontName then
				remove(fonts, index)
				break
			end
		end
		fonts[#fonts + 1] = {
			fontName = fontName,
			font = font,
			size = size
		}
		return CreateFont(fontName, fontData)
	end
	hook.Add("ScreenResolutionChanged", "Jailbreak::Fonts", function()
		for _index_0 = 1, #fonts do
			local data = fonts[_index_0]
			fontData.font, fontData.size = data.font, VMin(data.size)
			CreateFont(data.fontName, fontData)
		end
	end)
end
do
	local voiceVolume = 0
	GM.PerformPlayerVoice = function(self, ply)
		if ply:IsSpeaking() then
			voiceVolume = ply:VoiceVolume()
		else
			voiceVolume = 0
		end
		local lastVoiceVolume = ply.m_fLastVoiceVolume
		if not lastVoiceVolume then
			lastVoiceVolume = voiceVolume
		end
		if lastVoiceVolume > 0 then
			voiceVolume = lastVoiceVolume + (voiceVolume - lastVoiceVolume) / 4
			if voiceVolume < 0.01 then
				voiceVolume = 0
			end
		end
		ply.m_fLastVoiceVolume = voiceVolume
		local maxVoiceVolume = ply.m_fMaxVoiceVolume
		if not maxVoiceVolume or maxVoiceVolume < voiceVolume then
			maxVoiceVolume = voiceVolume
			ply.m_fMaxVoiceVolume = maxVoiceVolume
		end
		if maxVoiceVolume > 0 and voiceVolume > 0 then
			ply.m_fVoiceFraction = voiceVolume / maxVoiceVolume
			return
		end
		ply.m_fVoiceFraction = 0
	end
end
do
	gameevent.Listen("player_spawn")
	local Player = Player
	hook.Add("player_spawn", "Jailbreak::SpawnEffect", function(data)
		local ply = Player(data.userid)
		if not (ply and ply:IsValid()) then
			return
		end
		local pl = Jailbreak.Player
		if pl:IsValid() then
			ply.m_fSpawnTime = CurTime() + pl:Ping() / 1000
		else
			ply.m_fSpawnTime = CurTime() + 0.25
		end
		return Run("PlayerSpawn", ply)
	end)
end
PLAYER.GetSpawnTime = function(self)
	return self.m_fSpawnTime or GetNW2Var(self, "spawn-time", 0)
end
PLAYER.GetAliveTime = function(self)
	return CurTime() - (self.m_fSpawnTime or GetNW2Var(self, "spawn-time", 0))
end
PLAYER.VoiceFraction = function(self)
	return self.m_fVoiceFraction or 0
end
do
	local isfunction = isfunction
	PLAYER.AnimRestartNetworkedGesture = function(self, slot, activity, autokill, finished)
		local sequenceID = self:SelectWeightedSequence(activity)
		if sequenceID < 0 then
			return
		end
		if isfunction(finished) then
			Simple(self:SequenceDuration(sequenceID), function()
				if self:IsValid() then
					return finished(self)
				end
			end)
		end
		return self:AnimRestartGesture(slot, activity, autokill)
	end
end
do
	local EntIndex = ENTITY.EntIndex
	ENTITY.IsDoorLocked = function(self)
		return GetNW2Var(self, "m_bLocked", false)
	end
	ENTITY.GetDoorState = function(self)
		return GetNW2Var(self, "m_eDoorState", 0)
	end
	ENTITY.IsLocalPlayer = function(self)
		local index = Jailbreak.PlayerIndex
		if not index then
			return true
		end
		return EntIndex(self) == index
	end
end
do
	local shopItems = Jailbreak.ShopItems
	if not shopItems then
		shopItems = { }
		Jailbreak.ShopItems = shopItems
	end
	local ReadString, ReadUInt, ReadBool
	do
		local _obj_0 = net
		ReadString, ReadUInt, ReadBool = _obj_0.ReadString, _obj_0.ReadUInt, _obj_0.ReadBool
	end
	local Empty = table.Empty
	net.Receive("Jailbreak::Shop", function()
		table.Empty(shopItems)
		for index = 1, ReadUInt(16) do
			local name = ReadString()
			shopItems[index] = {
				name = name,
				title = "#jb." .. name,
				model = ReadString(),
				price = ReadUInt(16),
				skin = ReadUInt(8),
				bodygroups = ReadString()
			}
		end
		return Run("ShopItems", shopItems)
	end)
end
do
	local GetPlayerColor = ENTITY.GetPlayerColor
	local SetVector = IMATERIAL.SetVector
	matproxy.Add({
		name = "PlayerColor",
		init = function(self, _, values)
			self.ResultTo = values.resultvar
		end,
		bind = function(self, material, entity)
			return SetVector(material, self.ResultTo, GetPlayerColor(entity))
		end
	})
end
do
	local Material = Material
	local materials = { }
	Jailbreak.Material = function(materialPath, parameters)
		if materials[materialPath] == nil then
			materials[materialPath] = Material(materialPath, parameters)
		end
		return materials[materialPath]
	end
end
