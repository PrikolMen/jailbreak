local random, max, min, floor, Rand = math.random, math.max, math.min, math.floor, math.Rand
local Teams, GameInProgress = Jailbreak.Teams, Jailbreak.GameInProgress
local SetNW2Var = ENTITY.SetNW2Var
local Simple = timer.Simple
local Jailbreak = Jailbreak
local Run = hook.Run
local CurTime = CurTime
local Vector = Vector
local GM = GM
local OBS_MODE_ROAMING = OBS_MODE_ROAMING
local OBS_MODE_CHASE = OBS_MODE_CHASE
local TEAM_PRISONER = TEAM_PRISONER
local TEAM_GUARD = TEAM_GUARD
GM.ShowTeam = function(self, ply)
	return ply:ConCommand("jb_showteam")
end
do
	local RENDERMODE_TRANSCOLOR = RENDERMODE_TRANSCOLOR
	GM.PlayerInitialSpawn = function(self, ply, transiton)
		ply:SetNoCollideWithTeammates(Jailbreak.GameName == "tf")
		ply:SetRenderMode(RENDERMODE_TRANSCOLOR)
		ply:SetAvoidPlayers(true)
		ply:SetCanZoom(false)
		local ragdoll = ply:FindRagdollEntity()
		if ragdoll:IsValid() then
			SetNW2Var(ragdoll, "ragdoll-owner", ply)
		else
			ply:SetTeam(TEAM_PRISONER)
		end
		ply.m_bInitialSpawn = true
	end
end
do
	local RagdollRemove, GuardsArmor, AllowWeaponsInVehicle = Jailbreak.RagdollRemove, Jailbreak.GuardsArmor, Jailbreak.AllowWeaponsInVehicle
	local white = Jailbreak.Colors.white
	GM.PlayerSpawn = function(self, ply, transiton)
		ply:SetAllowWeaponsInVehicle(AllowWeaponsInVehicle:GetBool())
		ply:RemoveFromObserveTargets()
		ply:SetColor(white)
		ply:SetupMovement()
		ply:RemoveAllAmmo()
		ply:StripWeapons()
		ply:UnSpectate()
		local ragdoll = ply:FindRagdollEntity()
		if ragdoll:IsValid() and ragdoll:Alive() then
			ply:SpawnFromRagdoll(ragdoll)
			Run("PostPlayerSpawn", ply)
			ragdoll:SetAlive(false)
			ragdoll:Remove()
			return
		end
		if ply.m_bInitialSpawn ~= nil then
			ply.m_bInitialSpawn = nil
			if GameInProgress() then
				if ragdoll:IsValid() then
					ply:SpawnFromRagdoll(ragdoll)
				end
				ply:KillSilent()
				return
			end
		end
		local teamID = ply:Team()
		if not Teams[teamID] then
			ply:KillSilent()
			return
		end
		if RagdollRemove:GetBool() then
			ply:RemoveRagdoll()
		end
		Run("PlayerSetModel", ply)
		ply:SetMaxHealth(100)
		ply:SetHealth(100)
		if teamID == TEAM_GUARD then
			local armor = GuardsArmor:GetInt()
			ply:SetMaxArmor(max(100, armor))
			ply:SetArmor(armor)
			ply:GiveSecurityRadio()
			ply:GiveSecurityKeys()
			ply:GiveFlashlight()
		else
			ply:SetMaxArmor(100)
			ply:SetArmor(0)
		end
		if not transiton then
			Run("PlayerLoadout", ply)
		end
		return Run("PostPlayerSpawn", ply)
	end
