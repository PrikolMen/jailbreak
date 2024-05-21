local Jailbreak = Jailbreak
local ceil, random, max, floor, Rand
do
	local _obj_0 = math
	ceil, random, max, floor, Rand = _obj_0.ceil, _obj_0.random, _obj_0.max, _obj_0.floor, _obj_0.Rand
end
local vector_origin = vector_origin
local CHAN_STATIC = CHAN_STATIC
local IsValid = ENTITY.IsValid
local Vector = Vector
local Create = ents.Create
local Angle = Angle
local Run = hook.Run
local GM = GM
do
	local ShockCollarVictimDamage, ShockCollarAttackerDamage = Jailbreak.ShockCollarVictimDamage, Jailbreak.ShockCollarAttackerDamage
	local white = Color(200, 200, 200, 150)
	local NOTIFY_ERROR = NOTIFY_ERROR
	local DMG_SONIC = DMG_SONIC
	GM.PlayerTakeDamage = function(self, ply, damageInfo, teamID)
		if ply:HasShockCollar() and damageInfo:IsShockDamage() then
			ply:DoElectricSparks()
			ply:TakeShockCollar(true)
			ply:SendNotify("#jb.notify.shock-collar.broken", NOTIFY_ERROR, 10)
			return
		end
		if not damageInfo:IsCloseRangeDamage() then
			return
		end
		local attacker = damageInfo:GetAttacker()
		if not (IsValid(attacker) and attacker:IsPlayer() and attacker:ShockCollarIsEnabled()) or attacker == ply then
			return
		end
		local damage, damageType = damageInfo:GetDamage(), damageInfo:GetDamageType()
		local newDamage = damage * ShockCollarAttackerDamage:GetFloat()
		if newDamage >= 1 then
			attacker:DoElectricSparks()
			damageInfo:SetDamage(newDamage)
			damageInfo:SetDamageType(DMG_SONIC)
			attacker:TakeDamageInfo(damageInfo)
			attacker:ShockScreenEffect(0.25, white, 0.25, true)
		end
		damageInfo:SetDamageType(damageType)
		return damageInfo:SetDamage(damage * ShockCollarVictimDamage:GetFloat())
	end
end
do
	local IsRoundPreparing, IsProp = Jailbreak.IsRoundPreparing, Jailbreak.IsProp
	GM.EntityTakeDamage = function(self, entity, damageInfo)
		local className = entity:GetClass()
		if IsRoundPreparing() then
			if className == "func_button" then
				return
			end
			return true
		end
		if damageInfo:IsExplosionDamage() then
			damageInfo:SetDamage(damageInfo:GetDamage() + damageInfo:GetDamageForce():Length() / 256)
		elseif damageInfo:IsCloseRangeDamage() then
			local attacker = damageInfo:GetAttacker()
			if IsValid(attacker) and attacker:IsPlayer() and Jailbreak.PowerfulPlayers then
				damageInfo:ScaleDamage(3)
			end
		end
		if entity:IsPlayer() then
			if Run("CanPlayerTakeDamage", entity, damageInfo, entity:Team()) == false then
				return true
			end
			return Run("PlayerTakeDamage", entity, damageInfo, entity:Team())
		end
		if entity:IsRagdoll() or entity:IsPlayerRagdoll() then
			return Run("RagdollTakeDamage", entity, damageInfo, className)
		end
		if damageInfo:IsNeverGibDamage() then
			damageInfo:SetDamageForce(vector_origin)
			damageInfo:ScaleDamage(0.25)
		end
		if className == "func_button" then
			return Run("ButtonTakeDamage", entity, damageInfo, className)
		end
		if className == "prop_door_rotating" then
			return Run("DoorTakeDamage", entity, damageInfo, className)
		end
		if IsProp(className) then
			return Run("PropTakeDamage", entity, damageInfo, className)
		end
		if entity:IsWeapon() then
			return Run("WeaponTakeDamage", entity, damageInfo, className)
		end
		return Run("ClassTakeDamage", entity, damageInfo, className)
	end
