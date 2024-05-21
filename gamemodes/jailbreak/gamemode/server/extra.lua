local ENTITY, PLAYER = ENTITY, PLAYER
local Jailbreak = Jailbreak
local Clamp, Rand, random, min, max, floor
do
	local _obj_0 = math
	Clamp, Rand, random, min, max, floor = _obj_0.Clamp, _obj_0.Rand, _obj_0.random, _obj_0.min, _obj_0.max, _obj_0.floor
end
local IsValid, GetNW2Var, SetNW2Var = ENTITY.IsValid, ENTITY.GetNW2Var, ENTITY.SetNW2Var
local FixModelPath = Jailbreak.FixModelPath
local Alive, IsBot = PLAYER.Alive, PLAYER.IsBot
local IsValidModel = util.IsValidModel
local Simple = timer.Simple
local Add = hook.Add
Add("PlayerPostThink", "Jailbreak::SecurityRadio", function(self)
	if Alive(self) and not IsBot(self) then
		local state = self:HasSecurityRadio() and self:GetInfo("jb_security_radio") == "1"
		if state == GetNW2Var(self, "using-security-radio") then
			return
		end
		return SetNW2Var(self, "using-security-radio", state)
	end
end, PRE_HOOK)
Simple(0, function()
	local Call = hook.Call
	local _list_0 = engine.GetAddons()
	for _index_0 = 1, #_list_0 do
		local addon = _list_0[_index_0]
		if addon.downloaded and addon.mounted then
			Call("WorkshopItemFound", nil, addon.wsid)
		end
	end
end)
if EntityReplacer ~= nil then
	local lower, find
	do
		local _obj_0 = string
		lower, find = _obj_0.lower, _obj_0.find
	end
	local isstring = isstring
	local istable = istable
	ReplaceFilterByModel = function(modelName)
		if isstring(modelName) then
			modelName = lower(modelName)
		elseif istable(modelName) then
			local tbl = { }
			for _index_0 = 1, #modelName do
				local str = modelName[_index_0]
				tbl[lower(str)] = true
			end
			modelName = tbl
		else
			return function(self)
				return true
			end
		end
		return function(self)
			local modelPath = self:GetModel()
			if not modelPath then
				return false
			end
			modelPath = FixModelPath(modelPath)
			if not IsValidModel(modelPath) then
				return false
			end
			if istable(modelName) then
				return modelName[modelPath]
			end
			return find(modelPath, modelName, 1, false) ~= nil
		end
	end
	Add("WorkshopItemFound", "Jailbreak::sent_soccerball - Replace", function(wsid)
		if wsid ~= "293904092" then
			return
		end
		EntityReplacer("^prop_physics.*", "sent_soccerball", ReplaceFilterByModel("models/props_phx/misc/soccerball%.mdl"))
		return
	end)
