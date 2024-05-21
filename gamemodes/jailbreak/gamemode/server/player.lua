local ENTITY, PLAYER = ENTITY, PLAYER
local NOTIFY_UNDO = NOTIFY_UNDO
local Jailbreak = Jailbreak
local IsInWorld, IsValidModel, TraceLine = util.IsInWorld, util.IsValidModel, util.TraceLine
local vector_origin = vector_origin
local FixModelPath = Jailbreak.FixModelPath
local Add, Run = hook.Add, hook.Run
local Simple = timer.Simple
local Create = ents.Create
local OBS_MODE_ROAMING = OBS_MODE_ROAMING
local NULL = NULL
PLAYER.ChangeTeam = Jailbreak.ChangeTeam
local SetNW2Var = ENTITY.SetNW2Var
PLAYER.HasFlashlight = PLAYER.CanUseFlashlight
PLAYER.GiveFlashlight = function(ply, silent)
	if ply:HasFlashlight() then
		return false
	end
	if ply:FlashlightIsOn() then
		ply:Flashlight(false)
	end
	ply:AllowFlashlight(true)
	if not (ply:IsBot() or silent) then
		ply:SendPickupNotify("jb.flashlight")
	end
	return true
end
PLAYER.TakeFlashlight = function(ply, silent)
	if not ply:HasFlashlight() then
		return false
	end
	if ply:FlashlightIsOn() then
		ply:Flashlight(false)
	end
	ply:AllowFlashlight(false)
	if not (ply:IsBot() or silent) then
		ply:SendNotify("#jb.flashlight.lost", NOTIFY_UNDO, 5)
	end
	return true
end
PLAYER.GiveSecurityKeys = function(ply, silent)
	if ply:HasSecurityKeys() then
		return false
	end
	SetNW2Var(ply, "security-keys", true)
	if not (ply:IsBot() or silent) then
		ply:SendPickupNotify("jb.security.keys")
	end
	return true
end
PLAYER.TakeSecurityKeys = function(ply, silent)
	if not ply:HasSecurityKeys() then
		return false
	end
	SetNW2Var(ply, "security-keys", false)
	if not (ply:IsBot() or silent) then
		ply:SendNotify("#jb.security.keys.lost", NOTIFY_UNDO, 5)
	end
	return true
end
PLAYER.GiveSecurityRadio = function(ply, silent)
	if ply:HasSecurityRadio() then
		return false
	end
	SetNW2Var(ply, "security-radio", true)
	if not (ply:IsBot() or silent) then
		ply:SendPickupNotify("jb.walkie-talkie")
	end
	return true
end
PLAYER.TakeSecurityRadio = function(ply, silent)
	if not ply:HasSecurityRadio() then
		return false
	end
	SetNW2Var(ply, "security-radio", false)
	if not (ply:IsBot() or silent) then
		ply:SendNotify("#jb.walkie-talkie.lost", NOTIFY_UNDO, 5)
	end
	return true
end
do
	local setShockCollar
	setShockCollar = function(ply, bool, silent)
		bool = bool == true
		if bool == ply:ShockCollarIsEnabled() then
			return
		end
		SetNW2Var(ply, "shock-collar-enabled", bool)
		if not silent then
			Run("ShockCollarToggled", ply, bool)
		end
		return
	end
	PLAYER.SetShockCollar = setShockCollar
	PLAYER.GiveShockCollar = function(ply, silent)
		if ply:HasShockCollar() then
			return
		end
		SetNW2Var(ply, "shock-collar", true)
		setShockCollar(ply, false, true)
		if not (ply:IsBot() or silent) then
			ply:SendPickupNotify("jb.shock-collar")
		end
		return
	end
	PLAYER.TakeShockCollar = function(ply, silent)
		if ply:HasShockCollar() then
			setShockCollar(ply, false, true)
			SetNW2Var(ply, "shock-collar", false)
			if not (ply:IsBot() or silent) then
				ply:SendNotify("#jb.shock-collar.lost", NOTIFY_UNDO, 5)
			end
		end
		return
	end
