ENT.Type = "brush"
ENT.Touch = function(self, entity)
	if self.Disabled then
		return
	end
	return entity:Ignite(0.5, 0)
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
	if "StartDisabled" == key then
		self.Disabled = tobool(value)
	end
end