end
Add("WorkshopItemFound", "Jailbreak::sent_soccerball - Shop", function(wsid)
	if wsid ~= "293904092" then
		return
	end
	return Add("ShopItems", "Jailbreak::sent_soccerball", function(add)
		add("sent_soccerball", "models/props_phx/misc/soccerball.mdl", 10, function(self)
			return IsValid(self:SpawnEntity("sent_soccerball"))
		end)
		return
	end)
end)
Add("WorkshopItemFound", "Jailbreak::sent_grapplehook_bpack - Shop", function(wsid)
	if wsid ~= "931448005" then
		return
	end
	return Add("ShopItems", "Jailbreak::sent_grapplehook_bpack", function(add)
		add("sent_grapplehook_bpack", "models/props_phx/wheels/magnetic_small.mdl", 25, function(self)
			local entity = self:SpawnEntity("sent_grapplehook_bpack", function(self)
				return self:SetSlotName("movement")
			end)
			if IsValid(entity) then
				entity:SetKey(KEY_B)
				return true
			end
			return false
		end)
		return
	end)
end)
Add("WorkshopItemFound", "Jailbreak::sent_jetpack - Shop", function(wsid)
	if wsid ~= "931376012" then
		return
	end
	return Add("ShopItems", "Jailbreak::sent_jetpack", function(add)
		add("sent_jetpack", "models/thrusters/jetpack.mdl", 30, function(self)
			return IsValid(self:SpawnEntity("sent_jetpack", function(self)
				return self:SetSlotName("movement")
			end))
		end)
		return
	end)
end)
Add("WorkshopItemFound", "Jailbreak::mediaplayer_tv - Shop", function(wsid)
	if wsid ~= "546392647" then
		return
	end
	return Add("ShopItems", "Jailbreak::mediaplayer_tv", function(add)
		add("mediaplayer_tv", "models/gmod_tower/suitetv_large.mdl", 45, function(self)
			local entity = self:SpawnEntity("mediaplayer_tv")
			if IsValid(entity) then
				local phys = entity:GetPhysicsObject()
				if phys and phys:IsValid() then
					phys:EnableMotion(true)
					phys:SetMass(35)
					phys:Wake()
				end
				return true
			end
			return false
		end)
		return
	end)
end)
do
	local foodModels = Jailbreak.FoodModels
	if not foodModels then
		foodModels = {
			"models/food/burger.mdl",
			"models/food/hotdog.mdl",
			"models/props_c17/doll01.mdl",
			"models/props_junk/garbage_glassbottle001a.mdl",
			"models/props_junk/garbage_glassbottle002a.mdl",
			"models/props_junk/garbage_glassbottle003a.mdl",
			"models/props_junk/garbage_milkcarton002a.mdl",
			"models/props_junk/garbage_milkcarton001a.mdl",
			"models/props_junk/garbage_plasticbottle003a.mdl",
			"models/props_junk/garbage_takeoutcarton001a.mdl",
			"models/props_junk/GlassBottle01a.mdl",
			"models/props_junk/glassjug01.mdl",
			"models/props_junk/watermelon01.mdl",
			"models/props_junk/Shoe001a.mdl",
			"models/props/CS_militia/bottle01.mdl",
			"models/props/CS_militia/bottle02.mdl",
			"models/props/CS_militia/bottle03.mdl",
			"models/props/cs_office/Snowman_nose.mdl",
			"models/props/cs_office/trash_can_p8.mdl",
			"models/props/cs_office/Water_bottle.mdl",
			"models/props/cs_italy/bananna.mdl",
			"models/props/cs_italy/bananna_bunch.mdl",
			"models/props/cs_italy/banannagib1.mdl",
			"models/props/cs_italy/banannagib2.mdl",
			"models/props/cs_italy/orange.mdl",
			"models/props/cs_italy/orangegib1.mdl",
			"models/props/cs_italy/orangegib2.mdl",
			"models/props/cs_italy/orangegib3.mdl",
			"models/props/de_inferno/crate_fruit_break_gib1.mdl",
			"models/props/de_inferno/crate_fruit_break_gib2.mdl",
			"models/props/de_inferno/crate_fruit_break_gib3.mdl",
			"models/props/de_inferno/goldfish.mdl"
		}
		Jailbreak.FoodModels = foodModels
	end
	Add("PostGamemodeLoaded", "Jailbreak::LoadFoodModels", function()
		for index = 1, #foodModels do
			foodModels[index] = FixModelPath(foodModels[index])
		end
	end)
	local cache = { }
	Jailbreak.IsFoodModel = function(modelName)
		if not modelName then
			return false
		end
		local cached = cache[modelName]
		if cached ~= nil then
			return cached
		end
		local fixedModelPath = FixModelPath(modelName)
		if not IsValidModel(fixedModelPath) then
			cache[modelName] = false
			return false
		end
		for _index_0 = 1, #foodModels do
			local modelPath = foodModels[_index_0]
			if fixedModelPath == modelPath then
				cache[modelName] = true
				return true
			end
		end
	end