end
do
	local setWarden
	setWarden = function(ply, bool, silent)
		bool = bool == true
		if bool == ply:IsWarden() then
			return
		end
		SetNW2Var(ply, "is-warden", bool)
		if not silent then
			Run("WardenChanged", ply, bool)
		end
		return
	end
	PLAYER.SetWarden = setWarden
	Add("PostPlayerDeath", "Jailbreak::WardenDeath", function(ply)
		setWarden(ply, false)
		return
	end)
end
do
	local allowFlight
	allowFlight = function(ply, bool)
		bool = bool == true
		if bool == false then
			SetNW2Var(ply, "in-flight", bool)
		end
		SetNW2Var(ply, "flight-allowed", bool)
		return
	end
	PLAYER.AllowFlight = allowFlight
	Add("PostPlayerDeath", "Jailbreak::DisallowFlight", function(ply)
		allowFlight(ply, false)
		return
	end)
end
do
	local PlayerSlowWalkSpeed, PlayerWalkSpeed, PlayerRunSpeed, PlayerJumpPower = Jailbreak.PlayerSlowWalkSpeed, Jailbreak.PlayerWalkSpeed, Jailbreak.PlayerRunSpeed, Jailbreak.PlayerJumpPower
	PLAYER.SetupMovement = function(ply)
		ply:SetSlowWalkSpeed(PlayerSlowWalkSpeed:GetInt())
		ply:SetWalkSpeed(PlayerWalkSpeed:GetInt())
		ply:SetRunSpeed(PlayerRunSpeed:GetInt())
		ply:SetJumpPower(PlayerJumpPower:GetInt())
		Run("SetupPlayerMovement", ply)
		return
	end
end
do
	local Start, WriteUInt, WriteTable, WriteString, WriteBool, WriteEntity, Send = net.Start, net.WriteUInt, net.WriteTable, net.WriteString, net.WriteBool, net.WriteEntity, net.Send
	PLAYER.PlaySound = function(ply, soundPath)
		Start("Jailbreak::Networking")
		WriteUInt(3, 4)
		WriteString(soundPath)
		Send(ply)
		return
	end
	PLAYER.SendPickupNotify = function(ply, itemName, pickupType, amount)
		Start("Jailbreak::Networking")
		WriteUInt(1, 4)
		WriteString(itemName)
		WriteUInt(pickupType or 0, 6)
		WriteUInt(amount or 1, 16)
		Send(ply)
		return
	end
	do
		util.AddNetworkString("Jailbreak::Shop")
		local ShopItems = Jailbreak.ShopItems
		local length = 0
		PLAYER.SendShopItems = function(ply)
			Start("Jailbreak::Shop")
			length = #ShopItems
			WriteUInt(length, 16)
			for index = 1, length do
				local item = ShopItems[index]
				if item ~= nil then
					WriteString(item.name)
					WriteString(item.model)
					WriteUInt(item.price, 16)
					WriteUInt(item.skin, 8)
					WriteString(item.bodygroups)
				end
			end
			Send(ply)
			return
		end
	end
	PLAYER.ResetToggles = function(ply)
		Start("Jailbreak::Networking")
		WriteUInt(5, 4)
		Send(ply)
		return
	end
	do
		local RecipientFilter = RecipientFilter
		local isfunction = isfunction
		PLAYER.AnimRestartNetworkedGesture = function(ply, slot, activity, autokill, finished, frac)
			local sequenceID = ply:SelectWeightedSequence(activity)
			if sequenceID < 0 then
				return
			end
			local rf = RecipientFilter()
			rf:AddPVS(ply:WorldSpaceCenter())
			if rf:GetCount() > 0 then
				Start("Jailbreak::Networking")
				WriteUInt(4, 4)
				WriteEntity(ply)
				WriteUInt(slot, 3)
				WriteUInt(activity, 11)
				WriteBool(autokill or false)
				Send(rf)
			end
			if isfunction(finished) then
				local duration = ply:SequenceDuration(sequenceID)
				Simple(duration - duration * (frac or 0), function()
					if ply:IsValid() then
						return finished(ply)
					end
				end)
			end
			ply:AnimRestartGesture(slot, activity, autokill)
			return
		end
	end
	do
		local sounds = {
			[NOTIFY_GENERIC] = "buttons/button9.wav",
			[NOTIFY_ERROR] = "player/suit_denydevice.wav",
			[NOTIFY_HINT] = "buttons/button9.wav",
			[NOTIFY_CLEANUP] = "buttons/button6.wav",
			[NOTIFY_UNDO] = "buttons/button9.wav"
		}
		PLAYER.SendNotify = function(ply, text, typeID, length, ...)
			Start("Jailbreak::Networking")
			WriteUInt(2, 4)
			WriteString(text)
			WriteTable({
				...
			}, true)
			WriteUInt(typeID, 3)
			WriteUInt(length, 16)
			Send(ply)
			local soundPath = sounds[typeID]
			if soundPath ~= nil then
				ply:PlaySound(soundPath)
			end
			return
		end
	end
