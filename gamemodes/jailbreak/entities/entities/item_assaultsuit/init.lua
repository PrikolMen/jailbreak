ENT.Type = "point"
ENT.Think = function(self)
	local _list_0 = ents.FindInSphere(self:GetPos(), 16)
	for _index_0 = 1, #_list_0 do
		local entity = _list_0[_index_0]
		if entity:IsPlayer() and entity:Alive() then
			local amount = entity:IsWarden() and 100 or 50
			if entity:Armor() < amount then
				entity:SetArmor(math.min(amount, entity:GetMaxArmor()))
				self:Remove()
				break
			end
		end
	end
end