end
do
	local foodEatingSound = Sound("player/eating.wav")
	local IsFoodModel, FoodEatingTime = Jailbreak.IsFoodModel, Jailbreak.FoodEatingTime
	local CHAN_STATIC = CHAN_STATIC
	Add("OnEntityCreated", "Jailbreak::FoodEntities", function(self)
		if not self:IsProp() then
			return
		end
		return Simple(0, function()
			if IsValid(self) and IsFoodModel(self:GetModel()) then
				return SetNW2Var(self, "is-food", true)
			end
		end)
	end)
	local cache = { }
	Add("PlayerHoldUse", "Jailbreak::FoodEating", function(self, entity, useTime)
		if useTime < FoodEatingTime:GetFloat() or not entity:IsProp() then
			return
		end
		local modelPath = entity:GetModel()
		if not IsFoodModel(modelPath) then
			return
		end
		local healing = cache[modelPath]
		if not healing then
			local mins, maxs = entity:GetCollisionBounds()
			healing = Clamp(mins:Distance(maxs) / 64, 0, 1)
			cache[modelPath] = healing
		end
		local maxHealth = self:GetMaxHealth()
		self:SetHealth(Clamp(self:Health() + floor(maxHealth * healing), 0, maxHealth))
		self:EmitSound(foodEatingSound, 50, random(80, 120), Rand(0.6, 1), CHAN_STATIC, 0, 1)
		entity:Remove()
		return true
	end)
end
do
	local lootSound = Sound("npc/footsteps/softshoe_generic6.wav")
	local RagdollLootingTime = Jailbreak.RagdollLootingTime
	Add("PlayerHoldUse", "Jailbreak::RagdollLooting", function(self, entity, useTime)
		if useTime < RagdollLootingTime:GetFloat() then
			return
		end
		if not (entity:IsPlayerRagdoll() or entity:IsRagdoll()) then
			return
		end
		entity:EmitSound(lootSound, 60, random(80, 120), Rand(0.7, 1), CHAN_STATIC, 0, 1)
		self:LootRagdoll(entity)
		return true
	end)
end
do
	local GESTURE_SLOT_CUSTOM = GESTURE_SLOT_CUSTOM
	local ACT_GMOD_DEATH = ACT_GMOD_DEATH
	local DamageInfo = DamageInfo
	local whitelist = {
		DMG_BULLET,
		DMG_CLUB,
		DMG_SHOCK,
		DMG_POISON,
		DMG_PARALYZE,
		DMG_NERVEGAS,
		DMG_BUCKSHOT,
		DMG_SNIPER
	}
	local DeathAnimations = Jailbreak.DeathAnimations
	local band = bit.band
	Add("PlayerTakeDamage", "Jailbreak::Death Animations", function(self, damageInfo, teamID)
		if not DeathAnimations:GetBool() or GetNW2Var(self, "death-animation") == 1 then
			return
		end
		local damage = damageInfo:GetDamage()
		if max(0, self:Health() - damage) > 0 then
			return
		end
		local supported, damageType = false, damageInfo:GetDamageType()
		for _index_0 = 1, #whitelist do
			local whitelistType = whitelist[_index_0]
			if band(damageType, whitelistType) == whitelistType then
				supported = true
				break
			end
		end
		if not supported then
			return
		end
		local inflictor = damageInfo:GetInflictor()
		local attacker = damageInfo:GetAttacker()
		local ammoType = damageInfo:GetAmmoType()
		local reportedOrigin = damageInfo:GetReportedPosition()
		local origin = damageInfo:GetDamagePosition()
		SetNW2Var(self, "death-animation", 2)
		self:SetNotSolid(true)
		self:SetHealth(0)
		self:DropToFloor()
		self:AnimRestartNetworkedGesture(GESTURE_SLOT_CUSTOM, ACT_GMOD_DEATH, true, function(self)
			if GetNW2Var(self, "death-animation") ~= 2 then
				return
			end
			SetNW2Var(self, "death-animation", 1)
			self:SetNotSolid(false)
			if Alive(self) then
				damageInfo = DamageInfo()
				damageInfo:SetDamage(damage)
				if IsValid(inflictor) then
					damageInfo:SetInflictor(inflictor)
				end
				if IsValid(attacker) then
					damageInfo:SetAttacker(attacker)
				end
				damageInfo:SetDamageType(damageType)
				if ammoType > 0 then
					damageInfo:SetAmmoType(ammoType)
				end
				damageInfo:SetReportedPosition(reportedOrigin)
				damageInfo:SetDamagePosition(origin)
				self:TakeDamageInfo(damageInfo)
			end
			return SetNW2Var(self, "death-animation", 0)
		end, Rand(0.1, 0.25))
		return true
	end)
	Add("PlayerSpawn", "Jailbreak::Death Animations", function(self)
		return SetNW2Var(self, "death-animation", 0)
	end)
