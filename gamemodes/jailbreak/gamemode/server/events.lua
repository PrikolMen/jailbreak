local ErrorNoHaltWithStack = ErrorNoHaltWithStack
local random, Clamp, Rand
do
	local _obj_0 = math
	random, Clamp, Rand = _obj_0.random, _obj_0.Clamp, _obj_0.Rand
end
local Jailbreak = Jailbreak
local Add, Remove
do
	local _obj_0 = hook
	Add, Remove = _obj_0.Add, _obj_0.Remove
end
local tostring = tostring
local Simple = timer.Simple
local xpcall = xpcall
local gsub = string.gsub
local ROUND_RUNNING = ROUND_RUNNING
local ROUND_FINISHED = ROUND_FINISHED
local TEAM_PRISONER = TEAM_PRISONER
local Colors, SendChatText, GetTeamPlayers, IsRoundRunning = Jailbreak.Colors, Jailbreak.SendChatText, Jailbreak.GetTeamPlayers, Jailbreak.IsRoundRunning
local CHAT_SERVERMESSAGE = CHAT_SERVERMESSAGE
local CHAT_CUSTOM = CHAT_CUSTOM
local white = Colors.white
local events = Jailbreak.Events
if not istable(events) then
	events = { }
	Jailbreak.Events = events