end
PLAYER.ObserveEntity = function(ply, entity)
	if ply:Alive() then
		return
	end
	if entity and entity:IsValid() then
		ply:Spectate(OBS_MODE_CHASE)
		ply:SpectateEntity(entity)
		return
	end
	local eyeAngles = ply:EyeAngles()
	ply:SpectateEntity()
	ply:Spectate(OBS_MODE_ROAMING)
	ply:SetEyeAngles(eyeAngles)
	return
end
do
	local ObserveTargets = Jailbreak.ObserveTargets
	local index, length = 0, 0
	PLAYER.MoveObserveIndex = function(ply, step, players)
		length = #ObserveTargets
		if length == 0 then
			return
		end
		index = (ply.m_iLastSpectatedIndex or 0) + step
		if index > length then
			index = 1
		elseif index < 1 then
			index = length
		end
		local entity = ObserveTargets[index]
		if not entity:IsValid() then
			if ply:GetObserverMode() ~= OBS_MODE_ROAMING then
				ply:Spectate(OBS_MODE_ROAMING)
			end
			ply.m_iLastSpectatedIndex = 0
			return
		end
		ply.m_iLastSpectatedIndex = index
		if entity:IsPlayer() or entity:IsRagdoll() then
			ply:ObserveEntity(entity)
			return
		end
		if ply:GetObserverMode() ~= OBS_MODE_ROAMING then
			ply:Spectate(OBS_MODE_ROAMING)
		end
		local angles = entity:GetAngles()
		angles[3] = 0
		ply:SetEyeAngles(angles)
		ply:SetPos(entity:GetPos())
		return
	end
end
PLAYER.UsingMegaphone = function(ply)
	return ply:IsWarden() and ply:Alive() and ply:GetInfo("jb_megaphone") == "1"
end
do
	local white = Color(255, 255, 255, 240)
	local CurTime = CurTime
	local IN = SCREENFADE.IN
	PLAYER.ShockScreenEffect = function(ply, time, color, fadeTime, blockMovement)
		if blockMovement ~= false then
			SetNW2Var(ply, "shock-time", CurTime() + (time or 3))
		end
		ply:ScreenFade(IN, color or white, fadeTime or 0.25, time or 3)
		return
	end
end
do
	local WeaponHandlers = WeaponHandlers or { }
	PLAYER.Give = function(ply, className, noAmmo, force)
		local handler = WeaponHandlers[className]
		if handler then
			className = handler.Alternative or className
		end
		if ply:HasWeapon(className) then
			return NULL
		end
		local weapon = Create(className)
		if not (weapon and weapon:IsValid()) then
			return NULL
		end
		weapon:SetAngles(ply:GetAngles())
		weapon:SetPos(ply:GetPos())
		weapon:Spawn()
		weapon:Activate()
		if not weapon:IsWeapon() then
			return weapon
		end
		if not force and Run("PlayerCanPickupWeapon", ply, weapon) == false then
			weapon:Remove()
			return NULL
		end
		if noAmmo then
			weapon:SetClip1(0)
			weapon:SetClip2(0)
		end
		ply:PickupWeapon(weapon, false)
		return weapon
	end
end
PLAYER.SetMutedByWarden = function(ply, state)
	return SetNW2Var(ply, "warden-mute", state ~= false)