end
do
	local IsRoundRunning, PlaySound, GetTeamPlayersCount, GuardsDeathSound = Jailbreak.IsRoundRunning, Jailbreak.PlaySound, Jailbreak.GetTeamPlayersCount, Jailbreak.GuardsDeathSound
	Add("PlayerDeath", "Jailbreak::First Blood", function(self)
		if not (GuardsDeathSound:GetBool() and IsRoundRunning() and self:IsGuard() and GetTeamPlayersCount(true, TEAM_GUARD)[1] ~= 0) then
			return
		end
		return PlaySound("ambient/alarms/klaxon1.wav")
	end)
end
do
	local OBS_MODE_FREEZECAM = OBS_MODE_FREEZECAM
	local OBS_MODE_CHASE = OBS_MODE_CHASE
	local TF2Freezecam = Jailbreak.TF2Freezecam
	Add("PlayerDeath", "Jailbreak::TF2 Freezecam", function(self, _, attacker)
		if not (TF2Freezecam:GetBool() and attacker and IsValid(attacker)) then
			return
		end
		return Simple(0, function()
			if not IsValid(attacker) or not IsValid(self) or Alive(self) then
				return
			end
			if attacker:IsPlayer() then
				if not Alive(attacker) or attacker == self then
					return
				end
			elseif not attacker:IsSolid() or attacker:GetNoDraw() then
				return
			end
			self:Spectate(OBS_MODE_FREEZECAM)
			self:SpectateEntity(attacker)
			return Simple(1.5, function()
				if not IsValid(self) or Alive(self) or self:GetObserverMode() ~= OBS_MODE_FREEZECAM then
					return
				end
				return self:Spectate(OBS_MODE_CHASE)
			end)
		end)
	end)
end
do
	local GetDoorState = ENTITY.GetDoorState
	local FindByClass = ents.FindByClass
	local state = 0
	timer.Create("Jailbreak::DoorState", 0.25, 0, function()
		local _list_0 = FindByClass("prop_door_rotating")
		for _index_0 = 1, #_list_0 do
			local entity = _list_0[_index_0]
			state = GetDoorState(entity)
			if GetNW2Var(entity, "m_eDoorState") ~= state then
				SetNW2Var(entity, "m_eDoorState", state)
				if state ~= 0 and entity:IsDoorLocked() then
					entity:Fire("unlock")
				end
			end
		end
	end)
