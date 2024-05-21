AddCSLuaFile("cl_init.lua")
ENT.Base = "item_base"
ENT.Model = "models/items/medkit_medium.mdl"
ENT.Sound = Sound("HealthKit.Touch")
ENT.Healing = 0.5
ENT.PlayerGotItem = function(self, ply)
	if ply:Health() >= ply:GetMaxHealth() then
		return
	end
	local maxHealth = ply:GetMaxHealth()
	ply:SetHealth(math.Clamp(ply:Health() + math.floor(maxHealth * self.Healing), 0, maxHealth))
	return true
end
