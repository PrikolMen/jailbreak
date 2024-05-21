local Jailbreak = Jailbreak
local ceil, min, max, random
do
	local _obj_0 = math
	ceil, min, max, random = _obj_0.ceil, _obj_0.min, _obj_0.max, _obj_0.random
end
local GetNW2Var, SetNW2Var
do
	local _obj_0 = ENTITY
	GetNW2Var, SetNW2Var = _obj_0.GetNW2Var, _obj_0.SetNW2Var
end
local GetGlobal2Bool = GetGlobal2Bool
local GetGlobal2Int = GetGlobal2Int
local Alive, Team
do
	local _obj_0 = PLAYER
	Alive, Team = _obj_0.Alive, _obj_0.Team
end
local Run, Add
do
	local _obj_0 = hook
	Run, Add = _obj_0.Run, _obj_0.Add
end
local Iterator = player.Iterator
local CurTime = CurTime
local Simple = timer.Simple
local ENTITY = ENTITY
local PLAYER = PLAYER
local lower = string.lower
local TEAM_SPECTATOR = TEAM_SPECTATOR
local TEAM_PRISONER = TEAM_PRISONER
local CHAN_STATIC = CHAN_STATIC
local TEAM_GUARD = TEAM_GUARD
local NULL = NULL
do
	local AllowJoinToGuards, GuardsDiff = Jailbreak.AllowJoinToGuards, Jailbreak.GuardsDiff
	local Joinable = team.Joinable
	Jailbreak.TeamIsJoinable = function(requestedTeamID)
		if not Joinable(requestedTeamID) then
			return false
		end
		local guardCount, prisonerCount = 0, 0
		for _, ply in Iterator() do
			local teamID = Team(ply)
			if teamID == TEAM_GUARD then
				guardCount = guardCount + 1
			elseif teamID == TEAM_PRISONER then
				prisonerCount = prisonerCount + 1
			end
		end
		if TEAM_PRISONER == requestedTeamID then
			if prisonerCount == 0 then
				return true
			end
			return guardCount ~= 0
		elseif TEAM_GUARD == requestedTeamID then
			if not AllowJoinToGuards:GetBool() then
				return false
			end
			if guardCount == 0 then
				return true
			end
			if prisonerCount == 0 then
				return false
			end
			return guardCount < ceil(prisonerCount / GuardsDiff:GetInt())
		end
		return true
	end
end
do
	local CLIENT = CLIENT
	local GetPhrase = CLIENT and language.GetPhrase
	Jailbreak.GetWeaponName = function(weapon)
		if not (weapon and weapon:IsValid() and weapon:IsWeapon()) then
			return "#jb.unknown"
		end
		if CLIENT then
			local placeholder = "jb." .. weapon:GetClass()
			if GetPhrase(placeholder) ~= placeholder then
				return "#" .. placeholder
			end
		end
		local printName = weapon:GetPrintName()
		if printName == "Scripted Weapon" then
			printName = "#" .. weapon:GetClass()
		end
		return printName
	end
end
do
	local gsub = string.gsub
	Jailbreak.FixModelPath = function(modelPath)
		return gsub(lower(modelPath), "[\\/]+", "/")
	end
end
Jailbreak.GetPlayersCount = function(teamID, alive)
	local count = 0
	for _, ply in Iterator() do
		if teamID ~= nil and Team(ply) ~= teamID then
			goto _continue_0
		end
		if alive ~= nil and Alive(ply) ~= alive then
			goto _continue_0
		end
		count = count + 1
		::_continue_0::
	end
	return count