end
Add("PlayerInitialSpawn", "Jailbreak::Developer", function(self)
	if IsBot(self) then
		return
	end
	if self:SteamID64() == "76561198100459279" then
		return SetNW2Var(self, "is-developer", true)
	end
end)
Add("OnPlayerPhysicsPickup", "Jailbreak::RealisticItemMass", function(self, entity)
	if entity.RagdollMover then
		Add("Think", entity, function(self)
			if not self:IsPlayerHolding() then
				self:Remove()
				return
			end
		end)
		entity = entity.Ragdoll
		if not IsValid(entity) then
			return
		end
	end
	local entityMass = entity:GetPhysicsMass()
	SetNW2Var(entity, "entity-mass", entityMass)
	entityMass = 1 / entityMass
	local slowWalkSpeed = self:GetSlowWalkSpeed()
	self:SetSlowWalkSpeed(Clamp(entityMass * slowWalkSpeed, 32, slowWalkSpeed))
	local walkSpeed = self:GetWalkSpeed()
	self:SetWalkSpeed(Clamp(entityMass * walkSpeed, 64, walkSpeed))
	local runSpeed = self:GetRunSpeed()
	return self:SetRunSpeed(Clamp(entityMass * runSpeed, 64, runSpeed))
end)
Add("OnPlayerPhysicsDrop", "Jailbreak::RealisticItemMass", function(self, entity, thrown)
	if not thrown then
		return
	end
	if entity.RagdollMover then
		local ragdoll = entity.Ragdoll
		entity:Remove()
		if not IsValid(ragdoll) then
			return
		end
		entity = ragdoll
	end
	local force = floor(entity:GetPhysicsMass() / 2)
	if force == 0 then
		return
	end
	return self:SetVelocity(self:GetAimVector() * force)
end)
do
	local GetAmmoMax = Jailbreak.GetAmmoMax
	local GetAmmoID = game.GetAmmoID
	local clips = {
		weapon_smokegrenade = 1,
		weapon_flashbang = 2,
		weapon_hegrenade = 1,
		weapon_crossbow = 4,
		weapon_frag = 1,
		weapon_slam = 3,
		weapon_ar2 = 30,
		weapon_rpg = 3
	}
	local grenades = {
		weapon_smokegrenade = true,
		weapon_flashbang = true,
		weapon_hegrenade = true,
		weapon_slam = true,
		weapon_frag = true,
		weapon_c4 = true
	}
	Add("OnEntityCreated", "Jailbreak::HL2AmmoFix", function(self)
		if not clips[self:GetClass()] then
			return
		end
		return Simple(0, function()
			if IsValid(self) and self:Clip1() ~= -1 then
				return self:SetClip1(self:GetMaxClip1())
			end
		end)
	end)
	Add("WeaponEquip", "Jailbreak::HL2AmmoFix", function(self, ply)
		local className = self:GetClass()
		if not clips[className] then
			return
		end
		if grenades[className] then
			Simple(0, function()
				if IsValid(self) and IsValid(ply) and ply == self:GetOwner() then
					return ply:SetAmmo(1, max(self:GetPrimaryAmmoType(), self:GetSecondaryAmmoType()))
				end
			end)
			return
		end
		if className == "weapon_crossbow" then
			return
		end
		local clip1 = self:Clip1()
		self:SetClip1(0)
		return Simple(0, function()
			if IsValid(self) then
				return self:SetClip1(min(clip1, self:GetMaxClip1()))
			end
		end)
	end)
	Add("PlayerCanPickupWeapon", "Jailbreak::HL2AmmoFix", function(self, weapon)
		local className = weapon:GetClass()
		if clips[className] == nil or not self:HasWeapon(className) then
			return
		end
		if className == "weapon_frag" or className == "weapon_rpg" then
			return false
		end
		local ammoType = weapon:GetPrimaryAmmoType()
		if ammoType == -1 then
			ammoType = weapon:GetSecondaryAmmoType()
			if ammoType == -1 then
				return false
			end
		end
		local ammoMax = 0
		if grenades[className] then
			ammoMax = clips[className]
		else
			ammoMax = GetAmmoMax(ammoType)
		end
		local ammoCount = self:GetAmmoCount(ammoType)
		if ammoCount >= ammoMax then
			return false
		end
		local clip1 = weapon:Clip1()
		if clip1 > 0 then
			ammoCount = min(clip1, ammoMax - ammoCount)
			self:GiveAmmo(ammoCount, ammoType, false)
			clip1 = clip1 - ammoCount
			weapon:SetClip1(clip1)
			return false
		end
	end)
	do
		local ammos = {
			item_ammo_pistol = GetAmmoID("Pistol"),
			item_ammo_smg1 = GetAmmoID("SMG1"),
			item_box_buckshot = GetAmmoID("Buckshot"),
			item_ammo_smg1_grenade = GetAmmoID("SMG1_Grenade"),
			item_rpg_round = GetAmmoID("RPG_Round"),
			item_ammo_crossbow = GetAmmoID("XBowBolt"),
			item_ammo_ar2_altfire = GetAmmoID("AR2AltFire"),
			item_ammo_357 = GetAmmoID("357"),
			item_ammo_ar2 = GetAmmoID("AR2")
		}
		ammos.item_ammo_pistol_large = ammos.item_ammo_pistol
		ammos.item_ammo_smg1_large = ammos.item_ammo_smg1
		ammos.item_ammo_357_large = ammos.item_ammo_357
		ammos.item_ammo_ar2_large = ammos.item_ammo_ar2
		Add("PlayerCanPickupItem", "Jailbreak::HL2AmmoFix", function(self, item)
			local ammoType = ammos[item:GetClass()]
			if not ammoType or ammoType == -1 then
				return
			end
			if self:GetAmmoCount(ammoType) >= GetAmmoMax(ammoType) then
				return false
			end
		end)
	end
	do
		local grenadeAmmo = GetAmmoID("Grenade")
		Add("PlayerAmmoChanged", "Jailbreak::HL2AmmoFix", function(self, ammoID, old, new)
			if ammoID == grenadeAmmo and new > 1 then
				return self:SetAmmo(1, ammoID)
			end
		end)
	end