end
PLAYER.RemoveRagdoll = function(ply)
	local ragdoll = ply:GetRagdollEntity()
	if ragdoll and ragdoll:IsValid() then
		ragdoll:Remove()
	end
	return
end
do
	local ceil = math.ceil
	PLAYER.Heal = function(ply, frac)
		local amount = ceil(ply:GetMaxHealth() * (frac or 1))
		ply:SetHealth(amount)
		return amount
	end
end
do
	local max = math.max
	PLAYER.AddHealth = function(ply, amount)
		amount = max(ply:GetHealth() + amount, ply:GetMaxHealth())
		ply:SetHealth(amount)
		return amount
	end
	PLAYER.TakeHealth = function(ply, amount)
		amount = max(0, ply:GetHealth() - amount)
		ply:SetHealth(amount)
		return amount
	end
end
PLAYER.CreateClientsideRagdoll = PLAYER.CreateClientsideRagdoll or PLAYER.CreateRagdoll
local COLLISION_GROUP_PASSABLE_DOOR = COLLISION_GROUP_PASSABLE_DOOR
do
	local RagdollRemove, RagdollHealth, IsRoundPreparing, DropActiveWeaponOnDeath = Jailbreak.RagdollRemove, Jailbreak.RagdollHealth, Jailbreak.IsRoundPreparing, Jailbreak.DropActiveWeaponOnDeath
	Add("PlayerCanCreateRagdoll", "Jailbreak::NoRagdollsOnPreparing", function()
		if IsRoundPreparing() then
			return false
		end
	end)
	local traceResult = { }
	local trace = {
		output = traceResult
	}
	PLAYER.CreateRagdoll = function(ply, putItems)
		putItems = putItems ~= false
		if Run("PlayerCanCreateRagdoll", ply, putItems) == false then
			return NULL
		end
		if RagdollRemove:GetBool() then
			ply:RemoveRagdoll()
		end
		local spawnOrigin = ply:GetPos()
		if not IsInWorld(spawnOrigin) then
			return NULL
		end
		local modelPath = ply:GetModel()
		if not modelPath then
			return NULL
		end
		modelPath = FixModelPath(modelPath)
		if not IsValidModel(modelPath) then
			return NULL
		end
		local ragdoll = Create(ply:GetBoneCount() > 1 and "prop_ragdoll" or "prop_physics")
		ragdoll:SetAngles(ply:GetAngles())
		ragdoll:SetModel(modelPath)
		ragdoll:SetPos(spawnOrigin)
		ragdoll:Spawn()
		ragdoll:SetHealth(RagdollHealth:GetInt())
		ragdoll:SetMaxHealth(ragdoll:Health())
		ragdoll:SetTeam(ply:Team())
		if ply:Alive() then
			ragdoll:SetAlive(true)
			ragdoll.MaxArmor = ply:GetMaxArmor()
			ragdoll.Armor = ply:Armor()
			local angles = ply:EyeAngles()
			angles[1], angles[3] = 0, 0
			ragdoll.PlayerAngles = angles
		end
		local _list_0 = ply:GetBodyGroups()
		for _index_0 = 1, #_list_0 do
			local bodygroup = _list_0[_index_0]
			ragdoll:SetBodygroup(bodygroup.id, ply:GetBodygroup(bodygroup.id))
		end
		ragdoll:SetFlexScale(ply:GetFlexScale())
		for flexID = 0, ply:GetFlexNum() do
			ragdoll:SetFlexWeight(flexID, ply:GetFlexWeight(flexID))
		end
		ragdoll:SetPlayerColor(ply:GetPlayerColor())
		ragdoll:SetModelScale(ply:GetModelScale())
		ragdoll:SetMaterial(ply:GetMaterial())
		ragdoll:SetColor(ply:GetColor())
		ragdoll:SetSkin(ply:GetSkin())
		for index = 1, #ply:GetMaterials() do
			local materialPath = ply:GetSubMaterial(index)
			if materialPath and #materialPath ~= 0 then
				ragdoll:SetSubMaterial(index, materialPath)
			end
		end
		ragdoll:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
		SetNW2Var(ragdoll, "is-player-ragdoll", true)
		SetNW2Var(ply, "player-ragdoll", ragdoll)
		SetNW2Var(ragdoll, "ragdoll-owner", ply)
		if not ply:IsBot() then
			SetNW2Var(ragdoll, "owner-steamid64", ply:SteamID64())
		end
		SetNW2Var(ragdoll, "owner-nickname", ply:Nick())
		for bone = 0, ply:GetBoneCount() - 1 do
			ragdoll:ManipulateBonePosition(bone, ply:GetManipulateBonePosition(bone))
			ragdoll:ManipulateBoneAngles(bone, ply:GetManipulateBoneAngles(bone))
			ragdoll:ManipulateBoneJiggle(bone, ply:GetManipulateBoneJiggle(bone))
			ragdoll:ManipulateBoneScale(bone, ply:GetManipulateBoneScale(bone))
		end
		if ragdoll:IsRagdoll() then
			local velocity = ply.m_vLastVelocity
			for physNum = 0, ragdoll:GetPhysicsObjectCount() - 1 do
				local phys = ragdoll:GetPhysicsObjectNum(physNum)
				if not (phys and phys:IsValid()) then
					goto _continue_0
				end
				local bone = ragdoll:TranslatePhysBoneToBone(physNum)
				if bone < 0 then
					goto _continue_0
				end
				local origin, angles = ply:GetBonePosition(bone)
				if origin then
					phys:SetAngles(angles)
					if not IsInWorld(origin) then
						goto _continue_0
					end
					trace.start = origin
					trace.endpos = origin
					trace.filter = {
						ragdoll,
						ply
					}
					TraceLine(trace)
					if traceResult.Hit then
						goto _continue_0
					end
					phys:SetPos(origin)
				end
				phys:SetVelocity(velocity)
				phys:Wake()
				::_continue_0::
			end
		else
			local phys = ragdoll:GetPhysicsObject()
			if phys and phys:IsValid() then
				phys:SetVelocity(ply.m_vLastVelocity)
				phys:Wake()
			end
		end
		if ply:IsOnFire() then
			ragdoll:Ignite(5, 64)
			ply:Extinguish()
		end
		Run("PlayerRagdollCreated", ply, ragdoll)
		if putItems then
			local boolean = DropActiveWeaponOnDeath:GetBool()
			if boolean then
				ply:DropWeapon()
			end
			boolean = ply:HasSecurityRadio()
			ragdoll.HasSecurityRadio = boolean
			if boolean then
				ply:TakeSecurityRadio()
			end
			boolean = ply:HasSecurityKeys()
			ragdoll.HasSecurityKeys = boolean
			if boolean then
				ply:TakeSecurityKeys()
			end
			boolean = ply:CanUseFlashlight()
			ragdoll.HasFlashlight = boolean
			if boolean then
				ply:TakeFlashlight()
			end
			boolean = ply:HasShockCollar()
			ragdoll.HasShockCollar = boolean
			if boolean then
				ply:TakeShockCollar()
			end
			local weapons, length = { }, 0
			local _list_1 = ply:GetWeapons()
			for _index_0 = 1, #_list_1 do
				local weapon = _list_1[_index_0]
				if #weapon:GetWeaponWorldModel() == 0 then
					goto _continue_1
				end
				ply:DropWeapon(weapon)
				if not weapon:IsValid() then
					goto _continue_1
				end
				weapon.m_bPickupForbidden = true
				weapon:SetPos(spawnOrigin)
				weapon:SetParent(ragdoll)
				weapon:SetNotSolid(true)
				weapon:SetNoDraw(true)
				length = length + 1
				weapons[length] = weapon
				::_continue_1::
			end
			if length ~= 0 then
				ragdoll.Weapons = weapons
			end
			ragdoll.Ammo = ply:GetAmmo()
			ply:RemoveAllAmmo()
		end
		ragdoll:AddToObserveTargets()
		return ragdoll
	end
