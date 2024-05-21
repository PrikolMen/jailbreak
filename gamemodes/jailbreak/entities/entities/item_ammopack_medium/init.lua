AddCSLuaFile("cl_init.lua")
local ceil = math.ceil
ENT.Base = "item_base"
ENT.Model = "models/items/ammopack_medium.mdl"
ENT.Sound = Sound("AmmoPack.Touch")
ENT.Ammo = 0.5
ENT.PlayerGotItem = function(self, ply)
	local gived = false
	local _list_0 = ply:GetWeapons()
	for _index_0 = 1, #_list_0 do
		local weapon = _list_0[_index_0]
		if weapon:Clip1() ~= -1 then
			local clip1Type = weapon:GetPrimaryAmmoType()
			if clip1Type >= 0 then
				local amount = ply:GetPickupAmmoCount(clip1Type)
				if amount ~= 0 then
					ply:GiveAmmo(ceil(amount * self.Ammo), clip1Type, false)
					gived = true
				end
			end
		end
		if weapon:Clip2() ~= -1 then
			local clip2Type = weapon:GetSecondaryAmmoType()
			if clip2Type >= 0 then
				local amount = ply:GetPickupAmmoCount(clip2Type)
				if amount ~= 0 then
					ply:GiveAmmo(ceil(amount * self.Ammo), clip2Type, false)
					gived = true
				end
			end
		end
	end
	return gived
end