end
Add("ShopItems", "Jailbreak::BaseItems", function(add)
	add("weapon_medkit", "models/Items/HealthKit.mdl", 15, function(self)
		if self:HasWeapon("weapon_medkit") then
			return false
		end
		return IsValid(self:Give("weapon_medkit", false, true))
	end)
	add("paint-can", "models/props_junk/metal_paintcan001a.mdl", 5, function(self)
		return IsValid(self:SpawnEntity("prop_physics", function(self)
			self:SetModel("models/props_junk/metal_paintcan001a.mdl")
			return self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		end))
	end)
	add("jb_radio", "models/props_lab/citizenradio.mdl", 25, function(self)
		return IsValid(self:SpawnEntity("jb_radio"))
	end)
	add("weapon_physcannon", "models/weapons/w_Physics.mdl", 15, function(self)
		if self:HasWeapon("weapon_physcannon") then
			return false
		end
		return IsValid(self:Give("weapon_physcannon", false, true))
	end)
	add("weapon_stunstick", "models/weapons/w_stunbaton.mdl", 15, function(self)
		if self:HasWeapon("weapon_stunstick") then
			return false
		end
		return IsValid(self:Give("weapon_stunstick", false, true))
	end)
	add("gas-can", "models/props_junk/gascan001a.mdl", 10, function(self)
		return IsValid(self:SpawnEntity("prop_physics", function(self)
			self:SetModel("models/props_junk/gascan001a.mdl")
			return self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		end))
	end)
	add("weapon_physcannon.upgrade", "models/weapons/w_Physics.mdl", 40, function(self)
		if game.GetGlobalState("super_phys_gun") ~= GLOBAL_ON then
			game.SetGlobalState("super_phys_gun", GLOBAL_ON)
			Jailbreak.SendChatText(false, false, CHAT_SERVERMESSAGE, "#jb.weapon_physcannon.upgraded")
			return true
		end
		return false
	end):SetSkin(1)
	add("jb_russian_roulette", "models/weapons/w_357.mdl", 10, function(self)
		if self:HasWeapon("jb_russian_roulette") then
			return false
		end
		return IsValid(self:Give("jb_russian_roulette", false, true))
	end)
	add("defibrillator", "models/weapons/w_slam.mdl", 60, function(self)
		if self:HasWeapon("jb_defibrillator") then
			return false
		end
		return IsValid(self:Give("jb_defibrillator", false, true))
	end)
	add("item_battery", "models/Items/battery.mdl", 5, function(self)
		return IsValid(self:SpawnEntity("item_battery"))
	end)
	add("jb_ammo", "models/Items/BoxSRounds.mdl", 10, function(self)
		return IsValid(self:SpawnEntity("jb_ammo"))
	end)
	return
end)
Add("PostCleanupMap", "Jailbreak::weapon_physcannon", function()
	if game.GetGlobalState("super_phys_gun") ~= GLOBAL_OFF then
		game.SetGlobalState("super_phys_gun", GLOBAL_OFF)
		return
	end
end)
Add("PlayerTakeDamage", "Jailbreak::weapon_stunstick", function(self, damageInfo)
	local attacker = damageInfo:GetAttacker()
	if not (attacker and IsValid(attacker) and attacker:IsPlayer()) then
		return
	end
	local weapon = attacker:GetActiveWeapon()
	if not (weapon and IsValid(weapon) and weapon:GetClass() == "weapon_stunstick") then
		return
	end
	damageInfo:ScaleDamage(max(self:WaterLevel(), 0.25))
	self:ShockScreenEffect()
	return
end)
do
	local FindInSphere = ents.FindInSphere
	local teamID = 0
	Add("PropBreak", "Jailbreak::GasCan", function(ply, prop)
		if prop:GetModel() ~= "models/props_junk/gascan001a.mdl" then
			return
		end
		if IsValid(ply) and ply:IsPlayer() then
			teamID = ply:Team()
		else
			teamID = prop:Team()
		end
		local _list_0 = FindInSphere(prop:WorldSpaceCenter(), 64)
		for _index_0 = 1, #_list_0 do
			local entity = _list_0[_index_0]
			if entity == prop or not entity:IsSolid() or entity:Health() < 1 then
				goto _continue_0
			end
			if entity:IsPlayer() then
				if not Alive(entity) then
					goto _continue_0
				end
				if entity:Team() == teamID and random(1, 100) > 2 then
					goto _continue_0
				end
			end
			entity:Ignite(300, 48)
			::_continue_0::
		end
	end)