end
do
	local Shuffle = table.Shuffle
	local min = math.min
	local pairs = pairs
	PLAYER.LootRagdoll = function(ply, ragdoll)
		local velocity = vector_origin
		local direction = ply:EyePos() - ragdoll:WorldSpaceCenter()
		direction:Normalize()
		if ragdoll.HasFlashlight and not ply:HasFlashlight() then
			ragdoll.HasFlashlight = nil
			velocity = velocity + (direction * 150)
			ply:GiveFlashlight()
		end
		if ragdoll.HasSecurityKeys and not ply:HasSecurityKeys() then
			ragdoll.HasSecurityKeys = nil
			velocity = velocity + (direction * 50)
			ply:GiveSecurityKeys()
		end
		if ragdoll.HasSecurityRadio and not ply:HasSecurityRadio() then
			ragdoll.HasSecurityRadio = nil
			velocity = velocity + (direction * 50)
			ply:GiveSecurityRadio()
		end
		local Weapons = ragdoll.Weapons
		if Weapons ~= nil then
			local spawnOrigin = ply:WorldSpaceCenter()
			local weapon = NULL
			for index = 1, #Weapons do
				weapon = Weapons[index]
				if not weapon:IsValid() or weapon:GetOwner():IsValid() or weapon:GetParent() ~= ragdoll then
					goto _continue_0
				end
				weapon:SetParent()
				weapon:SetNoDraw(false)
				weapon:SetNotSolid(false)
				weapon.m_bPickupForbidden = nil
				if Run("PlayerCanPickupWeapon", ply, weapon) == false then
					weapon:SetPos(spawnOrigin)
				else
					ply:PickupWeapon(weapon)
				end
				velocity = velocity + (direction * 200)
				::_continue_0::
			end
			ragdoll.Weapons = nil
		end
		local Ammo = ragdoll.Ammo
		if Ammo ~= nil then
			local count, amount = 0, 0
			for ammoType, ammoCount in pairs(Ammo) do
				amount = min(ammoCount, ply:GetPickupAmmoCount(ammoType))
				if amount < 1 then
					goto _continue_1
				end
				ply:GiveAmmo(amount, ammoType)
				velocity = velocity + (direction * 100)
				ammoCount = ammoCount - amount
				if ammoCount > 0 then
					Ammo[ammoType] = ammoCount
					count = count + 1
				else
					Ammo[ammoType] = nil
				end
				::_continue_1::
			end
			if count == 0 then
				ragdoll.Ammo = nil
			end
		end
		if velocity:Length() < 100 then
			return
		end
		if ragdoll:IsRagdoll() then
			local physParts, length = { }, 0
			for physNum = 1, ragdoll:GetPhysicsObjectCount() - 1 do
				local phys = ragdoll:GetPhysicsObjectNum(physNum)
				if phys and phys:IsValid() then
					length = length + 1
					physParts[length] = phys
				end
			end
			Shuffle(physParts)
			for index = 1, min(length, 6) do
				physParts[index]:ApplyForceCenter(velocity)
			end
		else
			local phys = ragdoll:GetPhysicsObject()
			if phys and phys:IsValid() then
				phys:ApplyForceCenter(velocity)
			end
		end
		Run("PlayerLootedRagdoll", ply, ragdoll)
		return
	end
