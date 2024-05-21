ENT.Type = "brush"
ENT.Initialize = function(self)
	self:SetCustomCollisionCheck(true)
	self:PhysicsInit(SOLID_BSP)
	return self:SetMoveType(MOVETYPE_NONE)
end
ENT.IsDisabled = function(self)
	return self:GetNW2Bool("disabled")
end
ENT.SetDisabled = function(self, bool)
	return self:SetNW2Bool("disabled", bool)
end
ENT.KeyValue = function(self, key, value)
	if "respawnroomname" == key then
		self.RoomName = value
		return timer.Simple(0.25, function()
			if not self:IsValid() then
				return
			end
			local entities = ents.FindByName(value)
			if #entities == 0 then
				return
			end
			return self:SetTeam(entities[1]:Team())
		end)
	elseif "StartDisabled" == key then
		return self:SetDisabled(tobool(value))
	end
end
ENT.Disable = function(self)
	return self:SetDisabled(true)
end
ENT.Enable = function(self)
	return self:SetDisabled(false)
end
ENT.Toggle = function(self)
	return self:SetDisabled(not self:GetDisabled())
end
ENT.AcceptInput = function(self, key, activator, caller, data)
	local func = self[key]
	if func then
		return func(self)
	end
end