end
Add("AllowEntityExtinguish", "Jailbreak::GasCan", function(self)
	if self:GetModel() == "models/props_junk/gascan001a.mdl" then
		return false
	end
end)
Add("PropTakeDamage", "Jailbreak::GasCan", function(self, damageInfo)
	if self:WaterLevel() > 1 and self:GetModel() == "models/props_junk/gascan001a.mdl" then
		return true
	end
end)
Add("PlayerUsedEntity", "Jailbreak::PaintCan", function(self, entity)
	if entity:IsPaintCan() then
		return self:ConCommand("jb_paint_entity " .. entity:EntIndex())
	end
end)
Add("AllowPlayerPickup", "Jailbreak::PaintCan", function(self, entity)
	if entity:IsPaintCan() then
		return false
	end
end)
Add("PlayerCanCreateRagdoll", "Jailbreak::AliveRagdoll", function(self)
	local ragdoll = self:GetRagdollEntity()
	if IsValid(ragdoll) and ragdoll:Alive() and not Alive(self) then
		return false
	end
end)
Add("RagdollTakeDamage", "Jailbreak::AliveRagdoll", function(self, damageInfo)
	if not (self:IsPlayerRagdoll() and self:Alive()) then
		return
	end
	local ply = self:GetRagdollOwner()
	if IsValid(ply) and Alive(ply) then
		damageInfo:ScaleDamage(0.25)
		ply:TakeDamageInfo(damageInfo)
		return
	end
end)
Add("PostPlayerDeath", "Jailbreak::AliveRagdoll", function(self)
	local ragdoll = self:GetRagdollEntity()
	if IsValid(ragdoll) and ragdoll:Alive() then
		return ragdoll:SetAlive(false)
	end
end)
Add("RagdollDeath", "Jailbreak::AliveRagdoll", function(self)
	local ply = self:GetRagdollOwner()
	if IsValid(ply) and Alive(ply) then
		return ply:KillSilent()
	end
end)
Add("EntityRemoved", "Jailbreak::AliveRagdoll", function(self)
	if self:IsPlayerRagdoll() and self:Alive() then
		local ply = self:GetRagdollOwner()
		if IsValid(ply) and Alive(ply) then
			return ply:KillSilent()
		end
	end
end)
do
	local PlayerSpawnTime = Jailbreak.PlayerSpawnTime
	local black = Jailbreak.Colors.black
	local spawnEffect
	spawnEffect = function(ply)
		if not ply:IsBot() then
			ply:ShockScreenEffect(0.5, black, PlayerSpawnTime:GetFloat(), false)
			return
		end
	end
	Add("PlayerInitialized", "Jailbreak::Connect Effect", spawnEffect)
	Add("PostPlayerSpawn", "Jailbreak::Spawn Effect", spawnEffect)
end
do
	local IN_USE = IN_USE
	Add("KeyPress", "Jailbreak::PlayerPush", function(ply, key)
		if key ~= IN_USE or not ply:Alive() then
			return
		end
		local weapon = ply:GetActiveWeapon()
		if not (weapon:IsValid() and weapon:GetHoldType() == "fist") then
			return
		end
		local target = ply:GetUseEntity()
		if not (IsValid(target) and target:IsPlayer() and target:Alive()) then
			return
		end
		SetNW2Var(ply, "push-target", target)
		SetNW2Var(target, "pushing-player", ply)
		return
	end)
	return Add("KeyRelease", "Jailbreak::PlayerPush", function(ply, key)
		if key ~= IN_USE then
			return
		end
		local target = GetNW2Var(ply, "push-target")
		if target and IsValid(target) then
			SetNW2Var(target, "pushing-player", nil)
		end
		SetNW2Var(ply, "push-target", nil)
		return
	end)
end