end
GM.PostEntityTakeDamage = function(self, entity, damageInfo, isRealDamage)
	if not isRealDamage then
		return
	end
	local velocity = damageInfo:GetDamageForce()
	local speed = velocity:Length()
	if speed < 1 then
		return
	end
	if entity:IsPlayer() then
		if damageInfo:IsBulletDamage() then
			local length = speed / 1000
			if length > 3 then
				velocity:Normalize()
				velocity = velocity * 256
			elseif length > 2 then
				velocity = velocity * (2 / length)
			end
			damageInfo:SetDamageForce(velocity)
		end
		local inflictor = damageInfo:GetInflictor()
		if IsValid(inflictor) and inflictor:IsWeapon() and inflictor:IsScripted() then
			entity:SetVelocity(velocity)
		end
		return
	end
	local inflictor = damageInfo:GetInflictor()
	if IsValid(inflictor) and inflictor:IsRagdoll() then
		damageInfo:SetDamageForce(vector_origin)
		return
	end
	local origin = damageInfo:GetDamagePosition()
	for physNum = 0, entity:GetPhysicsObjectCount() - 1 do
		local phys = entity:GetPhysicsObjectNum(physNum)
		if phys and phys:IsValid() and phys:IsMoveable() and phys:IsMotionEnabled() then
			phys:ApplyForceOffset(velocity / phys:GetMass(), origin)
			if phys:IsAsleep() then
				phys:Wake()
			end
		end
	end
end
do
	local sk_npc_dmg_fraggrenade = GetConVar("sk_npc_dmg_fraggrenade")
	local sk_fraggrenade_radius = GetConVar("sk_fraggrenade_radius")
	local Explosion = Jailbreak.Explosion
	GM.ClassTakeDamage = function(self, entity, damageInfo, className)
		if className == "npc_grenade_frag" and not entity.m_bExploded then
			entity.m_bExploded = true
			local radius = sk_fraggrenade_radius:GetInt()
			if damageInfo:IsExplosionDamage() then
				radius = radius * random(1, 4)
			end
			Explosion(entity, damageInfo:GetAttacker(), entity:WorldSpaceCenter(), radius, sk_npc_dmg_fraggrenade:GetInt())
			entity:Remove()
			return true
		end
	end
	GM.WeaponTakeDamage = function(self, weapon, damageInfo, className)
		if className == "weapon_frag" and not weapon.m_bExploded then
			weapon.m_bExploded = true
			local radius = sk_fraggrenade_radius:GetInt()
			if damageInfo:IsExplosionDamage() then
				radius = radius * random(1, 4)
			end
			Explosion(weapon, damageInfo:GetAttacker(), weapon:WorldSpaceCenter(), radius, sk_npc_dmg_fraggrenade:GetInt())
			weapon:Remove()
			return true
		end
	end
end
do
	local IsValidModel, IsInWorld
	do
		local _obj_0 = util
		IsValidModel, IsInWorld = _obj_0.IsValidModel, _obj_0.IsInWorld
	end
	local DoorsHealth = Jailbreak.DoorsHealth
	GM.DoorTakeDamage = function(self, door, damageInfo)
		local model = door:GetModel()
		if #model == 0 or not IsValidModel(model) then
			return
		end
		local maxHealth = door:GetMaxHealth()
		if maxHealth == 1 then
			maxHealth = DoorsHealth:GetInt()
			if maxHealth <= 0 then
				return
			end
			door:SetMaxHealth(maxHealth)
			door:SetHealth(maxHealth)
		end
		local health = max(0, door:Health() - damageInfo:GetDamage())
		door:SetHealth(health)
		if health >= 1 then
			return
		end
		local center = door:OBBCenter()
		center[1], center[2] = 0, 0
		local origin = door:LocalToWorld(center)
		if not IsInWorld(origin) then
			door:Remove()
			return true
		end
		local prop = Create("prop_physics")
		prop:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		prop:SetAngles(door:GetAngles())
		prop:SetSkin(door:GetSkin())
		prop:SetModel(model)
		prop:SetPos(origin)
		prop:Spawn()
		prop:EmitSound("physics/wood/wood_crate_break" .. random(1, 5) .. ".wav", 70, random(80, 120), 1, CHAN_STATIC, 0, 1)
		door:Remove()
		origin = damageInfo:GetDamagePosition()
		util.ScreenShake(origin, 5, 10, 0.5, 150)
		prop:DoElectricSparks(origin, nil, true)
		prop:TakeDamageInfo(damageInfo)
		return
	end
