local Jailbreak = Jailbreak
local string = string
local math = math
local net = net
local GM = GM
local VoiceChatMinDistance, VoiceChatMaxDistance, GameInProgress = Jailbreak.VoiceChatMinDistance, Jailbreak.VoiceChatMaxDistance, Jailbreak.GameInProgress
local white, red, dark_white
do
	local _obj_0 = Jailbreak.Colors
	white, red, dark_white = _obj_0.white, _obj_0.red, _obj_0.dark_white
end
local CHAT_SERVERMESSAGE = CHAT_SERVERMESSAGE
local CHAT_OOC = CHAT_OOC
local GetHumans = player.GetHumans
local tonumber = tonumber
local isstring = isstring
local lower = string.lower
local random = math.random
local Add = hook.Add
local sendChatText = nil
do
	util.AddNetworkString("Jailbreak::Chat")
	local Start, WriteUInt, WriteBool, WriteTable, Send, Broadcast = net.Start, net.WriteUInt, net.WriteBool, net.WriteTable, net.Send, net.Broadcast
	local isnumber = isnumber
	local IsEntity = IsEntity
	local TypeID = TypeID
	local Run = hook.Run
	local TYPE_ENTITY = TYPE_ENTITY
	local TYPE_RECIPIENTFILTER = TYPE_RECIPIENTFILTER
	local TYPE_TABLE = TYPE_TABLE
	local fallbackStr = "unsupported"
	sendChatText = function(target, speaker, messageType, text, nickname, isDead, isTeamChat, ...)
		Start("Jailbreak::Chat")
		local hasSpeaker = speaker and speaker:IsValid()
		WriteBool(hasSpeaker)
		if hasSpeaker then
			WriteUInt(speaker:EntIndex(), 8)
		end
		WriteUInt(messageType, 5)
		WriteTable({
			text,
			nickname,
			isDead,
			isTeamChat,
			...
		}, true)
		if not hasSpeaker then
			if target then
				Send(target)
			else
				Broadcast()
			end
			return
		end
		if not target then
			if messageType == CHAT_OOC then
				Broadcast()
				return
			end
			target = GetHumans()
		end
		if not isstring(text) then
			text = fallbackStr
		end
		isTeamChat = isnumber(isTeamChat)
		local _exp_0 = TypeID(target)
		if TYPE_ENTITY == _exp_0 then
			if Run("PlayerCanSeePlayersChat", text, isTeamChat, target, speaker) ~= false then
				return Send(target)
			end
		elseif TYPE_RECIPIENTFILTER == _exp_0 then
			local players = { }
			local _list_0 = target:GetPlayers()
			for _index_0 = 1, #_list_0 do
				local listener = _list_0[_index_0]
				if Run("PlayerCanSeePlayersChat", text, isTeamChat, listener, speaker) ~= false then
					players[#players + 1] = listener
				end
			end
			return Send(players)
		elseif TYPE_TABLE == _exp_0 then
			local players = { }
			for _index_0 = 1, #target do
				local listener = target[_index_0]
				if not (IsEntity(listener) and listener:IsValid() and listener:IsPlayer()) then
					goto _continue_0
				end
				if Run("PlayerCanSeePlayersChat", text, isTeamChat, listener, speaker) ~= false then
					players[#players + 1] = listener
				end
				::_continue_0::
			end
			return Send(players)
		end
	end
	PLAYER.ChatPrint = function(self, text)
		if not (isstring(text) and #text > 0) then
			text = fallbackStr
		end
		return sendChatText(self, false, CHAT_SERVERMESSAGE, text, white)
	end
end
Jailbreak.SendChatText = sendChatText
local chatCommands = Jailbreak.ChatCommands
if not istable(chatCommands) then
	chatCommands = { }
	Jailbreak.ChatCommands = chatCommands
end
local setChatCommand = nil
do
	local isfunction = isfunction
	setChatCommand = function(str, func, description)
		if not (isstring(str) and isfunction(func)) then
			return
		end
		if not isstring(description) then
			description = "#jb.chat.command.no-description"
		end
		chatCommands[lower(str)] = {
			func,
			description
		}
	end
	Jailbreak.SetChatCommand = setChatCommand
end
setChatCommand("help", function(self)
	local text, counter = "#jb.chat.command.available\n", 1
	for str, data in pairs(chatCommands) do
		text = text .. (counter .. ". /" .. str .. " - " .. data[2] .. "\n")
		counter = counter + 1
	end
	return sendChatText(self, false, CHAT_SERVERMESSAGE, text)
end, "#jb.chat.command.help")
do
	local CHAT_LOOC = CHAT_LOOC
	local looc
	looc = function(self, text, isTeamChat)
		return sendChatText(self:GetNearPlayers(VoiceChatMinDistance:GetInt(), false), self, CHAT_LOOC, text, self:Nick(), self:Alive(), isTeamChat and self:Team() or false)
	end
	Jailbreak.LOOC = looc
	setChatCommand("looc", looc, "#jb.chat.command.looc")
	setChatCommand("", looc, "#jb.chat.command.looc")
end
do
	local EmotionDistance = Jailbreak.EmotionDistance
	local CHAT_EMOTION = CHAT_EMOTION
	local customEmotion
	customEmotion = function(self, ...)
		return sendChatText(self:GetNearPlayers(EmotionDistance:GetInt(), false), self, CHAT_EMOTION, self:Nick(), self:Alive(), ...)
	end
	Jailbreak.Emotion = customEmotion
	local emotion
	emotion = function(self, text)
		if #text == 0 then
			return sendChatText(self, false, CHAT_SERVERMESSAGE, "#jb.chat.command.invalid", red)
		else
			return customEmotion(self, lower(text))
		end
	end
	setChatCommand("e", emotion, "#jb.chat.command.emotion")
	setChatCommand("me", emotion, "#jb.chat.command.emotion")
	setChatCommand("emotion", emotion, "#jb.chat.command.emotion")
	do
		local coinFlip
		coinFlip = function(self, _, text)
			return emotion(self, "#jb.chat.coin-flip #jb.chat.coin-flip." .. random(0, 1))
		end
		setChatCommand("coin", coinFlip, "#jb.chat.command.coin")
		setChatCommand("flip", coinFlip, "#jb.chat.command.coin")
	end
	do
		local match = string.match
		setChatCommand("roll", function(self, text)
			local int1, int2 = match(text, "(-?%d+)%s+(-?%d+)")
			if not int1 then
				int1 = 0
			end
			if not int2 then
				int2 = 100
			end
			return emotion(self, "#jb.chat.rolled " .. random(tonumber(int1) or 0, tonumber(int2) or 0))
		end, "#jb.chat.command.roll")
	end
end
local ooc
ooc = function(self, text, isTeamChat)
	return sendChatText(false, self, CHAT_OOC, text, self:Nick(), self:Alive(), isTeamChat and self:Team() or false)
end
Jailbreak.OOC = ooc
do
	local OutOfCharacter = Jailbreak.OutOfCharacter
	local NOTIFY_ERROR = NOTIFY_ERROR
	local func
	func = function(self, text)
		if GameInProgress() and not (OutOfCharacter:GetBool() or self:IsAdmin()) then
			self:SendNotify("#jb.chat.fail", NOTIFY_ERROR, 5)
			return
		end
		ooc(self, text)
		return
	end
	setChatCommand("ooc", func, "#jb.chat.command.ooc")
	setChatCommand("/", func, "#jb.chat.command.ooc")
end
local whisper = nil
do
	local MaxWhisperDistance = Jailbreak.MaxWhisperDistance
	local CHAT_WHISPER = CHAT_WHISPER
	whisper = function(self, text, isTeamChat, noSpeaker)
		return sendChatText(self:GetNearPlayers(MaxWhisperDistance:GetInt(), false, noSpeaker), self, CHAT_WHISPER, text, self:Nick(), self:Alive(), isTeamChat and self:Team() or false)
	end
	Jailbreak.Whisper = whisper
end
setChatCommand("w", whisper, "#jb.chat.command.whisper")
setChatCommand("whisper", whisper, "#jb.chat.command.whisper")
do
	local sub, find, Trim = string.sub, string.find, string.Trim
	local AllowTeamChat = Jailbreak.AllowTeamChat
	local CHAT_TEXT = CHAT_TEXT
	local min = math.min
	GM.PlayerSay = function(self, ply, text, isTeamChat)
		text = Trim(text)
		if sub(text, 1, 1) == "/" then
			local startPos, _, command = find(text, "^/([^%s]+)")
			if command then
				local data = chatCommands[lower(command)]
				if data then
					return data[1](ply, Trim(sub(text, min(startPos + #command + 1, #text) + 1)), isTeamChat) or ""
				else
					sendChatText(ply, false, CHAT_SERVERMESSAGE, "#jb.chat.command.unknown", red)
				end
			end
			return ""
		end
		if isTeamChat then
			if not AllowTeamChat:GetBool() then
				ply:Say(text, false)
				return ""
			end
		elseif ply:UsingSecurityRadio() then
			local players = { }
			local _list_0 = GetHumans()
			for _index_0 = 1, #_list_0 do
				local pl = _list_0[_index_0]
				if pl:HasSecurityRadio() then
					players[#players + 1] = pl
				end
			end
			sendChatText(players, ply, CHAT_TEXT, text, ply:Nick(), not ply:Alive(), false, true)
			whisper(ply, text, false, true)
			return ""
		end
		if not GameInProgress() then
			ooc(ply, text, isTeamChat)
			return ""
		end
		sendChatText(false, ply, CHAT_TEXT, text, ply:Nick(), not ply:Alive(), isTeamChat and ply:Team() or false, false)
		return ""
	end
end
do
	local CHAT_CONNECT = CHAT_CONNECT
	Add("PlayerConnect", "Jailbreak::JoinNotification", function(nickname, ip)
		local players, admins = { }, { }
		local _list_0 = GetHumans()
		for _index_0 = 1, #_list_0 do
			local ply = _list_0[_index_0]
			if ply:IsAdmin() then
				admins[#admins + 1] = ply
			else
				players[#players + 1] = ply
			end
		end
		sendChatText(admins, false, CHAT_CONNECT, nickname, ip ~= "none" and ip or nil)
		return sendChatText(players, false, CHAT_CONNECT, nickname)
	end)
end
do
	gameevent.Listen("player_disconnect")
	local CHAT_DISCONNECT = CHAT_DISCONNECT
	Add("player_disconnect", "Jailbreak::LeaveNotification", function(data)
		local players, admins = { }, { }
		local _list_0 = GetHumans()
		for _index_0 = 1, #_list_0 do
			local ply = _list_0[_index_0]
			if ply:IsAdmin() then
				admins[#admins + 1] = ply
			else
				players[#players + 1] = ply
			end
		end
		local steamID = false
		if not data.bot then
			steamID = data.networkid
		end
		sendChatText(admins, false, CHAT_DISCONNECT, data.name, steamID, data.reason)
		return sendChatText(players, false, CHAT_DISCONNECT, data.name)
	end)
end
do
	gameevent.Listen("player_changename")
	local CHAT_NAMECHANGE = CHAT_NAMECHANGE
	local Player = Player
	Add("player_changename", "Jailbreak::NameChangeNotification", function(data)
		local admins = { }
		local _list_0 = GetHumans()
		for _index_0 = 1, #_list_0 do
			local ply = _list_0[_index_0]
			if ply:IsAdmin() then
				admins[#admins + 1] = ply
			end
		end
		local ply, color = Player(data.userid), dark_white
		if ply:IsValid() then
			color = ply:GetModelColor()
		end
		return sendChatText(admins, false, CHAT_NAMECHANGE, data.oldname, data.newname, color)
	end)
end
Add("PlayerInitialSpawn", "Jailbreak::Communication", function(self)
	if not self:IsBot() then
		self.AvailableSpeakers = { }
	end
end)
GM.PlayerCanSeePlayersChat = function(self, text, isTeam, listener, speaker)
	if #text == 0 or listener:IsBot() then
		return false
	end
	if listener:EntIndex() == speaker:EntIndex() then
		return true
	end
	if not (speaker and speaker:IsValid()) then
		return true
	end
	if isTeam and listener:Team() ~= speaker:Team() then
		return false
	end
	if speaker:IsBot() then
		return true
	end
	return listener.AvailableSpeakers[speaker] ~= nil
end
do
	local RecipientFilter = RecipientFilter
	local CHAN_STATIC = CHAN_STATIC
	local CHAT_CUSTOM = CHAT_CUSTOM
	Add("WardenChanged", "Jailbreak::WardenNotification", function(self, state)
		sendChatText(false, false, CHAT_CUSTOM, self:GetModelColor(), self:Nick(), white, state and " #jb.alert.warden-join" or " #jb.alert.warden-leave")
		if state and not self:IsBot() then
			self:SendShopItems()
		end
		local rf = RecipientFilter()
		rf:AddPAS(self:EyePos())
		return self:EmitSound(state and "ui/buttonclick.wav" or "ui/buttonclickrelease.wav", 75, random(80, 120), 1, CHAN_STATIC, 0, 1, rf)
	end)
end
setChatCommand("warden", function(self)
	return self:ConCommand("jb_warden")
end, "#jb.chat.command.warden")
do
	local ChangeTeam = Jailbreak.ChangeTeam
	local func
	func = function(self, text)
		return ChangeTeam(self, tonumber(text) or 0)
	end
	setChatCommand("changeteam", func, "#jb.chat.command.changeteam")
	setChatCommand("team", func, "#jb.chat.command.changeteam")
	do
		local TEAM_PRISONER = TEAM_PRISONER
		setChatCommand("prisoners", function(self)
			return ChangeTeam(self, TEAM_PRISONER)
		end)
	end
	do
		local TEAM_GUARD = TEAM_GUARD
		setChatCommand("guards", function(self)
			return ChangeTeam(self, TEAM_GUARD)
		end)
	end
	do
		local TEAM_SPECTATOR = TEAM_SPECTATOR
		setChatCommand("spectators", function(self)
			return ChangeTeam(self, TEAM_SPECTATOR)
		end)
	end
end
GM.PlayerCanHearPlayersVoice = function(self, listener, speaker)
	if listener:IsBot() or speaker:IsBot() or listener:EntIndex() == speaker:EntIndex() then
		return false, false
	end
	local stereoSound = listener.AvailableSpeakers[speaker]
	if stereoSound ~= nil then
		return true, stereoSound
	end
	return false, false
end
do
	local sendVolumes = nil
	do
		util.AddNetworkString("JB::Communication")
		local Start, WriteUInt, WriteEntity, WriteFloat, Send = net.Start, net.WriteUInt, net.WriteEntity, net.WriteFloat, net.Send
		local VoiceChatUDP = Jailbreak.VoiceChatUDP
		sendVolumes = function(listener, volumes)
			local length = #volumes
			if length == 0 then
				return
			end
			Start("JB::Communication", VoiceChatUDP:GetBool())
			WriteUInt(length, 10)
			for i = 1, length do
				local data = volumes[i]
				WriteEntity(data[1])
				WriteFloat(data[2])
			end
			return Send(listener)
		end
	end
	local IsRoundRunning, VoiceChatSpeed, VoiceChatProximity = Jailbreak.IsRoundRunning, Jailbreak.VoiceChatSpeed, Jailbreak.VoiceChatProximity
	local RecipientFilter = RecipientFilter
	local max, Clamp, Round = math.max, math.Clamp, math.Round
	local Distance = VECTOR.Distance
	local EyePos = ENTITY.EyePos
	local Empty = table.Empty
	local sv_alltalk = GetConVar("sv_alltalk"):GetInt() > 2
	cvars.AddChangeCallback("sv_alltalk", function(_, __, value)
		sv_alltalk = (tonumber(value) or 2) > 2
	end, "Jailbreak")
	cvars.AddChangeCallback(VoiceChatSpeed:GetName(), function(_, __, value)
		return timer.Adjust("JB::Communication", 1 / (tonumber(value) or 4))
	end, "Jailbreak")
	return timer.Create("JB::Communication", 1 / VoiceChatSpeed:GetInt(), 0, function()
		local minDistance, maxDistance = VoiceChatMinDistance:GetInt(), VoiceChatMaxDistance:GetInt()
		local players = GetHumans()
		for _index_0 = 1, #players do
			local listener = players[_index_0]
			local speakers = listener.AvailableSpeakers
			Empty(speakers)
			local listenerIndex = listener:EntIndex()
			local volumes = { }
			if sv_alltalk or not IsRoundRunning() then
				for _index_1 = 1, #players do
					local speaker = players[_index_1]
					if speaker:IsBot() or speaker:EntIndex() == listenerIndex then
						goto _continue_1
					end
					volumes[#volumes + 1] = {
						speaker,
						1
					}
					speakers[speaker] = false
					::_continue_1::
				end
				sendVolumes(listener, volumes)
				goto _continue_0
			end
			local origin = EyePos(listener)
			local rf = RecipientFilter()
			rf:AddPAS(origin)
			local isInGame = listener:Alive()
			local proximityVoiceChat = VoiceChatProximity:GetBool()
			local hasRadio = isInGame and listener:HasSecurityRadio()
			local _list_0 = rf:GetPlayers()
			for _index_1 = 1, #_list_0 do
				local speaker = _list_0[_index_1]
				if speaker:IsBot() or speaker:EntIndex() == listenerIndex then
					goto _continue_2
				end
				if not speaker:Alive() then
					if not isInGame then
						volumes[#volumes + 1] = {
							speaker,
							1
						}
						speakers[speaker] = false
					end
					goto _continue_2
				end
				if not proximityVoiceChat then
					volumes[#volumes + 1] = {
						speaker,
						1
					}
					speakers[speaker] = true
					goto _continue_2
				end
				if proximityVoiceChat and ((hasRadio and speaker:UsingSecurityRadio()) or speaker:UsingMegaphone()) then
					goto _continue_2
				end
				local volume = Round(1 - Clamp(max(0, Distance(origin, EyePos(speaker)) - minDistance) / maxDistance, 0, 1), 2)
				if volume > 0 then
					volumes[#volumes + 1] = {
						speaker,
						volume
					}
					speakers[speaker] = true
				end
				::_continue_2::
			end
			if not proximityVoiceChat then
				goto _continue_0
			end
			for _index_1 = 1, #players do
				local speaker = players[_index_1]
				if speakers[speaker] ~= nil or speaker:IsBot() or speaker:EntIndex() == listenerIndex then
					goto _continue_3
				end
				if (hasRadio and speaker:UsingSecurityRadio()) or speaker:UsingMegaphone() then
					volumes[#volumes + 1] = {
						speaker,
						1
					}
					speakers[speaker] = false
				end
				::_continue_3::
			end
			sendVolumes(listener, volumes)
			::_continue_0::
		end
	end)
end
