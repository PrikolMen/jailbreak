ENT.Type = "brush"
ENT.Sound = Sound("Regenerate.Touch")
ENT.Initialize = function(self)
	self:SetTrigger(true)
	self.Players = { }
end
ENT.Regenerate = function(self, ply)
	ply:Heal()
	local _list_0 = ply:GetWeapons()
	for _index_0 = 1, #_list_0 do
		local weapon = _list_0[_index_0]
		local clip1Type = weapon:GetPrimaryAmmoType()
		if clip1Type >= 0 then
			local amount = ply:GetPickupAmmoCount(clip1Type)
			if amount ~= 0 then
				ply:GiveAmmo(amount, clip1Type, false)
			end
		end
		local clip2Type = weapon:GetSecondaryAmmoType()
		if clip2Type >= 0 then
			local amount = ply:GetPickupAmmoCount(clip2Type)
			if amount ~= 0 then
				ply:GiveAmmo(amount, clip2Type, false)
			end
		end
	end
end
ENT.StartTouch = function(self, entity)
	if entity:IsPlayer() and entity:Alive() then
		local _obj_0 = self.Players
		_obj_0[#_obj_0 + 1] = entity
	end
end
ENT.EndTouch = function(self, entity)
	if entity:IsPlayer() then
		return table.RemoveByValue(self.Players, entity)
	end
end
ENT.AssociatedAction = function(self, func)
	local _list_0 = ents.FindByName(self.AssociatedName)
	for _index_0 = 1, #_list_0 do
		local entity = _list_0[_index_0]
		func(entity)
	end
end
ENT.Open = function(self)
	if self.Opened then
		return
	end
	self.Opened = true
	return self:AssociatedAction(function(entity)
		entity:ResetSequence("open")
		return entity:EmitSound(self.Sound, 150)
	end)
end
ENT.Close = function(self)
	if not self.Opened then
		return
	end
	self.Opened = false
	return self:AssociatedAction(function(entity)
		return entity:ResetSequence("close")
	end)
end
ENT.ToggleOpen = function(self)
	if self.Opened then
		return self:Close()
	else
		return self:Open()
	end
end
ENT.Think = function(self)
	if self:IsDisabled() then
		return
	end
	local players = self.Players
	if #players == 0 then
		self:Close()
		return
	end
	for _index_0 = 1, #players do
		local ply = players[_index_0]
		self:Regenerate(ply)
	end
	self:NextThink(CurTime() + 1)
	self:ToggleOpen()
	return true
end
ENT.IsDisabled = function(self)
	return self.Disabled or false
end
ENT.Disable = function(self)
	self.Disabled = true
end
ENT.Enable = function(self)
	self.Disabled = false
end
ENT.Toggle = function(self)
	self.Disabled = not self.Disabled
end
ENT.AcceptInput = function(self, key, activator, caller, data)
	local func = self[key]
	if func then
		return func(self)
	end
end
ENT.KeyValue = function(self, key, value)
	if "associatedmodel" == key then
		self.AssociatedName = value
	elseif "StartDisabled" == key then
		self.Disabled = tobool(value)
	end
end