end
do
	local angle_zero = angle_zero
	local Clamp = math.Clamp
	PLAYER.SpawnFromRagdoll = function(ply, ragdoll, ignoreHealth)
		if ply:Team() ~= ragdoll:Team() then
			ply:SetTeam(ragdoll:Team())
		end
		if not ragdoll:Alive() then
			if ply:Alive() then
				ply:KillSilent()
			end
			Simple(0, function()
				if ply:IsValid() and ply:Alive() then
					ply:ObserveEntity(ragdoll)
					return
				end
			end)
			return false
		end
		ply:SetModel(ragdoll:GetModel())
		ply:SetPos(ragdoll:WorldSpaceCenter())
		ply:SetEyeAngles(ragdoll.PlayerAngles or angle_zero)
		if ignoreHealth ~= true then
			ply:SetHealth(ply:GetMaxHealth() * Clamp(ragdoll:Health() - (ragdoll:GetMaxHealth() * 0.75) / (ragdoll:GetMaxHealth() * 0.25), 0, 1))
			ply:SetArmor(ply:GetMaxArmor() * ((ragdoll.Armor or 0) / (ragdoll.MaxArmor or 100)))
		end
		ply:SetPlayerColor(ragdoll:GetPlayerColor())
		ply:SetModelScale(ragdoll:GetModelScale())
		ply:SetMaterial(ragdoll:GetMaterial())
		ply:SetColor(ragdoll:GetColor())
		ply:SetSkin(ragdoll:GetSkin())
		local _list_0 = ply:GetBodyGroups()
		for _index_0 = 1, #_list_0 do
			local bodygroup = _list_0[_index_0]
			ply:SetBodygroup(bodygroup.id, ragdoll:GetBodygroup(bodygroup.id))
		end
		for index = 1, #ply:GetMaterials() do
			local materialPath = ragdoll:GetSubMaterial(index)
			if materialPath ~= "" then
				ply:SetSubMaterial(index, materialPath)
			end
		end
		if ragdoll:IsOnFire() then
			ragdoll:Extinguish()
			ply:Ignite(5, 16)
		end
		for bone = 0, ply:GetBoneCount() - 1 do
			ply:ManipulateBonePosition(bone, ragdoll:GetManipulateBonePosition(bone))
			ply:ManipulateBoneAngles(bone, ragdoll:GetManipulateBoneAngles(bone))
			ply:ManipulateBoneJiggle(bone, ragdoll:GetManipulateBoneJiggle(bone))
			ply:ManipulateBoneScale(bone, ragdoll:GetManipulateBoneScale(bone))
		end
		if ragdoll:IsRagdoll() then
			local velocity = vector_origin
			local count = ragdoll:GetPhysicsObjectCount()
			for physNum = 0, count - 1 do
				local phys = ragdoll:GetPhysicsObjectNum(physNum)
				if phys and phys:IsValid() then
					velocity = velocity + phys:GetVelocity()
				end
			end
			velocity = velocity / count
			ply:SetVelocity(velocity)
		else
			local phys = ragdoll:GetPhysicsObject()
			if phys and phys:IsValid() then
				ply:SetVelocity(phys:GetVelocity())
			end
		end
		if ragdoll.HasShockCollar then
			ragdoll.HasShockCollar = nil
			ply:GiveShockCollar()
		end
		ply:Give("jb_hands", false, true)
		ply:LootRagdoll(ragdoll)
		return true
	end
