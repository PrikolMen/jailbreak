local Jailbreak = Jailbreak
local Colors = Jailbreak.Colors
local blue, butterfly_bush, dark_white, white = Colors.blue, Colors.butterfly_bush, Colors.dark_white, Colors.white
local isstring = isstring
local string = string
local CHAT_SERVERMESSAGE = CHAT_SERVERMESSAGE
local CHAT_TEXT = CHAT_TEXT
local messageHandlers = Jailbreak.MessageHandlers
if not istable(messageHandlers) then
	messageHandlers = { }
	Jailbreak.MessageHandlers = messageHandlers
end
local message = { }
local pointer = 1
local insert
insert = function(value, borders, isTag)
	if isstring(value) then
		if isstring(borders) then
			value = borders[1] .. value .. borders[2]
		end
		if isTag then
			value = value .. " "
		end
	end
	message[pointer] = value
	pointer = pointer + 1
end
Jailbreak.InsertChatValue = insert
do
	local TEXT_FILTER_GAME_CONTENT = TEXT_FILTER_GAME_CONTENT
	local ReadBool, ReadUInt, ReadTable
	do
		local _obj_0 = net
		ReadBool, ReadUInt, ReadTable = _obj_0.ReadBool, _obj_0.ReadUInt, _obj_0.ReadTable
	end
	local TEXT_FILTER_CHAT = TEXT_FILTER_CHAT
	local AddText, PlaySound
	do
		local _obj_0 = chat
		AddText, PlaySound = _obj_0.AddText, _obj_0.PlaySound
	end
	local light_grey = Colors.light_grey
	local FilterText = util.FilterText
	local Run, Call
	do
		local _obj_0 = hook
		Run, Call = _obj_0.Run, _obj_0.Call
	end
	local Entity = Entity
	local unpack = unpack
	local NULL = NULL
	local band = bit.band
	local date = os.date
	local chatSound = CreateClientConVar("jb_chat_sound", "1", true, false, "Play sound of chat messages.", 0, 1)
	local chatTime = CreateClientConVar("jb_chat_time", "1", true, false, "Draw time of chat messages.", 0, 1)
	local cl_chatfilters = GetConVar("cl_chatfilters")
	local performChatMessage
	performChatMessage = function(speaker, messageType, data)
		for index = 1, pointer - 1 do
			message[index] = nil
		end
		pointer = 1
		local handler = messageHandlers[messageType]
		if not handler then
			return false
		end
		if speaker:IsValid() and speaker:IsPlayer() and isstring(data[1]) then
			data[1] = FilterText(data[1], (band(cl_chatfilters:GetInt(), 64) ~= 0) and TEXT_FILTER_CHAT or TEXT_FILTER_GAME_CONTENT, speaker)
			if Call("OnPlayerChat", nil, speaker, data[1], false, speaker:Alive()) then
				return false
			end
		end
		local listener = Jailbreak.Player
		Run("OnChatText", listener, speaker, data)
		if handler(listener, speaker, data) then
			return false
		end
		if chatTime:GetBool() then
			AddText(light_grey, date("[%H:%M:%S] "), unpack(message))
		else
			AddText(unpack(message))
		end
		if chatSound:GetBool() then
			PlaySound()
		end
		return true
	end
	Jailbreak.PerformChatMessage = performChatMessage
	GM.OnAchievementAchieved = function(self, ply, achievementID)
		performChatMessage(ply, CHAT_ACHIEVEMENT, {
			achievementID,
			ply:Nick()
		})
		return
	end
	do
		local buffer = { }
		GM.ChatText = function(self, _, __, text, messageType)
			if "servermsg" == messageType then
				buffer[1] = text
				buffer[2] = nil
				performChatMessage(NULL, CHAT_SERVERMESSAGE, buffer)
			elseif "chat" == messageType then
				buffer[1] = text
				buffer[2] = nil
				performChatMessage(NULL, CHAT_TEXT, buffer)
			end
			return true
		end
		PLAYER.ChatPrint = function(self, text)
			buffer[1] = text
			buffer[2] = white
			performChatMessage(NULL, CHAT_SERVERMESSAGE, buffer)
			return
		end
	end
	net.Receive("Jailbreak::Chat", function()
		performChatMessage(ReadBool() and Entity(ReadUInt(8)) or NULL, ReadUInt(5), ReadTable(true))
		return
	end)
