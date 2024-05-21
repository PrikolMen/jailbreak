AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
local ceil, random
do
	local _obj_0 = math
	ceil, random = _obj_0.ceil, _obj_0.random
end
local TraceLine = util.TraceLine
local CurTime = CurTime
local traceResult = { }
local trace = {
	output = traceResult
}
SWEP.UseDoor = function(self, open)
	local curTime, lastDoorLock = CurTime(), self.LastDoorLock or 0
	self.LastDoorLock = curTime
	if (curTime - lastDoorLock) <= 0.025 then
		return
	end
	local owner = self:GetOwner()
	trace.start = owner:GetShootPos()
	trace.endpos = trace.start + owner:GetAimVector() * 72
	trace.filter = owner
	TraceLine(trace)
	if not traceResult.Hit then
		return
	end
	local entity = traceResult.Entity
	if not (entity and entity:IsValid()) then
		return
	end
	local className = entity:GetClass()
	if className == "prop_door_rotating" or className == "func_door_rotating" then
		if not owner:HasSecurityKeys() then
			entity:EmitSound("physics/wood/wood_crate_impact_hard2.wav", 100, random(90, 110), 1, CHAN_STATIC, 0, 1)
			owner:AnimRestartNetworkedGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST, true)
			return
		end
		if open ~= entity:IsDoorLocked() or entity:GetDoorState() ~= 0 then
			return
		end
		timer.Simple(0.8, function()
			if entity:IsValid() then
				return entity:EmitSound("doors/door_latch3.wav", 50, random(80, 120), 1, CHAN_STATIC, 0, 1)
			end
		end)
		owner:EmitSound("npc/metropolice/gear" .. random(1, 6) .. ".wav", 50, random(80, 120), 1, CHAN_STATIC, 0, 1)
		owner:AnimRestartNetworkedGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_PLACE, true)
		return entity:Fire(open and "unlock" or "lock", "", 0, owner, owner)
	elseif className == "func_button" then
		entity:EmitSound("buttons/blip1.wav", 70, random(90, 110), 1, CHAN_STATIC, 0, 1)
		return entity:Use(owner, owner)
	end
end
do
	local ConVarFlags = bit.bor(FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_DONTRECORD)
	SWEP.MinDamage = CreateConVar("jb_hands_damage_min", "8", ConVarFlags, "Minimal damage from a fist punch.", 0, 16384)
	SWEP.MaxDamage = CreateConVar("jb_hands_damage_max", "12", ConVarFlags, "Maximal damage from a fist punch.", 0, 16384)
end
do
	local phys_pushscale = GetConVar("phys_pushscale")
	local NULL = NULL
	SWEP.HitEntity = function(self, entity, owner, origin)
		local vm = owner:GetViewModel()
		if not (vm and vm:IsValid()) then
			return
		end
		local hit, anim = false, self:GetSequenceName(vm:GetSequence())
		if entity and entity:IsValid() then
			if entity:IsPlayer() and entity:HasGodMode() then
				if not entity.m_bArmstrongMoment and random(1, 100) == 1 then
					entity.m_bArmstrongMoment = true
					entity:Say("You can't hurt me, Jack.")
				end
				self:SetNextFire(CurTime() + 0.05)
			else
				local scale = phys_pushscale:GetFloat()
				local attacker = owner
				if not (attacker and attacker:IsValid()) then
					attacker = self
				end
				local damageInfo = DamageInfo()
				damageInfo:SetInflictor(self)
				damageInfo:SetAttacker(attacker)
				damageInfo:SetDamageType(DMG_SLASH)
				damageInfo:SetDamage(random(self.MinDamage:GetInt(), self.MaxDamage:GetInt()))
				damageInfo:SetDamagePosition(origin)
				if anim == "fists_left" then
					damageInfo:SetDamageForce((owner:GetForward() + owner:GetRight()) * 128 * scale)
				elseif anim == "fists_right" then
					damageInfo:SetDamageForce((owner:GetForward() - owner:GetRight()) * 128 * scale)
				elseif anim == "fists_uppercut" then
					damageInfo:SetDamageForce((owner:GetForward() + owner:GetUp()) * 128 * scale)
					damageInfo:ScaleDamage(2)
				end
				SuppressHostEvents(NULL)
				entity:TakeDamageInfo(damageInfo)
				SuppressHostEvents(owner)
			end
			hit = true
		end
		if hit and anim ~= "fists_uppercut" then
			return self:SetCombo(self:GetCombo() + 1)
		else
			return self:SetCombo(0)
		end
	end
end
SWEP.Materials = {
	[MAT_WOOD] = 5,
	[MAT_VENT] = 15,
	[MAT_GLASS] = 15,
	[MAT_METAL] = 10,
	[MAT_GRATE] = 10,
	[MAT_CONCRETE] = 10
}
SWEP.HitMaterial = function(self, matType, owner, origin)
	local damage = self.Materials[matType]
	if damage ~= nil then
		local damageInfo = DamageInfo()
		damageInfo:SetInflictor(self)
		damageInfo:SetAttacker(owner)
		damageInfo:SetDamagePosition(origin)
		damageInfo:SetDamage(ceil(owner:Health() * (damage / 100)))
		damageInfo:SetDamageForce(owner:GetAimVector() * -(Jailbreak.PowerfulPlayers and 1000 or 128))
		util.ScreenShake(owner:EyePos(), 12, 120, 0.5, 32)
		if matType == MAT_COMPUTER then
			damageInfo:SetDamageType(DMG_SHOCK)
			if owner:ShockCollarIsEnabled() then
				damageInfo:ScaleDamage(2)
			end
		else
			damageInfo:SetDamageType(DMG_SLASH)
		end
		return owner:TakeDamageInfo(damageInfo)
	end
end
SWEP.OnDrop = function(self)
	return self:Remove()
end