end
do
	local DMG_SHOCK = DMG_SHOCK
	GM.ButtonTakeDamage = function(self, button, damageInfo)
		if damageInfo:IsExplosionDamage() then
			return true
		end
		local attacker = damageInfo:GetAttacker()
		if not (IsValid(attacker) and attacker:IsPlayer() and random(0, 1) == 1) then
			return true
		end
		button:DoElectricSparks(damageInfo:GetDamagePosition(), 150)
		button:Use(attacker, attacker)
		if not damageInfo:IsCloseRangeDamage() then
			return true
		end
		attacker:Ignite(0.5, 16)
		local dir = attacker:WorldSpaceCenter() - damageInfo:GetDamagePosition()
		dir[3] = 1
		damageInfo:SetDamage(attacker:GetMaxHealth() / Rand(2, 3))
		damageInfo:SetDamageForce(dir * 100)
		damageInfo:SetDamageType(DMG_SHOCK)
		damageInfo:SetAttacker(button)
		attacker:TakeDamageInfo(damageInfo)
		return true
	end
end
do
	local MOVETYPE_VPHYSICS = MOVETYPE_VPHYSICS
	local SOLID_VPHYSICS = SOLID_VPHYSICS
	local isnumber = isnumber
	local istable = istable
	local dropList = Jailbreak.PropsDropList
	if not dropList then
		dropList = {
			["models/props/de_inferno/crate_fruit_break.mdl"] = {
				["Models"] = "models/props/cs_italy/orange.mdl",
				["Count"] = {
					16,
					32
				}
			}
		}
		Jailbreak.PropsDropList = dropList
	end
	local materials = Jailbreak.PropDamageMaterials
	if not materials then
		materials = {
			[MAT_GLASS] = 0.5,
			[MAT_CONCRETE] = 5,
			[MAT_SLOSH] = 0.25,
			[MAT_GRATE] = 8,
			[MAT_DIRT] = 3,
			[MAT_TILE] = 2,
			[MAT_FOLIAGE] = 1.5,
			[MAT_VENT] = 0.25,
			[MAT_WOOD] = 3,
			[MAT_COMPUTER] = 0.25,
			[MAT_METAL] = 8,
			[MAT_PLASTIC] = 1.25,
			[MAT_GRASS] = 0.25,
			[MAT_DEFAULT] = 16,
			[MAT_FLESH] = 0.5,
			[MAT_BLOODYFLESH] = 0.25
		}
		Jailbreak.PropDamageMaterials = materials
	end
	local cache = { }
	GM.PropTakeDamage = function(self, entity, damageInfo)
		if damageInfo:IsCrushDamage() then
			damageInfo:SetDamageForce(vector_origin)
		end
		if entity.m_bCustomHealth == nil then
			if entity:GetMaxHealth() == 1 and entity:Health() == 0 then
				local health = cache[entity:GetModel()]
				if not health then
					local mins, maxs = entity:GetCollisionBounds()
					health = ceil(mins:Distance(maxs) * (materials[entity:GetMaterialType() or 0] or 1))
					cache[entity:GetModel()] = health
				end
				entity:SetHealth(health)
				entity:SetMaxHealth(health)
				entity.m_bCustomHealth = true
			else
				entity.m_bCustomHealth = false
			end
		end
		if not entity.m_bCustomHealth then
			return
		end
		local health = max(0, entity:Health() - damageInfo:GetDamage())
		if health < 1 then
			local velocity = entity:GetVelocity() + damageInfo:GetDamageForce()
			if entity:PrecacheGibs() > 0 then
				entity:GibBreakClient(velocity)
			end
			local dropModels = dropList[entity:GetModel()]
			if dropModels ~= nil then
				local count = dropModels.Count
				if istable(count) then
					count = random(count[1], count[2])
				elseif not isnumber(count) then
					count = 1
				end
				dropModels = dropModels.Models
				local isTable = istable(dropModels)
				if isTable or isstring(dropModels) then
					local mins, maxs = entity:GetCollisionBounds()
					local speed = velocity:Length()
					mins = mins * 0.8
					maxs = maxs * 0.8
					for i = 1, count do
						local prop = Create("prop_physics")
						if isTable then
							prop:SetModel(dropModels[random(1, #dropModels)])
						else
							prop:SetModel(dropModels)
						end
						prop:SetPos(entity:LocalToWorld(Vector(random(mins[1], maxs[1]), random(mins[2], maxs[2]), random(mins[3], maxs[3]))))
						prop:SetAngles(Angle(random(-180, 180), random(-180, 180), random(-180, 180)))
						prop:Spawn()
						local phys = prop:GetPhysicsObject()
						if phys and phys:IsValid() then
							phys:ApplyForceCenter(Vector(random(-1, 1), random(-1, 1), random(-1, 1)) * speed)
						end
					end
				end
			end
			local inflictor = damageInfo:GetInflictor()
			if IsValid(inflictor) and inflictor:GetClass() == "prop_combine_ball" then
				entity:Dissolve()
				return
			end
			entity:Remove()
			return true
		end
		entity:SetHealth(health)
		if (health / entity:GetMaxHealth()) > 0.5 then
			return
		end
		local changed = false
		if entity:GetMoveType() ~= MOVETYPE_VPHYSICS then
			entity:SetMoveType(MOVETYPE_VPHYSICS)
			changed = true
		end
		if entity:GetClass() == "prop_dynamic" then
			entity:PhysicsInit(SOLID_VPHYSICS)
			changed = true
		end
		local phys = entity:GetPhysicsObject()
		if phys and phys:IsValid() then
			if not phys:IsMotionEnabled() then
				phys:EnableMotion(true)
				changed = true
			end
			if phys:IsAsleep() then
				phys:Wake()
			end
		end
		if changed then
			entity:DoElectricSparks(entity:WorldSpaceCenter())
			return entity:EmitSound("physics/metal/metal_box_break" .. random(1, 2) .. ".wav", 70, random(80, 120), 1, CHAN_STATIC, 0, 1)
		end
	end
end
do
	local player_old_armor = GetConVar("player_old_armor")
	GM.PerformArmorDamage = function(self, entity, armor, damageInfo)
		if armor <= 0 then
			return 0
		end
		if damageInfo:IsNonPhysicalDamage() then
			return armor
		end
		if damageInfo:IsCloseRangeDamage() and damageInfo:GetAttacker() == entity then
			damageInfo:ScaleDamage(0.25)
		end
		local isEnabled = player_old_armor:GetBool()
		local flBonus = isEnabled and 0.5 or 1
		local flRatio = 0.2
		local damage = damageInfo:GetDamage()
		local flNew = damage * flRatio
		local flArmor = (damage - flNew) * flBonus
		if not isEnabled and flArmor < 1 then
			flArmor = 1
		end
		if flArmor > armor then
			flArmor = armor * (1 / flBonus)
			flNew = damage - flArmor
			armor = 0
		else
			armor = armor - flArmor
		end
		damageInfo:SetDamage(flNew)
		return armor
	end
end
do
	local BLOOD_COLOR_MECH = BLOOD_COLOR_MECH
	local BLOOD_COLOR_RED = BLOOD_COLOR_RED
	GM.HandlePlayerArmorReduction = function(self, ply, damageInfo)
		ply:SetArmor(self:PerformArmorDamage(ply, ply:Armor(), damageInfo))
		return ply:SetBloodColor(ply:Armor() > 0 and BLOOD_COLOR_MECH or BLOOD_COLOR_RED)
	end
end
GM.GetFallDamage = function(self, ply, speed)
	if ply:GetNW2Bool("in-flight") then
		return 0
	end
	return max(0, ceil(0.2418 * speed - 141.75))
end
do
	local LocalToWorld = LocalToWorld
	local BloodSplashes = Jailbreak.BloodSplashes
	GM.RagdollTakeDamage = function(self, ragdoll, damageInfo)
		if damageInfo:IsNeverGibDamage() then
			damageInfo:ScaleDamage(0.25)
		end
		if damageInfo:IsBulletDamage() then
			local force = damageInfo:GetDamageForce()
			local length = force:Length() / 1000
			if length > 3 then
				damageInfo:SetDamageForce(force * (3 / length))
			end
			damageInfo:SetDamage(damageInfo:GetDamage() * 0.25)
		end
		if damageInfo:IsCrushDamage() then
			damageInfo:SetDamageForce(vector_origin)
			local damage = floor(damageInfo:GetDamage() * 0.1)
			if damage > 100 then
				damage = 100
			end
			if damage < 1 then
				return true
			end
			damageInfo:SetDamage(damage)
		end
		local armor = ragdoll.Armor
		if armor ~= nil and armor > 0 then
			ragdoll.Armor = self:PerformArmorDamage(ragdoll, armor, damageInfo)
		end
		local health = ragdoll:Health()
		local nextHealth = floor(health - damageInfo:GetDamage())
		ragdoll:SetHealth(nextHealth)
		if ragdoll:Alive() then
			local startHealth = ragdoll.StartHealth
			if not startHealth then
				startHealth = health
				ragdoll.StartHealth = startHealth
			end
			if (nextHealth / startHealth) < 0.75 then
				ragdoll:EmitSound("Player.Death", 75, random(80, 120), 1, CHAN_STATIC, 0, 1)
				ragdoll:SetAlive(false)
				Run("RagdollDeath", ragdoll)
			end
		end
		if nextHealth > 0 then
			BloodSplashes(ragdoll, damageInfo, false)
			return
		end
		local velocity = ragdoll:GetVelocity() + damageInfo:GetDamageForce()
		BloodSplashes(ragdoll, damageInfo, true, velocity)
		if ragdoll.Weapons ~= nil then
			local origin, angles = ragdoll:WorldSpaceCenter(), ragdoll:GetAngles()
			local mins, maxs = ragdoll:GetCollisionBounds()
			mins, maxs = mins * 0.5, maxs * 0.5
			local _list_0 = ragdoll.Weapons
			for _index_0 = 1, #_list_0 do
				local weapon = _list_0[_index_0]
				if not IsValid(weapon) then
					goto _continue_0
				end
				weapon:SetParent()
				weapon:SetNoDraw(false)
				weapon:SetNotSolid(false)
				origin, angles = LocalToWorld(Vector(random(mins[1], maxs[1], random(mins[2], maxs[2]), random(mins[3], maxs[3]))), Angle(Rand(-90, 90), Rand(-180, 180), Rand(-180, 180)), origin, angles)
				weapon:SetAngles(angles)
				weapon:SetPos(origin)
				local phys = weapon:GetPhysicsObject()
				if phys and phys:IsValid() then
					phys:SetVelocity(velocity)
					phys:Wake()
				end
				weapon.m_bPickupForbidden = nil
				::_continue_0::
			end
			ragdoll.Weapons = nil
		end
		if ragdoll:PrecacheGibs() > 0 then
			ragdoll:GibBreakClient(velocity)
		elseif random(1, 2) == 1 then
			ragdoll:EmitSound("physics/body/body_medium_break" .. random(2, 4) .. ".wav", 70, random(80, 120), 1, CHAN_STATIC, 0, 1)
		else
			ragdoll:EmitSound("physics/flesh/flesh_squishy_impact_hard" .. random(1, 4) .. ".wav", 70, random(80, 120), 1, CHAN_STATIC, 0, 1)
		end
		local inflictor = damageInfo:GetInflictor()
		if IsValid(inflictor) and inflictor:GetClass() == "prop_combine_ball" then
			ragdoll:Dissolve()
			return
		end
		return ragdoll:Remove()
	end
end