end
do
	local Empty, Shuffle = table.Empty, table.Shuffle
	local GetSpawnPoint = team.GetSpawnPoint
	local FindByClass = ents.FindByClass
	local vector_origin = vector_origin
	local cache, lastIndex, length, teamID = { }, 0, 0, 0
	hook.Add("PostCleanupMap", "Jailbreak::ClearSpawnPointCache", function()
		Empty(cache)
		lastIndex = 0
	end)
	GM.PlayerSelectSpawn = function(self, ply, transition)
		if transiton then
			return
		end
		teamID = ply:Team()
		if not Teams[teamID] then
			teamID = random(1, 2)
		end
		local spawnPoints = cache[teamID]
		if not spawnPoints then
			spawnPoints, length = { }, 0
			local _list_0 = GetSpawnPoint(teamID)
			for _index_0 = 1, #_list_0 do
				local className = _list_0[_index_0]
				local _list_1 = FindByClass(className)
				for _index_1 = 1, #_list_1 do
					local entity = _list_1[_index_1]
					if className ~= "info_player_teamspawn" or (not entity.Disabled and entity:Team() == teamID) then
						length = length + 1
						spawnPoints[length] = entity
					end
				end
			end
			if length > 1 then
				Shuffle(spawnPoints)
			end
			cache[teamID] = spawnPoints
		end
		length = #spawnPoints
		if length ~= 0 then
			if length == 1 then
				return spawnPoints[1]
			end
			lastIndex = lastIndex + 1
			if lastIndex > length then
				lastIndex = 1
			end
			local spawnPoint = spawnPoints[lastIndex]
			if spawnPoint and spawnPoint:IsValid() then
				return spawnPoint
			end
		end
		return ply:SetPos(vector_origin)
	end
end
GM.SetupMove = function(self, ply, _, cmd)
	if ply:IsFullyConnected() or not (cmd:IsForced() or ply:IsBot()) then
		return
	end
	SetNW2Var(ply, "fully-connected", true)
	return Run("PlayerInitialized", ply)
end
do
	local AllowCustomPlayerModels, IsFemalePrison = Jailbreak.AllowCustomPlayerModels, Jailbreak.IsFemalePrison
	local TranslatePlayerModel = player_manager.TranslatePlayerModel
	local match = string.match
	local length = 0
	GM.PlayerSetModel = function(self, ply)
		local modelPath = TranslatePlayerModel(ply:GetInfo("jb_playermodel"))
		if AllowCustomPlayerModels:GetBool() and ply:SetModel(modelPath) then
			return
		end
		local models = Jailbreak.PlayerModels[ply:Team()][IsFemalePrison()]
		length = #models
		if length == 1 then
			ply:SetModel(models[1])
			return
		end
		local requestedName = match(modelPath, "([%w%_%-]+)%.mdl$")
		for index = 1, length do
			if (models[index] == modelPath or match(models[index], "([%w%_%-]+)%.mdl$") == requestedName) and ply:SetModel(models[index]) then
				return
			end
		end
		ply:SetModel(models[random(1, length)])
		return
	end
end
do
	local AllowCustomPlayerColors, AllowCustomWeaponColors, DefaultTeamColors = Jailbreak.AllowCustomPlayerColors, Jailbreak.AllowCustomWeaponColors, Jailbreak.DefaultTeamColors
	local Explode = string.Explode
	local tonumber = tonumber
	local defaultWeaponColor = Vector(0.001, 0.001, 0.001)
	GM.PlayerModelChanged = function(self, ply)
		local isBot = ply:IsBot()
		if isBot then
			ply:SetSkin(random(0, ply:SkinCount()))
			local _list_0 = ply:GetBodyGroups()
			for _index_0 = 1, #_list_0 do
				local bodygroup = _list_0[_index_0]
				ply:SetBodygroup(bodygroup.id, random(0, bodygroup.num - 1))
			end
		else
			ply:SetSkin(ply:GetInfoNum("jb_playerskin", 0))
			local groups = Explode(" ", ply:GetInfo("jb_playerbodygroups") or "")
			for i = 0, ply:GetNumBodyGroups() - 1 do
				ply:SetBodygroup(i, tonumber(groups[i + 1]) or 0)
			end
		end
		if not AllowCustomPlayerColors:GetBool() then
			ply:SetPlayerColor(DefaultTeamColors[ply:Team()])
		elseif isBot then
			ply:SetPlayerColor(Vector(Rand(0, 1), Rand(0, 1), Rand(0, 1)))
		else
			ply:SetPlayerColor(Vector(ply:GetInfo("cl_playercolor")))
		end
		if not AllowCustomWeaponColors:GetBool() then
			ply:SetWeaponColor(DefaultTeamColors[ply:Team()])
		elseif isBot then
			ply:SetWeaponColor(Vector(Rand(0, 1), Rand(0, 1), Rand(0, 1)))
		else
			local weaponColor = Vector(ply:GetInfo("cl_weaponcolor"))
			if weaponColor:Length() < 0.001 then
				weaponColor = defaultWeaponColor
			end
			ply:SetWeaponColor(weaponColor)
		end
		return
	end