end
Add("PlayerSelectSpawn", "Jailbreak::AliveRagdoll", function(ply)
	local ragdoll = ply:GetRagdollEntity()
	if ragdoll and ragdoll:IsValid() and ragdoll:Alive() then
		return ragdoll
	end
end)
PLAYER.SetLoseConsciousness = function(ply, state)
	if state then
		local ragdoll = ply:CreateRagdoll(true)
		if ragdoll:IsValid() then
			ply:DropObject()
			ply:SetMoveType(MOVETYPE_NONE)
			ply:DrawWorldModel(false)
			ply:SetNoDraw(true)
			ply:SetNotSolid(true)
			ply:SetCollisionGroup(12)
			SetNW2Var(ply, "lost-consciousness", true)
		end
		return
	end
	local ragdoll = ply:GetRagdollEntity()
	if ragdoll:IsValid() and ragdoll:Alive() then
		SetNW2Var(ply, "lost-consciousness", false)
		ply:SpawnFromRagdoll(ragdoll, true, true)
		ply:SetNoDraw(false)
		ply:DrawWorldModel(true)
		ply:SetCollisionGroup(5)
		ply:SetNotSolid(false)
		ply:SetMoveType(MOVETYPE_WALK)
		ragdoll:SetAlive(false)
		ragdoll:Remove()
	end
	return