end
GM.OnPlayerChat = function(self)
	return true
end
do
	local GESTURE_SLOT_VCD = GESTURE_SLOT_VCD
	local ACT_GMOD_IN_CHAT = ACT_GMOD_IN_CHAT
	local FrameTime = FrameTime
	local Approach = math.Approach
	GM.GrabEarAnimation = function(self, ply)
		if ply:IsPlayingTaunt() then
			return
		end
		local weight = ply.ChatGestureWeight or 0
		if ply:IsTyping() or (ply:IsSpeaking() and ply:UsingSecurityRadio()) then
			weight = Approach(weight, 1, FrameTime() * 5)
		else
			weight = Approach(weight, 0, FrameTime() * 5)
		end
		ply.ChatGestureWeight = weight
		if weight > 0 then
			ply:AnimRestartGesture(GESTURE_SLOT_VCD, ACT_GMOD_IN_CHAT, true)
			return ply:AnimSetGestureWeight(GESTURE_SLOT_VCD, weight)
		end
	end
end
do
	local TrimLeft, sub, match = string.TrimLeft, string.sub, string.match
	GM.OnChatTab = function(self, text)
		text = TrimLeft(text)
		if sub(text, 1, 1) == "/" then
			local command = match(text, "/([^%s]+)")
			if not command then
				return "/whisper " .. sub(text, 2)
			end
			local arguments = sub(text, #command + 2)
			if "whisper" == command then
				text = "/emotion" .. arguments
			elseif "emotion" == command then
				text = "/coin" .. arguments
			elseif "coin" == command then
				text = "/roll" .. arguments
			elseif "roll" == command then
				text = "/looc" .. arguments
			elseif "looc" == command then
				text = "/ooc" .. arguments
			elseif "ooc" == command then
				text = "/whisper" .. arguments
			end
		else
			text = "/whisper " .. text
		end
		return text
	end
end
local GetTeamColor, Translate = Jailbreak.GetTeamColor, Jailbreak.Translate
local GetPhrase = language.GetPhrase
do
	local horizon = Colors.horizon
	messageHandlers[CHAT_TEXT] = function(listener, speaker, data)
		if data[3] then
			insert(dark_white)
			insert(GetPhrase("jb.chat.dead"), "[]", true)
		end
		local teamID = data[4]
		if teamID then
			insert(GetTeamColor(teamID))
			insert(GetPhrase("jb.chat.team." .. teamID), "[]", true)
		end
		if data[5] then
			insert(horizon)
			insert(GetPhrase("jb.walkie-talkie"), "[]", true)
		end
		local text, nickname, isMuted = data[1], data[2], false
		if speaker:IsValid() then
			if speaker:IsPlayer() then
				if speaker:IsDeveloper() then
					insert(butterfly_bush)
					insert("/", "<>", true)
				end
				insert(speaker:GetModelColor())
				insert(nickname or speaker:Nick())
				if speaker:IsMuted() then
					text, isMuted = GetPhrase("jb.chat.muted"), true
				end
			end
		elseif nickname then
			insert(dark_white)
			insert(nickname)
		else
			insert(butterfly_bush)
			insert(GetPhrase("jb.chat.console"))
		end
		insert(white)
		insert(" " .. GetPhrase("jb.chat.says") .. ": \"")
		if isMuted then
			insert(dark_white)
		end
		insert(text)
		if isMuted then
			insert(white)
		end
		return insert("\"")
	end
end
do
	local turquoise = Colors.turquoise
	local OOCHandler
	OOCHandler = function(listener, speaker, data, isLocal)
		if isLocal then
			insert(blue)
			insert(GetPhrase("jb.chat.looc"), "[]", true)
		else
			insert(turquoise)
			insert(GetPhrase("jb.chat.ooc"), "[]", true)
		end
		if not data[3] then
			insert(dark_white)
			insert(GetPhrase("jb.chat.dead"), "[]", true)
		end
		local teamID = data[4]
		if teamID then
			insert(GetTeamColor(teamID))
			insert(GetPhrase("jb.chat.team." .. teamID), "[]", true)
		end
		local text, nickname, isMuted = data[1], data[2], false
		if speaker:IsValid() and speaker:IsPlayer() then
			if speaker:IsDeveloper() then
				insert(butterfly_bush)
				insert("/", "<>", true)
			end
			insert(speaker:GetModelColor())
			insert(nickname or speaker:Nick())
			if speaker:IsMuted() then
				text, isMuted = GetPhrase("jb.chat.muted"), true
			end
		else
			insert(dark_white)
			insert(nickname)
		end
		insert(white)
		insert(": ")
		if isMuted then
			insert(dark_white)
		end
		return insert(text)
	end
	messageHandlers[CHAT_OOC] = OOCHandler
	messageHandlers[CHAT_LOOC] = function(listener, speaker, data)
		return OOCHandler(listener, speaker, data, true)
	end
end
do
	local remove = table.remove
	messageHandlers[CHAT_EMOTION] = function(listener, speaker, data)
		if not remove(data, 2) then
			insert(dark_white)
			insert(GetPhrase("jb.chat.dead"), "[]", true)
		end
		local nickname = remove(data, 1)
		if speaker:IsValid() and speaker:IsPlayer() then
			if speaker:IsMuted() then
				return true
			end
			if speaker:IsDeveloper() then
				insert(butterfly_bush)
				insert("/", "<>", true)
			end
			insert(speaker:GetModelColor())
			insert(nickname or speaker:Nick())
		else
			insert(dark_white)
			insert(nickname)
		end
		insert(white)
		insert(" ")
		for _index_0 = 1, #data do
			local value = data[_index_0]
			insert(isstring(value) and Translate(value) or value)
		end
	end
end
do
	local MinWhisperDistance, MaxWhisperDistance = Jailbreak.MinWhisperDistance, Jailbreak.MaxWhisperDistance
	local floor, random, max
	do
		local _obj_0 = math
		floor, random, max = _obj_0.floor, _obj_0.random, _obj_0.max
	end
	local sub = utf8.sub
	local replaceSymbols = {
		"#",
		"*",
		"~",
		"-",
		" "
	}
	messageHandlers[CHAT_WHISPER] = function(listener, speaker, data)
		if not data[3] then
			insert(dark_white)
			insert(GetPhrase("jb.chat.dead"), "[]", true)
		end
		local teamID = data[4]
		if teamID then
			insert(GetTeamColor(teamID))
			insert(GetPhrase("jb.chat.team." .. teamID), "[]", true)
		end
		local text, nickname, isMuted = data[1], data[2], false
		if speaker:IsValid() and speaker:IsPlayer() then
			if speaker:IsDeveloper() then
				insert(butterfly_bush)
				insert("/", "<>", true)
			end
			insert(speaker:GetModelColor())
			insert(nickname or speaker:Nick())
			if speaker:IsMuted() then
				text, isMuted = GetPhrase("jb.chat.muted"), true
			end
			local distance, minDistance = speaker:EyePos():Distance(listener:EyePos()), MinWhisperDistance:GetInt()
			if distance > minDistance then
				local maxDistance = MaxWhisperDistance:GetInt()
				if distance > maxDistance then
					return true
				end
				local lostSymbols = { }
				local length = #text
				local fraction = (distance - minDistance) / (maxDistance - minDistance)
				for i = 1, floor(length * fraction) do
					local index = random(1, length)
					while lostSymbols[index] ~= nil do
						index = random(1, length)
					end
					lostSymbols[index] = true
				end
				local newText = ""
				for i = 1, floor(length * max(1 - fraction, 0.25)) do
					if lostSymbols[i] then
						newText = newText .. replaceSymbols[random(1, #replaceSymbols)]
					else
						newText = newText .. sub(text, i, i)
					end
				end
				text = newText
			end
		else
			insert(dark_white)
			insert(nickname)
		end
		insert(white)
		insert(" " .. GetPhrase("jb.chat.whispers") .. ": \"")
		if isMuted then
			insert(dark_white)
		end
		insert(text)
		if isMuted then
			insert(white)
		end
		return insert("\"")
	end
end
messageHandlers[CHAT_CUSTOM] = function(_, __, data)
	for _index_0 = 1, #data do
		local value = data[_index_0]
		insert(isstring(value) and Translate(value) or value)
	end
end
messageHandlers[CHAT_SERVERMESSAGE] = function(_, __, data)
	insert(data[2] or dark_white)
	return insert(Translate(data[1]), nil)
end
messageHandlers[CHAT_CONNECTED] = function(_, __, data)
	insert(white)
	insert(GetPhrase("jb.player") .. " ")
	insert(data[1])
	insert(data[2])
	local steamID = data[3]
	if steamID then
		insert(white)
		insert(" ( ")
		insert(blue)
		insert(steamID)
		insert(white)
		insert(" )")
	end
	insert(white)
	return insert(" " .. GetPhrase("jb.chat.player.connected"))
end
do
	local asparagus = Colors.asparagus
	messageHandlers[CHAT_CONNECT] = function(_, __, data)
		insert(white)
		insert(GetPhrase("jb.player") .. " ")
		insert(asparagus)
		insert(data[1])
		local address = data[2]
		if address then
			insert(white)
			insert(" ( ")
			insert(blue)
			insert(address)
			insert(white)
			insert(" )")
		end
		insert(white)
		return insert(" " .. GetPhrase("jb.chat.player.connecting"))
	end
end
do
	local au_chico = Colors.au_chico
	messageHandlers[CHAT_DISCONNECT] = function(_, __, data)
		insert(white)
		insert(GetPhrase("jb.player") .. " ")
		insert(au_chico)
		insert(data[1])
		local steamID = data[2]
		if steamID then
			insert(white)
			insert(" ( ")
			insert(blue)
			insert(steamID)
			insert(white)
			insert(" )")
		end
		insert(white)
		local reason = data[3]
		if reason ~= nil then
			insert(" " .. GetPhrase("jb.chat.player.disconnected-with-reason") .. ": \"")
			insert(dark_white)
			insert(reason)
			insert(white)
			return insert("\"")
		else
			return insert(" " .. GetPhrase("jb.chat.player.disconnected"))
		end
	end
end
messageHandlers[CHAT_NAMECHANGE] = function(_, __, data)
	insert(white)
	insert(GetPhrase("jb.player") .. " ")
	local color = data[3]
	insert(color)
	insert(data[1])
	insert(white)
	insert(" " .. GetPhrase("jb.chat.player.changed-name") .. " ")
	insert(color)
	insert(data[2])
	insert(white)
	return insert(".")
end
do
	local GetName = achievements.GetName
	local vivid_orange = Colors.vivid_orange
	messageHandlers[CHAT_ACHIEVEMENT] = function(_, speaker, data)
		insert(white)
		insert(GetPhrase("jb.player") .. " ")
		if speaker:IsValid() and speaker:IsPlayer() then
			insert(speaker:GetModelColor())
			insert(speaker:Nick())
		else
			insert(white)
			insert(data[2])
		end
		insert(white)
		insert(" " .. GetPhrase("jb.chat.got-achievement") .. " ")
		insert(vivid_orange)
		if isstring(data[1]) then
			return insert(data[1])
		else
			return insert(GetName(isnumber(data[1]) and data[1] or 2))
		end
	end
end
