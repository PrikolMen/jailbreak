ENT.Type = "brush"
local TF2Team = Jailbreak.TF2Team
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
	if "targetname" == key then
		self.Targets = value
	elseif "TeamNum" == key then
		return self:SetTeam(TF2Team(tonumber(value) or 0))
	elseif "StartDisabled" == key then
		self.Disabled = tobool(value)
	end
end