end
do
	local TranslatePlayerHands, TranslateToPlayerModelName = player_manager.TranslatePlayerHands, player_manager.TranslateToPlayerModelName
	GM.PlayerSetHandsModel = function(self, ply, hands)
		local info = TranslatePlayerHands(TranslateToPlayerModelName(ply:GetModel()))
		if info == nil then
			return
		end
		hands:SetModel(info.model)
		hands:SetBodyGroups(info.body)
		hands:SetPlayerColor(ply:GetPlayerColor())
		hands:SetSkin(info.matchBodySkin and ply:GetSkin() or info.skin)
		return
	end
end
do
	local IsWaitingPlayers = Jailbreak.IsWaitingPlayers
	GM.DoPlayerDeath = function(self, ply, attacker, damageInfo)
		if not Teams[ply:Team()] then
			return
		end
		if attacker:IsValid() and attacker:IsPlayer() and attacker ~= ply then
			attacker:AddFrags(1)
		end
		if IsWaitingPlayers() then
			ply:RemoveRagdoll()
		end
		local ragdoll = ply:CreateRagdoll()
		if not ragdoll:IsValid() then
			return
		end
		Simple(0.25, function()
			if ragdoll:IsValid() and ply:IsValid() and not ply:Alive() then
				return ply:ObserveEntity(ragdoll)
			end
		end)
		if damageInfo:IsDissolveDamage() then
			ragdoll:Dissolve()
			return
		end
		ragdoll:TakeDamageInfo(damageInfo)
		return
	end
end
GM.PlayerDeath = function(self, ply, inflictor, attacker)
	local teamID = ply:Team()
	if Teams[teamID] then
		Run("TeamPlayerDeath", ply, teamID)
		return
	end
end
GM.PlayerSilentDeath = function(self, ply)
	local teamID = ply:Team()
	if Teams[teamID] then
		Run("TeamPlayerDeath", ply, teamID)
		return
	end
end
GM.PostPlayerDeath = function(self, ply)
	ply:AddDeaths(1)
	ply:ResetToggles()
	ply:Extinguish()
	ply:DropObject()
	return
end
do
	local OBS_MODE_NONE = OBS_MODE_NONE
	GM.PlayerDeathThink = function(self, ply)
		if Teams[ply:Team()] and not GameInProgress() then
			ply:Spawn()
			return
		end
		if ply:GetObserverMode() == OBS_MODE_NONE then
			ply:Spectate(OBS_MODE_ROAMING)
			return
		end
	end
end
do
	local IN_ATTACK, IN_ATTACK2, IN_USE = IN_ATTACK, IN_ATTACK2, IN_USE
	local Weld = constraint.Weld
	local TraceLine = util.TraceLine
	local Create = ents.Create
	local MovementKeys = {
		[IN_FORWARD] = true,
		[IN_BACK] = true,
		[IN_MOVELEFT] = true,
		[IN_MOVERIGHT] = true
	}
	local traceResult = { }
	local trace = {
		output = traceResult
	}
	GM.KeyPress = function(self, ply, key)
		if ply:Alive() then
			if key ~= IN_USE or ply:IsHoldingEntity() then
				return
			end
			Simple(0.05 + (ply:Ping() or 0) / 1000, function()
				if not (ply:IsValid() and ply:Alive()) or ply:KeyDown(IN_USE) or ply:IsHoldingEntity() then
					return
				end
				trace.filter = ply
				trace.start = ply:EyePos()
				trace.endpos = trace.start + ply:GetAimVector() * 72
				TraceLine(trace)
				if not traceResult.Hit then
					return
				end
				local entity = traceResult.Entity
				if not entity:IsValid() then
					return
				end
				if entity:IsRagdoll() then
					local physID = max(0, traceResult.PhysicsBone)
					local phys = entity:GetPhysicsObjectNum(physID)
					if not (phys and phys:IsValid() and phys:IsMoveable()) then
						return
					end
					local mover = Create("jb_ragdoll_mover")
					mover:SetPos(phys:LocalToWorld(phys:GetMassCenter()))
					mover.Ragdoll = entity
					mover:SetOwner(ply)
					mover:Spawn()
					mover.Weld = Weld(mover, entity, 0, physID, 0, true, true)
					return ply:PickupObject(mover)
				elseif entity:IsFood() then
					return ply:PickupObject(entity)
				end
			end)
			return
		end
		if MovementKeys[key] then
			if ply:GetObserverMode() ~= OBS_MODE_ROAMING then
				ply:ObserveEntity()
			end
			return
		end
		if key == IN_ATTACK then
			ply:MoveObserveIndex(1)
			return
		end
		if key == IN_ATTACK2 then
			ply:MoveObserveIndex(-1)
			return
		end
		if key == IN_JUMP then
			local target = ply:GetObserverTarget()
			if not (target:IsValid() and ((target:IsPlayer() and target:Alive()) or target:IsNPC())) then
				return
			end
			local observerMode = ply:GetObserverMode()
			if observerMode == OBS_MODE_CHASE then
				ply:Spectate(OBS_MODE_IN_EYE)
				ply:SetupHands(target)
				return
			end
			if observerMode == OBS_MODE_IN_EYE then
				ply:Spectate(OBS_MODE_CHASE)
				return
			end
		end
	end
