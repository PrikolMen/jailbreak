AddCSLuaFile()
local CLIENT, SERVER = CLIENT, SERVER
local CurTime = CurTime
local Simple = timer.Simple
local random = math.random
SWEP.PrintName = "#jb.hands"
SWEP.Spawnable = false
if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("weapons/jb_hands")
end
SWEP.Slot = 0
SWEP.SlotPos = 4
SWEP.Weight = -5
SWEP.ViewModel = Model("models/weapons/c_arms.mdl")
SWEP.WorldModel = ""
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.DrawWeaponInfoBox = false
SWEP.ViewModelFOV = 60
SWEP.DrawAmmo = false
SWEP.UseHands = true
SWEP.Initialize = function(self)
	return self:SetHoldType("normal")
end
SWEP.SetupDataTables = function(self)
	self:NetworkVar("Float", 0, "NextMeleeAttack")
	self:NetworkVar("Float", 1, "NextIdle")
	return self:NetworkVar("Int", 2, "Combo")
end
do
	local NULL = NULL
	SWEP.GetViewModel = function(self)
		local owner = self:GetOwner()
		if owner:IsValid() then
			return owner:GetViewModel()
		end
		return NULL
	end
end
SWEP.PlaySequence = function(self, sequenceName, onFinish)
	self.SequenceFinished = false
	local owner = self:GetOwner()
	if not (owner:IsValid() and owner:Alive()) then
		return
	end
	local vm = owner:GetViewModel()
	if not vm:IsValid() then
		return
	end
	local seqid = vm:LookupSequence(sequenceName)
	if not (seqid and seqid > 0) then
		return
	end
	vm:SendViewModelMatchingSequence(seqid)
	local duration = vm:SequenceDuration(seqid) / vm:GetPlaybackRate()
	local nextSequence = CurTime() + duration
	Simple(duration, function()
		if not self:IsValid() then
			return
		end
		if self:GetOwner() ~= owner then
			return
		end
		self.SequenceFinished = true
		if onFinish then
			return onFinish(owner, vm)
		end
	end)
	return nextSequence, duration
end
SWEP.SetNextFire = function(self, curTime)
	self:SetNextPrimaryFire(curTime)
	return self:SetNextSecondaryFire(curTime)
end
do
	local swingSound = Sound("WeaponFrag.Throw")
	local PLAYER_ATTACK1 = PLAYER_ATTACK1
	local CHAN_STATIC = CHAN_STATIC
	local seqFinish, delay, combo = 0, 0, 0
	SWEP.PrimaryAttack = function(self, right)
		if self.Pulls then
			return
		end
		if self:GetHoldType() == "normal" then
			if SERVER then
				self:UseDoor(false)
			end
			return
		end
		if self:GetNextIdle() == 0 then
			return
		end
		local owner = self:GetOwner()
		owner:SetAnimation(PLAYER_ATTACK1)
		owner:EmitSound(swingSound, 50, random(80, 120), 1, CHAN_STATIC, 0, 1)
		local anim = "fists_left"
		if right then
			anim = "fists_right"
		end
		combo = self:GetCombo()
		if combo >= 2 then
			anim = "fists_uppercut"
		end
		seqFinish, delay = self:PlaySequence(anim)
		self:SetNextMeleeAttack(CurTime() + (delay / 4) / math.max(combo, 1))
		self:SetNextFire(seqFinish)
		return self:SetNextIdle(seqFinish)
	end
end
SWEP.SecondaryAttack = function(self)
	if self.Pulls then
		return
	end
	if self:GetHoldType() ~= "normal" then
		return self:PrimaryAttack(true)
	elseif SERVER then
		return self:UseDoor(true)
	end
end
SWEP.HitDistance = CreateConVar("jb_hands_distance", "48", bit.bor(FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_DONTRECORD), "Distance of the player's fist punch.", 16, 4096)
do
	local traceResult = { }
	local trace = {
		output = traceResult,
		mask = MASK_SHOT_HULL,
		mins = Vector(-10, -10, -8),
		maxs = Vector(10, 10, 8)
	}
	local hitSound = Sound("Flesh.ImpactHard")
	local TraceHull = util.TraceHull
	SWEP.DealDamage = function(self)
		local owner = self:GetOwner()
		if not (owner:IsValid() and owner:IsPlayer() and owner:Alive()) then
			return
		end
		owner:LagCompensation(true)
		trace.start = owner:GetShootPos()
		trace.endpos = trace.start + owner:GetAimVector() * self.HitDistance:GetInt()
		trace.filter = owner
		TraceHull(trace)
		if traceResult.Hit then
			if not (game.SinglePlayer() and CLIENT) then
				self:EmitSound(hitSound, 70, random(80, 120), 1, CHAN_BODY, 0, 1)
			end
			if SERVER then
				self:HitMaterial(traceResult.MatType, owner, traceResult.HitPos)
			end
		end
		if SERVER then
			self:HitEntity(traceResult.Entity, owner, traceResult.HitPos)
		end
		return owner:LagCompensation(false)
	end
end
SWEP.Show = function(self)
	local vm = self:GetViewModel()
	if vm:IsValid() then
		vm:SetNoDraw(false)
	end
	self:SetHoldType("fist")
	self.PrintName = "#jb.fists"
	self.Pulls = true
	return self:SetNextIdle(self:PlaySequence("fists_draw", function()
		self.Pulls = false
	end))
end
SWEP.Hide = function(self)
	self.Pulls = true
	self:SetNextIdle(0)
	self:SetHoldType("normal")
	self.PrintName = "#jb.hands"
	return self:PlaySequence("fists_holster", function(_, vm)
		vm:SetNoDraw(true)
		self.Pulls = false
	end)
end
SWEP.Deploy = function(self)
	self.SequenceFinished = true
	self:SetNextFire(CurTime() + 1.5)
	self:SetNextMeleeAttack(0)
	self:SetNextIdle(0)
	if self:GetHoldType() == "normal" then
		local vm = self:GetViewModel()
		if vm:IsValid() then
			vm:SetNoDraw(true)
		end
	else
		self:Show()
	end
	if SERVER then
		self:SetCombo(0)
	end
	return true
end
SWEP.Holster = function(self, weapon)
	self:SetNextMeleeAttack(0)
	self:SetNextIdle(0)
	return true
end
local curTime = 0
do
	local idletime, meleetime = 0, 0
	SWEP.Think = function(self)
		if self:GetHoldType() ~= "fist" or self.Pulls then
			return
		end
		curTime = CurTime()
		idletime = self:GetNextIdle()
		if idletime > 0 and curTime > idletime then
			self:SetNextIdle(self:PlaySequence("fists_idle_0" .. random(1, 2)))
		end
		meleetime = self:GetNextMeleeAttack()
		if meleetime > 0 and curTime > meleetime then
			self:SetNextMeleeAttack(0)
			self:DealDamage()
		end
		if SERVER and curTime > self:GetNextPrimaryFire() + 0.1 then
			return self:SetCombo(0)
		end
	end
end
do
	local lastReload
	lastReload, curTime = 0, 0
	SWEP.Reload = function(self)
		lastReload, curTime = self.m_fLastReload or 0, CurTime()
		self.m_fLastReload = curTime
		if (curTime - lastReload) <= 0.25 or self.Pulls then
			return
		end
		if self:GetHoldType() == "normal" then
			self:Show()
			return
		end
		self:Hide()
		return
	end
end