end
local JailbreakEvent
do
	local _class_0
	local _base_0 = {
		ConVarFlags = bit.bor(FCVAR_ARCHIVE, FCVAR_NOTIFY),
		GetStartState = function(self)
			return self.startState
		end,
		SetStartState = function(self, state)
			self.startState = state
		end,
		GetFinishState = function(self)
			return self.finishState
		end,
		SetFinishState = function(self, state)
			self.finishState = state
		end,
		ConVar = function(self, default)
			return self:SetChance(CreateConVar("jb_event_" .. gsub(self.name, "[%p%s]+", "_") .. "_chance", tostring(Clamp(default, 0, 100)), self.ConVarFlags, "Chance of '" .. self.name .. "' event.", 0, 100))
		end,
		GetChance = function(self)
			return self.chance
		end,
		SetChance = function(self, chance)
			if TypeID(chance) ~= TYPE_CONVAR then
				assert(isnumber(chance), "chance must be a number")
			end
			self.chance = chance
		end,
		GetType = function(self)
			return self.type
		end,
		SetType = function(self, str)
			assert(isstring(str), "type must be a string")
			self.type = str
		end,
		GetColor = function(self)
			return self.color
		end,
		SetColor = function(self, color)
			assert(IsColor(color), "color must be a Color")
			self.color = color
		end,
		GetMessage = function(self)
			return self.color, "#jb.event." .. self.name
		end,
		SendMessage = function(self)
			return SendChatText(false, false, CHAT_CUSTOM, white, "#jb.round.modifier.added: ", self:GetMessage())
		end,
		Finish = function(self, state)
			if state ~= self.finishState then
				return
			end
			local finish = self.finish
			if finish then
				return xpcall(finish, ErrorNoHaltWithStack, self, state)
			end
		end,
		Run = function(self, state)
			if state ~= self.startState then
				return
			end
			local chance = self.chance
			if not chance then
				return
			end
			if TypeID(chance) == TYPE_CONVAR then
				chance = chance:GetInt()
			end
			if isnumber(chance) and ((chance == 0) or (chance ~= 100 and random(1, 100) > chance)) then
				return
			end
			local status, writeMessage, stopEvents = xpcall(self.init, ErrorNoHaltWithStack, self, state)
			if status and writeMessage then
				self:SendMessage()
			end
			return stopEvents or false
		end
	}
	if _base_0.__index == nil then
		_base_0.__index = _base_0
	end
	_class_0 = setmetatable({
		__init = function(self, name, init, finish)
			assert(isstring(name), "name must be a string")
			assert(isfunction(init), "init must be a function")
			self.startState = ROUND_PREPARING
			self.finishState = ROUND_RUNNING
			self.type = "default"
			if isfunction(finish) then
				self.finish = finish
			end
			self.color = white
			self.init = init
			self.name = name
			events[#events + 1] = self
		end,
		__base = _base_0,
		__name = "JailbreakEvent"
	}, {
		__index = _base_0,
		__call = function(cls, ...)
			local _self_0 = setmetatable({ }, _base_0)
			cls.__init(_self_0, ...)
			return _self_0
		end
	})
	_base_0.__class = _class_0
	JailbreakEvent = _class_0
end
local registerEvent
registerEvent = function(name, init, finish)
	for _index_0 = 1, #events do
		local event = events[_index_0]
		if event.name == name then
			event.init = init
			event.finish = finish
			return event
		end
	end
	return JailbreakEvent(name, init, finish)
end
Jailbreak.RegisterEvent = registerEvent
Jailbreak.RunEvents = function(state)
	local stoppedTypes = { }
	for _index_0 = 1, #events do
		local event = events[_index_0]
		event:Finish(state)
		if stoppedTypes[event.type] then
			goto _continue_0
		end
		if event:Run(state) then
			stoppedTypes[event.type] = true
		end
		::_continue_0::
	end
end
do
	local event = registerEvent("female-prison", function()
		Jailbreak.SetFemalePrison(true)
		return true, true
	end, function()
		return Jailbreak.SetFemalePrison(false)
	end)
	event:SetFinishState(ROUND_FINISHED)
	event:SetType("playermodel")
	event:SetColor(Colors.pink)
	event:ConVar(15)
end
do
	local playerModels = player_manager.AllValidModels()
	local Vector = Vector
	local Random = table.Random
	local event = registerEvent("masquerade", function()
		Add("PlayerSetModel", "Jailbreak::MasqueradeEvent", function(self)
			local modelPath = Random(playerModels)
			if modelPath == nil then
				return
			end
			self:SetModel(modelPath)
			return true
		end)
		Add("PlayerModelChanged", "Jailbreak::MasqueradeEvent", function(self)
			if self:IsBot() then
				return
			end
			self:SetPlayerColor(Vector(Rand(0, 1), Rand(0, 1), Rand(0, 1)))
			self:SetWeaponColor(Vector(Rand(0, 1), Rand(0, 1), Rand(0, 1)))
			self:SetSkin(random(0, self:SkinCount()))
			local _list_0 = self:GetBodyGroups()
			for _index_0 = 1, #_list_0 do
				local bodygroup = _list_0[_index_0]
				self:SetBodygroup(bodygroup.id, random(0, bodygroup.num - 1))
			end
			return true
		end)
		return true, true
	end, function()
		Remove("PlayerModelChanged", "Jailbreak::MasqueradeEvent")
		return Remove("PlayerSetModel", "Jailbreak::MasqueradeEvent")
	end)
	event:SetFinishState(ROUND_FINISHED)
	event:SetType("playermodel")
	event:ConVar(5)
	local HSVToColor = HSVToColor
	event.SendMessage = function(self)
		local seed = random(0, 360)
		local _list_0 = player.GetHumans()
		for _index_0 = 1, #_list_0 do
			local ply = _list_0[_index_0]
			local text = Jailbreak.GetPhrase(ply, "jb.event." .. self.name)
			local message, index = { }, 0
			for i = 1, utf8.len(text) do
				index = index + 1
				message[index] = HSVToColor(i * seed % 360, 1, 1)
				index = index + 1
				message[index] = utf8.sub(text, i, i)
			end
			SendChatText(ply, false, CHAT_CUSTOM, white, "#jb.round.modifier.added: ", unpack(message))
		end
	end
end
do
	local event = registerEvent("grass-is-lava", function()
		Add("PlayerDeathSound", "Jailbreak::GrassIsLavaEvent", function(self)
			self:EmitSound("vo/npc/" .. (self:IsFemaleModel() and "fe" or "") .. "male01/ohno.wav", 90, random(80, 120), 1, CHAN_STATIC, 0, 1)
			return true
		end)
		local TraceHull = util.TraceHull
		local traceResult = { }
		local trace = {
			output = traceResult
		}
		Add("PlayerFootstep", "Jailbreak::GrassIsLavaEvent", function(self, pos, _, __, volume)
			if not self:Alive() then
				return
			end
			local _update_0 = 3
			pos[_update_0] = pos[_update_0] - 8
			trace.mins, trace.maxs = self:GetCollisionBounds()
			trace.start = self:EyePos()
			trace.endpos = pos
			trace.filter = self
			TraceHull(trace)
			if not (traceResult.Hit and traceResult.HitWorld) then
				return
			end
			if traceResult.MatType == MAT_GRASS then
				self:SetColor(Colors.black)
				self:Ignite(0.25, 32)
				local damageInfo = DamageInfo()
				damageInfo:SetDamageType(DMG_BURN)
				damageInfo:SetDamage(self:Health() + self:Armor())
				damageInfo:SetDamageForce((trace.start - pos) * 10)
				damageInfo:SetDamagePosition(pos)
				damageInfo:SetAttacker(self)
				self:TakeDamageInfo(damageInfo)
				return true
			end
		end)
		return true, false
	end, function()
		Remove("PlayerDeathSound", "Jailbreak::GrassIsLavaEvent")
		return Remove("PlayerFootstep", "Jailbreak::GrassIsLavaEvent")
	end)
	event:SetStartState(ROUND_RUNNING)
	event:SetFinishState(ROUND_FINISHED)
	event:SetType("death")
	event:ConVar(5)
	event.SendMessage = function(self)
		local _list_0 = player.GetHumans()
		for _index_0 = 1, #_list_0 do
			local ply = _list_0[_index_0]
			local text = Jailbreak.GetPhrase(ply, "jb.event." .. self.name)
			local message, index = { }, 0
			local length = utf8.len(text)
			for i = 1, length do
				index = index + 1
				message[index] = HSVToColor((length - i) * 10 % 360, 1, 1)
				index = index + 1
				message[index] = utf8.sub(text, i, i)
			end
			SendChatText(ply, false, CHAT_CUSTOM, white, "#jb.round.modifier.added: ", unpack(message))
		end
	end
end
do
	local event = registerEvent("powerful-players", function()
		Jailbreak.PowerfulPlayers = true
		Add("EntityTakeDamage", "Jailbreak::PowerfulPlayers", function(self, damageInfo)
			local attacker = damageInfo:GetAttacker()
			if attacker:IsValid() or attacker:IsPlayer() then
				return damageInfo:ScaleDamage(2)
			end
		end)
		for _, ply in player.Iterator() do
			if ply:Alive() then
				ply:AnimRestartNetworkedGesture(GESTURE_SLOT_CUSTOM, ACT_GMOD_GESTURE_TAUNT_ZOMBIE, true)
			end
		end
		return true, false
	end, function()
		Remove("EntityTakeDamage", "Jailbreak::PowerfulPlayers")
		Jailbreak.PowerfulPlayers = false
	end)
	event:SetStartState(ROUND_RUNNING)
	event:SetFinishState(ROUND_FINISHED)
	event:SetColor(Colors.red)
	event:SetType("damage")
	event:ConVar(5)
end
do
	local ceil = math.ceil
	local event = registerEvent("random-knife", function()
		return Simple(0, function()
			if not IsRoundRunning() then
				return
			end
			local prisoners = GetTeamPlayers(true, TEAM_PRISONER)[1]
			local prisonerCount = #prisoners
			if prisonerCount == 0 then
				return
			end
			for i = 1, ceil(prisonerCount * 0.25) do
				local ply = prisoners[random(1, prisonerCount)]
				if not (ply and ply:IsValid()) then
					goto _continue_0
				end
				if not ply:HasWeapon("weapon_knife") then
					ply:Give("weapon_knife", false, true)
				end
				::_continue_0::
			end
		end)
	end)
	event:SetStartState(ROUND_RUNNING)
	event:SetFinishState(nil)
	event:SetType("weapon")
	event:ConVar(10)
end
do
	local event = registerEvent("hidden-angel", function()
		local prisoners = GetTeamPlayers(true, TEAM_PRISONER)[1]
		local prisonerCount = #prisoners
		if prisonerCount == 0 then
			return false, false
		end
		local ply = prisoners[random(1, prisonerCount)]
		if not (ply and ply:IsValid() and ply:Alive()) then
			return false, false
		end
		ply:AllowFlight(true)
		SendChatText(ply, false, CHAT_SERVERMESSAGE, "#jb.event.hidden-angel.message")
		return true, true
	end)
	event:SetStartState(ROUND_RUNNING)
	event:SetColor(Colors.dark_white)
	event:SetType("movement")
	event:ConVar(25)
end
do
	local event = registerEvent("heaven", function()
		local guards = GetTeamPlayers(true, TEAM_GUARD)
		if not guards then
			return false, false
		end
		guards = guards[1]
		if not guards then
			return false, false
		end
		SetGlobal2Bool("Jailbreak::Heaven", true)
		for _index_0 = 1, #guards do
			local ply = guards[_index_0]
			ply:AllowFlight(true)
		end
		Add("PlayerRagdollCreated", "Jailbreak::Heaven", function(_, ragdoll)
			return Simple(1, function()
				if ragdoll:IsValid() then
					return ragdoll:Dissolve()
				end
			end)
		end)
		return true, true
	end, function()
		Remove("PlayerRagdollCreated", "Jailbreak::Heaven")
		return SetGlobal2Bool("Jailbreak::Heaven", false)
	end)
	event:SetStartState(ROUND_RUNNING)
	event:SetFinishState(ROUND_FINISHED)
	event:SetColor(Colors.dark_white)
	event:SetType("world")
	event:ConVar(5)
end
do
	local event = registerEvent("hell", function()
		local prisoners = GetTeamPlayers(true, TEAM_PRISONER)
		if not prisoners then
			return false, false
		end
		prisoners = prisoners[1]
		if not prisoners then
			return false, false
		end
		SetGlobal2Bool("Jailbreak::Hell", true)
		for _index_0 = 1, #prisoners do
			local ply = prisoners[_index_0]
			ply:SetEscaped(true)
			ply:AllowFlight(true)
			ply:GiveRandomWeapons(3)
			ply:SetModel("models/player/charple.mdl")
		end
		local _list_0 = ents.FindByClass("prop_door_rotating")
		for _index_0 = 1, #_list_0 do
			local entity = _list_0[_index_0]
			entity:Fire("Open")
		end
		local _list_1 = ents.FindByClass("func_door*")
		for _index_0 = 1, #_list_1 do
			local entity = _list_1[_index_0]
			entity:Fire("Open")
		end
		return true, true
	end, function()
		return SetGlobal2Bool("Jailbreak::Hell", false)
	end)
	event:SetStartState(ROUND_RUNNING)
	event:SetFinishState(ROUND_FINISHED)
	event:SetColor(Colors.red)
	event:SetType("world")
	event:ConVar(5)
end
do
	local event = registerEvent("moon-gravity", function()
		Jailbreak.__oldGravity = cvars.String("sv_gravity")
		RunConsoleCommand("sv_gravity", "200")
		return true, true
	end, function()
		return RunConsoleCommand("sv_gravity", Jailbreak.__oldGravity or "800")
	end)
	event:SetStartState(ROUND_RUNNING)
	event:SetFinishState(ROUND_FINISHED)
	event:SetColor(Colors.dark_white)
	event:SetType("world")
	event:ConVar(10)
end
do
	local event = registerEvent("spooky-scary-skeletons", function()
		Add("PlayerSetModel", "Jailbreak::SpookySkeletonsEvent", function(self)
			self:SetModel("models/player/skeleton.mdl")
			return true
		end)
		Add("PlayerModelChanged", "Jailbreak::SpookySkeletonsEvent", function(self)
			self:SetSkin(self:IsPrisoner() and 2 or 1)
			return true
		end)
		Add("PostPlayerSpawn", "Jailbreak::SpookySkeletonsEvent", function(self)
			self:SetMaxHealth(50)
			return self:SetHealth(50)
		end)
		return true, true
	end, function()
		Remove("PlayerSetModel", "Jailbreak::SpookySkeletonsEvent")
		Remove("PlayerModelChanged", "Jailbreak::SpookySkeletonsEvent")
		return Remove("PostPlayerSpawn", "Jailbreak::SpookySkeletonsEvent")
	end)
	event:SetFinishState(ROUND_FINISHED)
	event:SetColor(Colors.dark_white)
	event:SetType("playermodel")
	return event:ConVar(8)
end
