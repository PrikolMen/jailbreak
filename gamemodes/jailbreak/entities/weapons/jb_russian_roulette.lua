local CHAN_STATIC = CHAN_STATIC
local CurTime = CurTime
local SERVER = SERVER
local random = math.random
if SERVER then
	AddCSLuaFile()
end
SWEP.PrintName = "#jb.jb_russian_roulette"
SWEP.DrawWeaponInfoBox = false
SWEP.DrawCrosshair = false
SWEP.Spawnable = true
SWEP.DrawAmmo = true
SWEP.SlotPos = 10
SWEP.Weight = -2
SWEP.Slot = 0
SWEP.ViewModel = "models/weapons/v_357.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"
SWEP.UseHands = true
SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Initialize = function(self)
	return self:SecondaryAttack()
end
SWEP.PrimaryAttack = function(self)
	self:SetNextSecondaryFire(CurTime() + 0.5)
	self:SetNextPrimaryFire(CurTime() + 0.5)
	local owner = self:GetOwner()
	if not (owner:IsValid() and owner:Alive()) then
		return
	end
	local clip1 = self:Clip1()
	if clip1 < 1 then
		self:EmitSound("weapons/pistol/pistol_empty.wav", 80, random(90, 110), 1, CHAN_STATIC, 0, 1)
		return
	end
	self:SetClip1(clip1 - 1)
	if clip1 ~= self:GetNW2Int("bullet-number") then
		self:EmitSound("weapons/pistol/pistol_empty.wav", 75, random(80, 120), 0.8, CHAN_STATIC, 0, 1)
		return
	end
	owner:EmitSound("vo/npc/" .. (owner:IsFemaleModel() and "fe" or "") .. "male01/no0" .. random(1, 2) .. ".wav", 75, random(90, 110), 1, CHAN_STATIC, 0, 1)
	self:EmitSound("weapons/357/357_fire" .. random(2, 3) .. ".wav", 75, random(80, 120), 1, CHAN_STATIC, 0, 1)
	if SERVER then
		local damageInfo = DamageInfo()
		damageInfo:SetDamagePosition(owner:EyePos())
		damageInfo:SetDamage(owner:Health() + owner:Armor() + 1)
		damageInfo:SetDamageForce(owner:GetAngles():Right() * 1000)
		damageInfo:SetDamageType(DMG_BULLET)
		damageInfo:SetAttacker(owner)
		damageInfo:SetInflictor(self)
		return owner:TakeDamageInfo(damageInfo)
	end
end
SWEP.SecondaryAttack = function(self)
	self:SetNextSecondaryFire(CurTime() + 1.5)
	self:SetNextPrimaryFire(CurTime() + 0.25)
	if SERVER then
		self:SetClip1(6)
		self:SetNW2Int("bullet-number", random(1, 6))
	end
	return self:EmitSound("weapons/357/357_spin1.wav", 75, random(90, 110), 1, CHAN_STATIC, 0, 1)
end
