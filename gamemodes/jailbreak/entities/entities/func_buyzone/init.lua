ENT.Type = "brush"
ENT.Initialize = function(self)
	return self:SetTrigger(true)
end
ENT.StartTouch = function(self, entity)
	if entity:IsPlayer() and entity:Alive() then
		return entity:SetNW2Bool("in-buy-zone", true)
	end
end
ENT.EndTouch = function(self, entity)
	if entity:IsPlayer() then
		return entity:SetNW2Bool("in-buy-zone", false)
	end
end