end
do
	local IsRoundPreparing = Jailbreak.IsRoundPreparing
	GM.CanPlayerSuicide = function(self, ply)
		if IsRoundPreparing() then
			return false
		end
		return ply:Alive()
	end
end
do
	local CHAN_VOICE_BASE = CHAN_VOICE_BASE
	GM.PlayerDeathSound = function(self, ply)
		if ply:IsGuard() then
			ply:EmitSound("Player.Death", 75, random(80, 120), 1, CHAN_VOICE_BASE, 0, 1)
		end
		return true
	end
end
GM.PlayerDisconnected = function(self, ply)
	local teamID = ply:Team()
	if Teams[teamID] then
		return Run("TeamPlayerDisconnected", ply, teamID)
	end
end
do
	local Start, WriteUInt, WriteString, Send
	do
		local _obj_0 = net
		Start, WriteUInt, WriteString, Send = _obj_0.Start, _obj_0.WriteUInt, _obj_0.WriteString, _obj_0.Send
	end
	local CHAT_CONNECTED = CHAT_CONNECTED
	local SendChatText = Jailbreak.SendChatText
	GM.PlayerInitialized = function(self, ply)
		if ply:IsBot() then
			SendChatText(false, false, CHAT_CONNECTED, ply:GetModelColor(), ply:Nick())
			return
		end
		SendChatText(false, false, CHAT_CONNECTED, ply:GetModelColor(), ply:Nick(), ply:SteamID())
		local gameName = Jailbreak.GameName
		if not gameName then
			return
		end
		Start("Jailbreak::Networking")
		WriteUInt(0, 4)
		WriteString(gameName)
		return Send(ply)
	end
end
do
	local TeamIsJoinable = Jailbreak.TeamIsJoinable
	GM.PlayerCanJoinTeam = function(self, ply, teamID, oldTeamID)
		if teamID == oldTeamID then
			return false, "#jb.error.already-on-team", 3
		end
		if not TeamIsJoinable(teamID) then
			return false, "#jb.error.cant-do-that", 5
		end
		return true
	end
end
do
	local AllowSprayEveryone = Jailbreak.AllowSprayEveryone
	GM.PlayerSpray = function(self, ply)
		if not ply:Alive() then
			return true
		end
		if AllowSprayEveryone:GetBool() or ply:IsPrisoner() then
			return false
		end
		ply:SendNotify("#jb.error.cant-do-that", NOTIFY_ERROR, 2)
		return true
	end
end
do
	local MOVETYPE_WALK = MOVETYPE_WALK
	GM.PlayerShouldTaunt = function(self, ply)
		if ply:Alive() and ply:IsOnGround() and not (ply:Crouching() or ply:InVehicle()) and ply:GetMoveType() == MOVETYPE_WALK and ply:WaterLevel() < 2 then
			return true
		end
		ply:SendNotify("#jb.error.cant-do-that", NOTIFY_ERROR, 2)
		return false
	end
end
GM.AllowPlayerPickup = function(self, ply, entity)
	return ply:Alive() and not entity:IsFood()
