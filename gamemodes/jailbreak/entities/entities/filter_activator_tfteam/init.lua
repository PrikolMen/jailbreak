ENT.Base = "base_filter"
ENT.Initialize = function(self)
	self.Negated = false
end
ENT.PassesFilter = function(self, entity, ply)
	if not (IsValid(ply) and ply:IsPlayer() and ply:Alive()) then
		return false
	end
	local requestedTeam = self.TeamNum
	if not requestedTeam then
		return self.Negated
	end
	if requestedTeam == ply:Team() then
		return not self.Negated
	end
	if ply:HasSecurityKeys() and requestedTeam == TEAM_GUARD then
		return not self.Negated
	end
	return self.Negated
end
ENT.KeyValue = function(self, key, value)
	if "Negated" == key then
		self.Negated = tobool(value)
	elseif "TeamNum" == key then
		self.TeamNum = Jailbreak.TF2Team(tonumber(value) or 0)
	end
end
ENT.AcceptInput = function(self, key, _, __, value)
	if key == "SetTeam" then
		self.TeamNum = Jailbreak.TF2Team(tonumber(value) or 0)
	end
end
