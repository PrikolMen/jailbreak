ENT.Type = "brush"
ENT.Initialize = function(self)
	return self:SetTrigger(true)
end
ENT.StartTouch = function(self, entity)
	if not (entity:IsPlayer() and entity:Alive() and entity:IsPrisoner()) or entity:IsEscaped() then
		return
	end
	local modelPath = player_manager.TranslatePlayerModel(entity:GetInfo("cl_playermodel"))
	if modelPath == "models/player/kleiner.mdl" then
		if Jailbreak.IsFemalePrison() then
			modelPath = "models/player/group03/female_0" .. math.random(1, 6) .. ".mdl"
		else
			modelPath = "models/player/group03/male_0" .. math.random(1, 9) .. ".mdl"
		end
	end
	entity:SetEscaped(true)
	entity:SetModel(modelPath)
	entity:GiveRandomWeapons(5)
	return
end
