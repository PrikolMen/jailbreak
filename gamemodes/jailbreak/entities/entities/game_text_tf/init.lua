ENT.Type = "point"
local HUD_PRINTCENTER = HUD_PRINTCENTER
local tonumber = tonumber
ENT.Display = function(self)
	local message = self:GetInternalVariable("message")
	if not message then
		return
	end
	local teamID = self:GetInternalVariable("display_to_team")
	if not teamID then
		PrintMessage(HUD_PRINTCENTER, message)
		return
	end
	teamID = Jailbreak.TF2Team(tonumber(teamID) or 0)
	for _, ply in player.Iterator() do
		if ply:Team() == teamID and not ply:IsBot() then
			ply:PrintMessage(HUD_PRINTCENTER, message)
		end
	end
end
ENT.AcceptInput = function(self, key, activator, caller, data)
	local func = self[key]
	if func then
		return func(self)
	end
end