end
do
	local ipairs = ipairs
	local length = 0
	Jailbreak.GetTeamPlayers = function(alive, ...)
		local teams = {
			...
		}
		for index, teamID in ipairs(teams) do
			length = 0
			local tbl = { }
			for _, ply in Iterator() do
				if Team(ply) ~= teamID then
					goto _continue_0
				end
				if alive ~= nil and Alive(ply) ~= alive then
					goto _continue_0
				end
				length = length + 1
				tbl[length] = ply
				::_continue_0::
			end
			teams[index] = tbl
		end
		return teams
	end
	Jailbreak.GetTeamPlayersCount = function(alive, ...)
		local teams = {
			...
		}
		for index, teamID in ipairs(teams) do
			length = 0
			for _, ply in Iterator() do
				if Team(ply) ~= teamID then
					goto _continue_0
				end
				if alive ~= nil and Alive(ply) ~= alive then
					goto _continue_0
				end
				length = length + 1
				::_continue_0::
			end
			teams[index] = length
		end
		return teams
	end
end
do
	local getWarden
	getWarden = function()
		local warden = Jailbreak.Warden
		if warden and warden:IsValid() and warden:IsWarden() and Alive(warden) then
			return warden
		end
		for _, ply in Iterator() do
			if ply:IsWarden() then
				Jailbreak.Warden = ply
				return ply
			end
		end
		return NULL
	end
	Jailbreak.GetWarden = getWarden
	Jailbreak.HasWarden = function()
		local warden = getWarden()
		return warden:IsValid() and Alive(warden)
	end
end
do
	local ROUND_WAITING_PLAYERS = ROUND_WAITING_PLAYERS
	local ROUND_PREPARING = ROUND_PREPARING
	local ROUND_RUNNING = ROUND_RUNNING
	local ROUND_FINISHED = ROUND_FINISHED
	local getRoundState
	getRoundState = function()
		return GetGlobal2Int("round-state")
	end
	Jailbreak.GetRoundState = getRoundState
	Jailbreak.IsWaitingPlayers = function(self)
		return getRoundState() == ROUND_WAITING_PLAYERS
	end
	Jailbreak.IsRoundPreparing = function(self)
		return getRoundState() == ROUND_PREPARING
	end
	Jailbreak.IsRoundRunning = function(self)
		return getRoundState() == ROUND_RUNNING
	end
	Jailbreak.IsRoundFinished = function(self)
		return getRoundState() == ROUND_FINISHED
	end
	Jailbreak.GameInProgress = function(self)
		local state = getRoundState()
		return state ~= ROUND_WAITING_PLAYERS and state ~= ROUND_PREPARING
	end
end
do
	local getRoundTime
	getRoundTime = function()
		return GetGlobal2Int("next-round-state")
	end
	Jailbreak.GetRoundTime = getRoundTime
	Jailbreak.GetRemainingTime = function(self)
		return max(0, getRoundTime() - CurTime())
	end
end
Jailbreak.GetWinningTeam = function()
	return GetGlobal2Int("winning-team")
end
Jailbreak.IsShockCollarsActive = function()
	return GetGlobal2Bool("shock-collars")
end
do
	local getWardenCoins
	getWardenCoins = function()
		return GetGlobal2Int("warden-coins")
	end
	Jailbreak.GetWardenCoins = getWardenCoins
	Jailbreak.CanWardenAfford = function(value)
		return getWardenCoins() >= value
	end
end
Jailbreak.DelayedRemove = function(self, delay)
	return Simple(delay or 0, function()
		if self:IsValid() then
			return self:Remove()
		end
	end)
end
Jailbreak.TF2Team = function(teamID)
	if 2 == teamID then
		return TEAM_PRISONER
	elseif 3 == teamID then
		return TEAM_GUARD
	end
	return TEAM_SPECTATOR
end
do
	local date = os.date
	Jailbreak.IsFemalePrison = function()
		if GetGlobal2Bool("female-prison") then
			return true
		end
		local result = date("!*t")
		return result.month == 3 and result.day == 8
	end