end
GM.PlayerCanPickupItem = function(self, ply, entity)
	return ply:Alive()
end
GM.PlayerNoClip = function(self, ply, desiredState)
	if not desiredState then
		return true
	end
	return ply:IsSuperAdmin() and ply:Alive() and not ply:IsPlayingTaunt()
end
GM.PlayerSwitchFlashlight = function(self, ply, newState)
	if not newState then
		return true
	end
	return ply:Alive() and ply:CanUseFlashlight()
end
GM.PlayerUse = function(self, ply, entity)
	if not ply:Alive() then
		return
	end
	if ply:IsHoldingEntity() then
		return false
	end
	if entity:IsPlayer() then
		return false
	end
	local curTime, lastUseTime = CurTime(), ply.LastUseTime or 0
	ply.LastUseTime = curTime
	local className = entity:GetClass()
	local isReleased = (curTime - lastUseTime) > 0.025
	if not lastUseTime or isReleased then
		SetNW2Var(ply, "start-use-time", curTime)
		Run("PlayerHoldUse", ply, entity, 0)
	else
		local startUseTime = ply:GetNW2Int("start-use-time")
		if startUseTime ~= 0 and Run("PlayerHoldUse", ply, entity, curTime - startUseTime) == true then
			SetNW2Var(ply, "start-use-time", 0)
			return false
		end
	end
	if not isReleased then
		return
	end
	if Run("PlayerUsedEntity", ply, entity) == false then
		return false
	end
	if entity:IsWeapon() then
		if entity.m_bPickupForbidden then
			return false
		end
		if entity.IsTemporaryWeapon then
			entity = entity:GetParent()
			if not (entity:IsValid() and entity:IsWeapon()) then
				return false
			end
		end
		if ply:HasWeapon(className) then
			local clip1, clip1Type = entity:Clip1(), entity:GetPrimaryAmmoType()
			if clip1 > 0 and clip1Type >= 0 then
				local canPickup = min(clip1, ply:GetPickupAmmoCount(clip1Type))
				if canPickup > 0 then
					entity:SetClip1(clip1 - canPickup)
					ply:GiveAmmo(canPickup, clip1Type, false)
				end
			end
			local clip2, clip2Type = entity:Clip2(), entity:GetSecondaryAmmoType()
			if clip2 > 0 and clip2Type >= 0 then
				local canPickup = min(clip2, ply:GetPickupAmmoCount(clip2Type))
				if canPickup > 0 then
					entity:SetClip2(clip2 - canPickup)
					ply:GiveAmmo(canPickup, clip2Type, false)
				end
			end
			return false
		end
		local slot = entity:GetSlot()
		if slot > 0 and slot < 5 then
			if slot == 1 or slot == 4 then
				local weapons, length = ply:GetWeaponsInSlot(slot)
				if length ~= 0 then
					ply:DropWeapon(weapons[length])
				end
			else
				for i = 1, 2 do
					local weapons, length = ply:GetWeaponsInSlot(i + 1)
					if length ~= 0 then
						ply:DropWeapon(weapons[length])
					end
				end
			end
		end
		if Run("PlayerCanPickupWeapon", ply, entity) ~= false then
			ply:PickupWeapon(entity, false)
			return false
		end
	end
	return true
end
GM.OnEntityCreated = function(self, entity)
	if entity:IsPlayer() then
		Run("OnPlayerCreated", entity)
		return
	end
	local className = entity:GetClass()
	if className == "game_player_equip" then
		entity:Remove()
		return
	end
	if className == "func_button" then
		SetNW2Var(entity, "is-button", true)
		return
	end
	entity:AddToObserveTargets()
	if entity:IsWeapon() then
		Run("OnWeaponCreated", entity)
		return
	end
end
do
	local FreezeWeaponsOnSpawn = Jailbreak.FreezeWeaponsOnSpawn
	local FindInSphere = ents.FindInSphere
	GM.OnWeaponCreated = function(self, weapon)
		return Simple(0, function()
			if not weapon:IsValid() or weapon:GetOwner():IsValid() then
				return
			end
			local phys = weapon:GetPhysicsObject()
			if not (phys and phys:IsValid() and phys:IsMotionEnabled()) then
				return
			end
			local counter = 0
			local _list_0 = FindInSphere(weapon:GetPos(), 32)
			for _index_0 = 1, #_list_0 do
				local other = _list_0[_index_0]
				if other:IsWeapon() and not other:GetOwner():IsValid() then
					counter = counter + 1
					if counter >= 5 then
						if FreezeWeaponsOnSpawn:GetBool() then
							phys:EnableMotion(false)
						else
							phys:Sleep()
						end
						return
					end
				end
			end
		end)
	end
