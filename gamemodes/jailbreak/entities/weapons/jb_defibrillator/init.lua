AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
local CHAN_STATIC = CHAN_STATIC
local DMG_SHOCK = DMG_SHOCK
local TraceLine = util.TraceLine
local CurTime = CurTime
local random = math.random
local jb_defibrillator_usages = CreateConVar("jb_defibrillator_usages", "3", bit.bor(FCVAR_ARCHIVE, FCVAR_NOTIFY), "Determines maximum number of defibrillator usages before it fails.")
SWEP.Initialize = function(self)
	self:SetHoldType("duel")
	return self:SetClip1(jb_defibrillator_usages:GetInt())
end
SWEP.TakeClip1 = function(self, amount, owner)
	local clip1 = self:Clip1() - amount
	if clip1 < 1 then
		owner:EmitSound("physics/metal/metal_box_break" .. random(1, 2) .. ".wav", 75, random(80, 120), 0.8, CHAN_STATIC, 0, 1)
		owner:SelectWeapon("jb_hands")
		self:Remove()
		return
	end
	return self:SetClip1(clip1)
end
SWEP.ShockAlivePlayer = function(self, ply, owner)
	local damageInfo = DamageInfo()
	damageInfo:SetAttacker(owner)
	damageInfo:SetInflictor(self)
	damageInfo:SetDamage(random(50, 100))
	damageInfo:SetDamageType(DMG_SHOCK)
	ply:TakeDamageInfo(damageInfo)
	if not ply:Alive() then
		return owner:SendNotify("#jb.notify.player-reanimated", NOTIFY_ERROR, 10, ply:Nick())
	end
end
local traceResult = { }
local trace = {
	output = traceResult
}
SWEP.PrimaryAttack = function(self)
	local owner = self:GetOwner()
	if not (owner:IsValid() and owner:Alive()) then
		return
	end
	trace.start = owner:GetShootPos()
	trace.endpos = trace.start + owner:GetAimVector() * 128
	trace.filter = owner
	TraceLine(trace)
	if not traceResult.Hit then
		return
	end
	local entity = traceResult.Entity
	if not entity:IsValid() then
		return
	end
	entity:DoElectricSparks(traceResult.HitPos)
	self:SetNextPrimaryFire(CurTime() + self.UsageDelay:GetFloat())
	if not entity:IsPlayerRagdoll() then
		if entity:IsPlayer() and entity:Alive() and entity:Team() ~= owner:Team() then
			self:ShockAlivePlayer(entity, owner)
			self:TakeClip1(1, owner)
			return
		end
		owner:SendNotify("#jb.error.cant-do-that", NOTIFY_ERROR, 5)
		return
	end
	local ply = entity:GetRagdollOwner()
	if not ply:IsValid() then
		owner:SendNotify("#jb.error.player-soulless", NOTIFY_ERROR, 10, entity:GetRagdollOwnerNickname())
		return
	end
	if ply:Alive() then
		if entity:Alive() and ply:IsLoseConsciousness() then
			self:ShockAlivePlayer(ply, owner)
			self:TakeClip1(1, owner)
			return
		end
		owner:SendNotify("#jb.error.cant-do-that", NOTIFY_ERROR, 10)
		return
	end
	local spawnTime = ply:GetSpawnTime()
	entity:SetAlive(true)
	ply:Spawn()
	ply:SetHealth(25)
	ply:SetNW2Int("spawn-time", spawnTime)
	owner:SendNotify("#jb.notify.player-reanimated", NOTIFY_GENERIC, 10, ply:Nick())
	return self:TakeClip1(1, owner)
end