end
do
	local AllowCustomPlayerModels, IsFemalePrison = Jailbreak.AllowCustomPlayerModels, Jailbreak.IsFemalePrison
	local TranslateToPlayerModelName = player_manager.TranslateToPlayerModelName
	local isFemalePrison = false
	Jailbreak.FormatPlayerModelName = function(modelName)
		if AllowCustomPlayerModels:GetBool() then
			return modelName
		end
		isFemalePrison = IsFemalePrison()
		local models = Jailbreak.PlayerModels[TEAM_GUARD][isFemalePrison]
		if #models == 0 or models[modelName] then
			return modelName
		end
		models = Jailbreak.PlayerModels[TEAM_PRISONER][isFemalePrison]
		if #models == 0 or models[modelName] then
			return modelName
		end
		return TranslateToPlayerModelName(models[random(1, #models)])
	end
end
PLAYER.IsDeveloper = function(self)
	return GetNW2Var(self, "is-developer", false)
end
PLAYER.UsingSecurityRadio = function(self)
	return GetNW2Var(self, "using-security-radio", false)
end
ENTITY.IsPlayerRagdoll = function(self)
	return GetNW2Var(self, "is-player-ragdoll", false)
end
ENTITY.GetRagdollOwner = function(self)
	return GetNW2Var(self, "ragdoll-owner", NULL)
end
ENTITY.GetRagdollOwnerNickname = function(self)
	local value = GetNW2Var(self, "owner-nickname")
	if not value then
		return "#jb.player.unknown"
	end
	return value
end
do
	local EffectData = EffectData
	local Effect = util.Effect
	ENTITY.DoElectricSparks = function(self, origin, pitch, noSound)
		if not origin then
			local bone = self:LookupBone("ValveBiped.Bip01_Head1")
			if bone and bone >= 0 then
				origin = self:GetBonePosition(bone)
			end
			if not origin then
				origin = self:EyePos()
			end
		end
		local fx = EffectData()
		fx:SetScale(0.5)
		fx:SetOrigin(origin)
		fx:SetMagnitude(random(3, 5))
		fx:SetRadius(random(1, 5))
		Effect("ElectricSpark", fx)
		if noSound ~= true then
			return self:EmitSound("Jailbreak.ElectricSpark", random(50, 90), pitch or random(80, 120), 1, CHAN_STATIC, 0, 1)
		end
	end
end
do
	local DefaultPlayerColor = Jailbreak.DefaultPlayerColor
	local getPlayerColor
	getPlayerColor = function(self)
		return self.m_vPlayerColor or DefaultPlayerColor
	end
	ENTITY.GetPlayerColor, PLAYER.GetPlayerColor = getPlayerColor, getPlayerColor
end
do
	local isvector = isvector
	Add("EntityNetworkedVarChanged", "Jailbreak::PlayerColor", function(self, key, _, value)
		if key == "player-color" and isvector(value) then
			self.m_vPlayerColor = value
			Run("PlayerColorChanged", self, value)
			return
		end
	end)
end
do
	local Call = hook.Call
	do
		local ClearMovement, ClearButtons
		do
			local _obj_0 = CUSERCMD
			ClearMovement, ClearButtons = _obj_0.ClearMovement, _obj_0.ClearButtons
		end
		Add("StartCommand", "Jailbreak::MovementBlocking", function(self, cmd)
			if Call("AllowPlayerMove", nil, self) == false then
				ClearMovement(cmd)
				return ClearButtons(cmd)
			end
		end)
	end
	do
		local GetVelocity, SetVelocity
		do
			local _obj_0 = CMOVEDATA
			GetVelocity, SetVelocity = _obj_0.GetVelocity, _obj_0.SetVelocity
		end
		local FrameTime = FrameTime
		local Lerp = Lerp
		local velocity, frameTime = Vector(), 0
		GM.Move = function(self, ply, mv)
			if Call("AllowPlayerMove", nil, ply) == false then
				velocity, frameTime = GetVelocity(mv), FrameTime()
				velocity[1] = Lerp(frameTime, velocity[1], 0)
				velocity[2] = Lerp(frameTime, velocity[2], 0)
				return SetVelocity(mv, velocity)
			end
		end
	end
end
do
	local ToColor = VECTOR.ToColor
	local defaultColor = ToColor(Jailbreak.DefaultPlayerColor)
	Add("PlayerColorChanged", "Jailbreak::PlayerColor", function(self, vector)
		self.m_cPlayerColor = ToColor(vector)
	end)
	ENTITY.GetModelColor = function(self)
		if self:IsValid() then
			return self.m_cPlayerColor or defaultColor
		end
		return defaultColor
	end
	ENTITY.GetModelColorUnpacked = function(self)
		if self:IsValid() then
			local color = self.m_cPlayerColor or defaultColor
			return color.r, color.g, color.b
		end
		return defaultColor.r, defaultColor.g, defaultColor.b
	end
end
local setPlayerColor
setPlayerColor = function(self, vector)
	return SetNW2Var(self, "player-color", vector)
end
ENTITY.SetPlayerColor, PLAYER.SetPlayerColor = setPlayerColor, setPlayerColor
do
	local classNames = list.GetForEdit("prop-classnames")
	classNames.prop_physics_multiplayer = true
	classNames.prop_physics_override = true
	classNames.prop_dynamic_override = true
	classNames.prop_dynamic = true
	classNames.prop_ragdoll = true
	classNames.prop_physics = true
	classNames.prop_detail = true
	classNames.prop_static = true
	Jailbreak.IsProp = function(className)
		return classNames[className] ~= nil
	end
	local GetClass = ENTITY.GetClass
	ENTITY.IsProp = function(self)
		return classNames[GetClass(self)] ~= nil
	end
	local GetModel = ENTITY.GetModel
	ENTITY.IsFemaleModel = function(self)
		local teamModels = Jailbreak.PlayerModels[self:Team()]
		if not teamModels then
			return false
		end
		local model = lower(GetModel(self))
		local _list_0 = teamModels[true]
		for _index_0 = 1, #_list_0 do
			local modelPath = _list_0[_index_0]
			if modelPath == model then
				return true
			end
		end
		return false
	end
	local paintCans = {
		["models/props_junk/metal_paintcan001a.mdl"] = true,
		["models/props_junk/metal_paintcan001b.mdl"] = true
	}
	ENTITY.IsPaintCan = function(self)
		return classNames[GetClass(self)] ~= nil and paintCans[GetModel(self)] ~= nil
	end
end
ENTITY.IsButton = function(self)
	return GetNW2Var(self, "is-button", false)
end
ENTITY.IsFood = function(self)
	return GetNW2Var(self, "is-food", false)
end
ENTITY.Team = function(self)
	return GetNW2Var(self, "player-team", TEAM_SPECTATOR)
end
ENTITY.Alive = function(self)
	return GetNW2Var(self, "alive", false) and self:Health() >= 1
end
do
	local DefaultColor = Color(255, 255, 100, 255)
	local TeamInfo = team.GetAllTeams()
	local getTeamColor
	getTeamColor = function(teamID)
		local teamInfo = TeamInfo[teamID]
		if teamInfo ~= nil then
			return teamInfo.Color
		end
		return DefaultColor
	end
	Jailbreak.GetTeamColor = getTeamColor
	local getTeamColorUpacked
	getTeamColorUpacked = function(teamID)
		local color = getTeamColor(teamID)
		return color.r, color.g, color.b, color.a
	end
	Jailbreak.GetTeamColorUpacked = getTeamColorUpacked
	PLAYER.GetTeamColor = function(self)
		return getTeamColor(Team(self))
	end
	PLAYER.GetTeamColorUpacked = function(self)
		return getTeamColorUpacked(Team(self))
	end
end
PLAYER.IsFullyConnected = function(self)
	return GetNW2Var(self, "fully-connected", false)
end
PLAYER.IsFlightAllowed = function(self)
	return GetNW2Var(self, "flight-allowed", false)
end
do
	local length = 0
	PLAYER.GetWeaponsInSlot = function(self, slot)
		local weapons = { }
		length = 0
		local _list_0 = self:GetWeapons()
		for _index_0 = 1, #_list_0 do
			local weapon = _list_0[_index_0]
			if weapon:GetSlot() == slot then
				length = length + 1
				weapons[length] = weapon
			end
		end
		return weapons, length
	end
end
PLAYER.HasWeaponsInSlot = function(self, slot)
	local _list_0 = self:GetWeapons()
	for _index_0 = 1, #_list_0 do
		local weapon = _list_0[_index_0]
		if weapon:GetSlot() == slot then
			return true
		end
	end
	return false
end
do
	local count = 0
	PLAYER.GetCountWeaponsInSlot = function(self, slot)
		count = 0
		local _list_0 = self:GetWeapons()
		for _index_0 = 1, #_list_0 do
			local weapon = _list_0[_index_0]
			if weapon:GetSlot() == slot then
				count = count + 1
			end
		end
		return count
	end
end
PLAYER.GetRagdollEntity = function(self)
	return GetNW2Var(self, "player-ragdoll", NULL)
end
do
	local FindByClass = ents.FindByClass
	PLAYER.FindRagdollEntity = function(self)
		local ragdoll = GetNW2Var(self, "player-ragdoll")
		if ragdoll and ragdoll:IsValid() then
			return ragdoll
		end
		local isBot = self:IsBot()
		local sid64 = isBot and self:Nick() or self:SteamID64()
		local _list_0 = FindByClass("prop_ragdoll")
		for _index_0 = 1, #_list_0 do
			local entity = _list_0[_index_0]
			if entity:IsPlayerRagdoll() and GetNW2Var(entity, isBot and "owner-nickname" or "owner-steamid64") == sid64 then
				SetNW2Var(self, "player-ragdoll", entity)
				return entity
			end
		end
		local _list_1 = FindByClass("prop_physics")
		for _index_0 = 1, #_list_1 do
			local entity = _list_1[_index_0]
			if entity:IsPlayerRagdoll() and GetNW2Var(entity, isBot and "owner-nickname" or "owner-steamid64") == sid64 then
				SetNW2Var(self, "player-ragdoll", entity)
				return entity
			end
		end
		return NULL
	end
end
PLAYER.IsGuard = function(self)
	return Team(self) == TEAM_GUARD
end
PLAYER.IsPrisoner = function(self)
	return Team(self) == TEAM_PRISONER
end
PLAYER.IsWarden = function(self)
	return GetNW2Var(self, "is-warden", false)
end
do
	local hasShockCollar
	hasShockCollar = function(self)
		return GetNW2Var(self, "shock-collar", false)
	end
	PLAYER.HasShockCollar = hasShockCollar
	PLAYER.ShockCollarIsEnabled = function(self)
		return hasShockCollar(self) and GetNW2Var(self, "shock-collar-enabled", false)
	end
end
PLAYER.HasSecurityKeys = function(self)
	return GetNW2Var(self, "security-keys", false)
end
PLAYER.HasSecurityRadio = function(self)
	return GetNW2Var(self, "security-radio", false)
end
do
	local FindInSphere = ents.FindInSphere
	PLAYER.GetNearPlayers = function(self, distance, isTeam, noSpeaker)
		local teamID = false
		if isTeam then
			teamID = Team(self)
		end
		local players = { }
		local _list_0 = FindInSphere(self:EyePos(), distance)
		for _index_0 = 1, #_list_0 do
			local ply = _list_0[_index_0]
			if not ply:IsPlayer() then
				goto _continue_0
			end
			if noSpeaker and ply == self then
				goto _continue_0
			end
			if isTeam and Team(ply) ~= teamID then
				goto _continue_0
			end
			players[#players + 1] = ply
			::_continue_0::
		end
		return players
	end
end
do
	local KeyDown = PLAYER.KeyDown
	local IN_USE = IN_USE
	PLAYER.GetUsedEntity = function(self)
		if KeyDown(self, IN_USE) then
			return self:GetUseEntity()
		end
		return NULL
	end
	PLAYER.IsUsingEntity = function(self)
		if KeyDown(self, IN_USE) then
			local entity = self:GetUseEntity()
			return entity ~= NULL and entity:IsValid()
		end
		return false
	end
	PLAYER.IsHoldingEntity = function(self)
		return GetNW2Var(self, "holding-entity", NULL):IsValid()
	end
	PLAYER.GetHoldingEntity = function(self)
		return GetNW2Var(self, "holding-entity", NULL)
	end
	PLAYER.GetUseTime = function(self)
		if not KeyDown(self, IN_USE) then
			return 0
		end
		local startUseTime = GetNW2Var(self, "start-use-time")
		if not startUseTime then
			return 0
		end
		return CurTime() - startUseTime
	end
end
do
	local GetAmmoCount = PLAYER.GetAmmoCount
	local GetAmmoMax = game.GetAmmoMax
	local count = 0
	local getAmmoMax
	getAmmoMax = function(ammoType)
		count = GetAmmoMax(ammoType)
		if count < 0 or count > 256 then
			return 256
		end
		return count
	end
	Jailbreak.GetAmmoMax = getAmmoMax
	PLAYER.GetPickupAmmoCount = function(self, ammoType)
		count = getAmmoMax(ammoType) - GetAmmoCount(self, ammoType)
		if count < 0 then
			return 0
		end
		return count
	end
end
PLAYER.IsSpawning = function(self)
	return Alive(self) and GetNW2Var(self, "is-spawning", false)
end
PLAYER.IsEscaped = function(self)
	return GetNW2Var(self, "escaped", false)
end
PLAYER.IsLoseConsciousness = function(self)
	return GetNW2Var(self, "lost-consciousness", false)
end
do
	local BuyZones = Jailbreak.BuyZones
	PLAYER.IsInBuyZone = function(self)
		return not BuyZones:GetBool() or GetNW2Var(self, "in-buy-zone", false)
	end
end
do
	local MOVETYPE_NOCLIP = MOVETYPE_NOCLIP
	local GetMoveType = ENTITY.GetMoveType
	PLAYER.InNoclip = function(self)
		return GetMoveType(self) == MOVETYPE_NOCLIP
	end
	PLAYER.SetNoclip = function(self, desiredState, force)
		if desiredState == self:InNoclip() then
			return true
		end
		if not force and Run("PlayerNoClip", self, desiredState) == false then
			return false
		end
		self:SetMoveType(desiredState and MOVETYPE_NOCLIP or MOVETYPE_WALK)
		return true
	end
end
do
	local sounds = { }
	for number = 1, 6 do
		sounds[number] = "ambient/energy/spark" .. number .. ".wav"
	end
	sound.Add({
		name = "Jailbreak.ElectricSpark",
		channel = CHAN_WEAPON,
		level = SNDLVL_70dB,
		sound = sounds,
		pitch = 100,
		volume = 1
	})
end
do
	local sounds = { }
	for number = 1, 6 do
		sounds[number] = "vo/npc/male01/pain0" .. number .. ".wav"
	end
	sound.Add({
		name = "Jailbreak.Male.Pain",
		channel = CHAN_STATIC,
		level = SNDLVL_TALKING,
		sound = sounds,
		pitch = 100,
		volume = 1
	})
end
do
	local sounds = { }
	for number = 1, 6 do
		sounds[number] = "vo/npc/female01/pain0" .. number .. ".wav"
	end
	sound.Add({
		name = "Jailbreak.Female.Pain",
		channel = CHAN_STATIC,
		level = SNDLVL_TALKING,
		sound = sounds,
		pitch = 100,
		volume = 1
	})
end
hook.Remove("PostDrawEffects", "RenderWidgets")
return hook.Remove("PlayerTick", "TickWidgets")
