AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
local random = math.random
ENT.StartAmount = 128
ENT.Initialize = function(self)
	self.m_iAmount = self.StartAmount
	self:SetModel(self.Model)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:DrawShadow(true)
	self:PhysWake()
	return
end
ENT.Use = function(self, ply)
	if not (ply:IsPlayer() and ply:Alive()) then
		return
	end
	local weapon = ply:GetActiveWeapon()
	if not (weapon and weapon:IsValid()) then
		ply:SendNotify("#jb.error.cant-do-that", NOTIFY_ERROR, 5)
		return
	end
	local ammoAmount, gived = self.m_iAmount, false
	if weapon:Clip1() ~= -1 then
		local clip1Type = weapon:GetPrimaryAmmoType()
		if clip1Type >= 0 then
			local acceptAmount = ply:GetPickupAmmoCount(clip1Type)
			if acceptAmount > ammoAmount then
				acceptAmount = ammoAmount
			end
			if acceptAmount ~= 0 then
				ply:GiveAmmo(acceptAmount, clip1Type, false)
				ammoAmount = ammoAmount - acceptAmount
				gived = true
			end
		end
	end
	local clip2Type = weapon:GetSecondaryAmmoType()
	if clip2Type >= 0 and acceptAmount ~= 0 then
		local acceptAmount = ply:GetPickupAmmoCount(clip2Type)
		if acceptAmount > ammoAmount then
			acceptAmount = ammoAmount
		end
		if acceptAmount ~= 0 then
			ply:GiveAmmo(acceptAmount, clip2Type, false)
			ammoAmount = ammoAmount - acceptAmount
			gived = true
		end
	end
	if not gived then
		ply:SendNotify("#jb.error.cant-do-that", NOTIFY_ERROR, 5)
		return
	end
	ply:SendNotify("#jb.jb_ammo ( " .. ammoAmount .. " / " .. self.StartAmount .. " )", NOTIFY_HINT, 5)
	ply:EmitSound("items/ammo_pickup.wav", 75, random(80, 120), 1, CHAN_STATIC, 0, 1)
	self.m_iAmount = ammoAmount
	if ammoAmount ~= 0 then
		return
	end
	self:Remove()
	return
end
local sk_npc_dmg_fraggrenade = GetConVar("sk_npc_dmg_fraggrenade")
local sk_fraggrenade_radius = GetConVar("sk_fraggrenade_radius")
local Explosion = Jailbreak.Explosion
ENT.OnTakeDamage = function(self, damageInfo)
	if self.m_bExploded or self.m_iAmount < 16 then
		return
	end
	local radius = sk_fraggrenade_radius:GetInt()
	if damageInfo:IsExplosionDamage() then
		radius = radius * random(1, 4)
	elseif random(1, 10) < 8 then
		return
	end
	self.m_bExploded = true
	Explosion(self, damageInfo:GetAttacker(), self:WorldSpaceCenter(), radius, sk_npc_dmg_fraggrenade:GetInt())
	self:Remove()
	return 0
end