end
GM.EntityRemoved = function(self, entity, fullUpdate)
	if fullUpdate then
		return
	end
	if entity:IsValidObserveTarget() then
		entity:RemoveFromObserveTargets()
	end
	if entity.RagdollMover then
		local weld = entity.Weld
		if weld and weld:IsValid() then
			return weld:Remove()
		end
	end
end
do
	local AltrenativeWeapons = Jailbreak.AltrenativeWeapons
	local Iterator = ents.Iterator
	GM.MapInitialized = function(self)
		Jailbreak.HasMapWeapons = false
		for _, entity in Iterator() do
			if entity:IsWeapon() and AltrenativeWeapons[entity:GetClass()] ~= nil and not entity:GetOwner():IsValid() then
				Jailbreak.HasMapWeapons = true
				break
			end
		end
	end
end
GM.PlayerLoadout = function(self, ply)
	if not Jailbreak.HasMapWeapons and ply:IsGuard() then
		ply:GiveRandomWeapons(4)
	end
	ply:Give("jb_hands", false, true)
	return ply:SelectWeapon("jb_hands")
end
hook.Add("PlayerSpawn", "Jailbreak::AmmoControler", function(ply)
	ply.m_tGivedAmmo = nil
end)
GM.WeaponEquip = function(self, weapon, owner)
	local mult = (owner:IsGuard() or owner:IsEscaped()) and 1 or 0.25
	local givedAmmo = owner.m_tGivedAmmo
	if not givedAmmo then
		givedAmmo = { }
		owner.m_tGivedAmmo = givedAmmo
	end
	local primaryAmmoType = weapon:GetPrimaryAmmoType()
	if primaryAmmoType >= 0 and givedAmmo[primaryAmmoType] == nil then
		local amount = floor(owner:GetPickupAmmoCount(primaryAmmoType) * mult)
		if amount ~= 0 then
			owner:GiveAmmo(amount, primaryAmmoType, false)
			givedAmmo[primaryAmmoType] = true
		end
	end
	local secondaryAmmoType = weapon:GetSecondaryAmmoType()
	if secondaryAmmoType >= 0 and givedAmmo[secondaryAmmoType] == nil then
		local amount = floor(owner:GetPickupAmmoCount(secondaryAmmoType) * mult)
		if amount ~= 0 then
			owner:GiveAmmo(amount, secondaryAmmoType, false)
			givedAmmo[secondaryAmmoType] = true
		end
	end
end
GM.PlayerCanPickupWeapon = function(self, ply, weapon)
	if not ply:Alive() or ply:HasWeapon(weapon:GetClass()) then
		return false
	end
	local slot = weapon:GetSlot()
	if slot < 1 or slot > 4 then
		return true
	end
	if ply:HasWeaponsInSlot(slot) then
		return false
	end
	if slot == 1 or slot == 4 then
		return true
	end
	if ply:HasWeaponsInSlot(2) or ply:HasWeaponsInSlot(3) then
		return false
	end
	return true
end
GM.FinishMove = function(self, ply, mv)
	if ply:Alive() then
		ply.m_vLastVelocity = mv:GetVelocity()
	end
end
GM.OnPlayerPhysicsPickup = function(self, ply, entity)
	SetNW2Var(ply, "holding-entity", entity)
	entity.m_eHolder = ply
end
do
	local NULL = NULL
	GM.OnPlayerPhysicsDrop = function(self, ply, entity)
		SetNW2Var(ply, "holding-entity", NULL)
		entity.m_eHolder = nil
		ply:SetupMovement()
		return
	end
end
return hook.Add("EntityRemoved", "Jailbreak::PhysicsDropFix", function(entity)
	local holder = entity.m_eHolder
	if holder and holder:IsValid() and holder:IsPlayer() then
		Run("OnPlayerPhysicsDrop", holder, entity)
		return
	end
end)