end
Add("PostPlayerDeath", "Jailbreak::LostConsciousness", function(ply)
	SetNW2Var(ply, "lost-consciousness", false)
	return
end)
do
	local traceResultDown, traceResultUp = { }, { }
	local trace = { }
	local fixupProp
	fixupProp = function(ply, entity, origin, mins, maxs)
		local downEndPos, upEndPos = entity:LocalToWorld(mins), entity:LocalToWorld(maxs)
		trace.filter = {
			entity,
			ply
		}
		trace.start = origin
		trace.endpos = downEndPos
		trace.output = traceResultDown
		TraceLine(trace)
		trace.start = origin
		trace.endpos = upEndPos
		trace.output = traceResultUp
		TraceLine(trace)
		if traceResultUp.Hit and traceResultDown.Hit then
			return
		end
		if traceResultDown.Hit then
			entity:SetPos(origin + (traceResultDown.HitPos - downEndPos))
		end
		if traceResultUp.Hit then
			entity:SetPos(origin + (traceResultUp.HitPos - upEndPos))
		end
		return
	end
	local tryFixPosition
	tryFixPosition = function(ply, entity, origin)
		local mins, maxs = entity:GetCollisionBounds()
		mins[2], mins[3] = 0, 0
		maxs[2], maxs[3] = 0, 0
		fixupProp(ply, entity, origin, mins, maxs)
		mins, maxs = entity:GetCollisionBounds()
		mins[1], mins[3] = 0, 0
		maxs[1], maxs[3] = 0, 0
		fixupProp(ply, entity, origin, mins, maxs)
		mins, maxs = entity:GetCollisionBounds()
		mins[1], mins[2] = 0, 0
		maxs[1], maxs[2] = 0, 0
		fixupProp(ply, entity, origin, mins, maxs)
		return
	end
	PLAYER.SpawnEntity = function(ply, className, preSpawn)
		trace.start = ply:GetShootPos()
		if not IsInWorld(trace.start) then
			return NULL
		end
		local entity = Create(className)
		if not (entity and entity:IsValid()) then
			return NULL
		end
		trace.endpos = trace.start + (ply:GetAimVector() * 128)
		trace.output = traceResultDown
		trace.filter = ply
		TraceLine(trace)
		local origin = traceResultDown.HitPos
		entity:SetTeam(ply:Team())
		entity:SetPos(origin)
		entity:SetCreator(ply)
		local angles = ply:EyeAngles()
		angles[1] = 0
		local _update_0 = 2
		angles[_update_0] = angles[_update_0] + 180
		angles[3] = 0
		entity:SetAngles(angles)
		if preSpawn ~= nil then
			preSpawn(entity, ply)
		end
		entity:Spawn()
		entity:Activate()
		origin = entity:NearestPoint(origin - (traceResultDown.HitNormal * entity:OBBMins()))
		entity:SetPos(origin)
		tryFixPosition(ply, entity, origin)
		entity:PhysWake()
		return entity
	end
end
do
	local PrecacheModel = util.PrecacheModel
	local SetModel = ENTITY.SetModel
	PLAYER.SetModel = function(ply, modelPath)
		modelPath = FixModelPath(modelPath)
		if IsValidModel(modelPath) then
			PrecacheModel(modelPath)
			SetModel(ply, modelPath)
			Run("PlayerModelChanged", ply, modelPath)
			ply:SetupHands()
			return true
		end
		return false
	end
end
do
	local GetNW2Int = ENTITY.GetNW2Int
	PLAYER.GetSpawnTime = function(ply)
		return GetNW2Int(ply, "spawn-time")
	end
	PLAYER.GetAliveTime = function(ply)
		return CurTime() - GetNW2Int(ply, "spawn-time")
	end
end
do
	local AvaliableWeapons = Jailbreak.AvaliableWeapons
	local Random = table.Random
	local Give, HasWeapon = PLAYER.Give, PLAYER.HasWeapon
	PLAYER.GiveRandomWeapons = function(ply, count, force)
		if not count then
			count = 4
		end
		local gived = { }
		for i = 1, count * 2 do
			if count == 0 then
				break
			end
			local className = Random(AvaliableWeapons, true)
			if HasWeapon(ply, className) or gived[className] == true then
				goto _continue_0
			end
			if Give(ply, className, false, force):IsValid() then
				gived[className] = true
				count = count - 1
			end
			::_continue_0::
		end
		return count == 0
	end
end
PLAYER.SetEscaped = function(ply, state)
	SetNW2Var(ply, "escaped", state == true)
	return
end
return Add("PostPlayerDeath", "Jailbreak::Escape", function(ply)
	SetNW2Var(ply, "escaped", false)
	return
end)
