local RunConsoleCommand = RunConsoleCommand
local format = string.format
local Jailbreak = Jailbreak
local Run = hook.Run
local MsgC = MsgC
local GM = GM
Jailbreak.VoiceChatState = Jailbreak.VoiceChatState or false
Jailbreak.PlayingTaunt = Jailbreak.PlayingTaunt or false
Jailbreak.TauntFraction = Jailbreak.TauntFraction or 0
Jailbreak.ViewEntity = Jailbreak.ViewEntity or NULL
Jailbreak.Player = Jailbreak.Player or NULL
hook.Add("RenderScene", "Jailbreak::PlayerInitialized", function()
	hook.Remove("RenderScene", "Jailbreak::PlayerInitialized")
	if not Jailbreak.Player:IsValid() then
		local ply = LocalPlayer()
		Jailbreak.Player = ply
		Jailbreak.PlayerIndex = ply:EntIndex()
		Run("PlayerInitialized", ply)
		return true
	end
end)
GM.PlayerInitialized = function(self)
	RunConsoleCommand("dsp_player", "1")
	return RunConsoleCommand("dsp_room", "1")
end
GM.InitPostEntity = function(self)
	RunConsoleCommand("r_flushlod")
	local mapName = game.GetMap()
	Jailbreak.MapName = mapName
	Run("MapInitialized", mapName)
	return
end
GM.PostCleanupMap = function(self)
	RunConsoleCommand("r_cleardecals")
	Run("MapInitialized", Jailbreak.MapName)
	return
end
GM.OnSpawnMenuOpen = function(self)
	RunConsoleCommand("lastinv")
	return
end
GM.PostProcessPermitted = function(self)
	return false
end
do
	Jailbreak.DrawHUD = GetConVar("cl_drawhud"):GetBool()
	cvars.AddChangeCallback("cl_drawhud", function(_, __, value)
		Jailbreak.DrawHUD = value ~= "0"
		local panel = Jailbreak.HUD
		if panel and panel:IsValid() then
			return panel:SetVisible(Jailbreak.DrawHUD)
		end
	end, "Jailbreak::DrawHUD")
end
do
	local PlayerModel = Jailbreak.PlayerModel
	do
		local requestedName = PlayerModel:GetString()
		local modelName = Jailbreak.FormatPlayerModelName(requestedName)
		Jailbreak.SelectedPlayerModel = modelName
		if modelName ~= requestedName then
			PlayerModel:SetString(modelName)
			Run("PlayerModelChanged", modelName)
		end
	end
	cvars.AddChangeCallback(PlayerModel:GetName(), function(_, __, requestedName)
		Jailbreak.PlayerBodyGroups:SetInt(0)
		Jailbreak.PlayerSkin:SetInt(0)
		local modelName = Jailbreak.FormatPlayerModelName(requestedName)
		Jailbreak.SelectedPlayerModel = modelName
		if modelName ~= requestedName then
			PlayerModel:SetString(modelName)
		end
		Run("PlayerModelChanged", modelName)
		return
	end, "Jailbreak::PlayerModel")
end
do
	local LookupKeyBinding, IsKeyDown = input.LookupKeyBinding, input.IsKeyDown
	local IsFirstTimePredicted = IsFirstTimePredicted
	GM.PlayerButtonUp = function(self, ply, keyCode)
		if not IsFirstTimePredicted() then
			return
		end
		local bind = LookupKeyBinding(keyCode)
		if keyCode == 17 and (not bind or bind == "drop" or #bind == 0) then
			return RunConsoleCommand("drop")
		elseif keyCode == 109 and (not bind or bind == "marker" or #bind == 0) then
			return RunConsoleCommand("marker")
		elseif (keyCode == 58 or keyCode == 23) and (not bind or bind == "jb_showteam" or #bind == 0) then
			return RunConsoleCommand("jb_showteam")
		elseif keyCode == 18 and (not bind or #bind == 0) then
			return RunConsoleCommand("pe_drop", "movement")
		end
	end
	GM.PlayerButtonDown = function(self, ply, keyCode)
		if (keyCode == 107 or keyCode == 108) and IsKeyDown(81) and IsFirstTimePredicted() then
			return RunConsoleCommand("marker")
		end
	end
end
do
	local ReadString, ReadUInt, ReadTable, ReadEntity, ReadBool = net.ReadString, net.ReadUInt, net.ReadTable, net.ReadEntity, net.ReadBool
	local AddLegacy = notification.AddLegacy
	local Translate = Jailbreak.Translate
	local CHAN_STATIC = CHAN_STATIC
	local random = math.random
	local Colors = Jailbreak.Colors
	local unpack = unpack
	local notifyColors = {
		[NOTIFY_GENERIC] = Colors.vivid_orange,
		[NOTIFY_CLEANUP] = Colors.horizon,
		[NOTIFY_ERROR] = Colors.red,
		[NOTIFY_UNDO] = Colors.blue,
		[NOTIFY_HINT] = Colors.guards
	}
	net.Receive("Jailbreak::Networking", function()
		local _exp_0 = ReadUInt(4)
		if 0 == _exp_0 then
			local gameName = ReadString()
			SoundHandler(gameName)
			Jailbreak.GameName = gameName
		elseif 1 == _exp_0 then
			return Run("PickupNotifyReceived", ReadString(), ReadUInt(6), ReadUInt(16))
		elseif 2 == _exp_0 then
			local text, notifyType = format(Translate(ReadString()), unpack(ReadTable(true))), ReadUInt(3)
			AddLegacy(text, notifyType, ReadUInt(16))
			return MsgC(notifyColors[notifyType], "Notify: ", text, "\n")
		elseif 3 == _exp_0 then
			local ply = Jailbreak.Player
			if ply:IsValid() then
				return ply:EmitSound(ReadString(), 75, random(90, 110), 1, CHAN_STATIC, 0, 1)
			end
		elseif 4 == _exp_0 then
			local entity = ReadEntity()
			if entity and (function()
				local _base_0 = entity
				local _fn_0 = _base_0.IsValid
				return _fn_0 and function(...)
					return _fn_0(_base_0, ...)
				end
			end)() and entity:IsPlayer() then
				return entity:AnimRestartGesture(ReadUInt(3), ReadUInt(11), ReadBool())
			end
		elseif 5 == _exp_0 then
			RunConsoleCommand("jb_megaphone", GetConVar("jb_megaphone"):GetDefault())
			return RunConsoleCommand("jb_security_radio", GetConVar("jb_security_radio"):GetDefault())
		end
	end)
end
return concommand.Add("jb_credits", function()
	return MsgC(unpack(Jailbreak.Credits))
end)
