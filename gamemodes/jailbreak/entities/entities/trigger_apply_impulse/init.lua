ENT.Type = "brush"
ENT.Base = "base_brush"
ENT.Initialize = function(self)
	self:SetSolid(SOLID_BBOX)
	self:SetTrigger(true)
	self.Entities = { }
end
ENT.StartTouch = function(self, entity)
	self:TriggerOutput("OnStartTouch", entity)
	local _obj_0 = self.Entities
	_obj_0[#_obj_0 + 1] = entity
end
do
	local remove = table.remove
	ENT.EndTouch = function(self, entity)
		local entities = self.Entities
		for index = 1, #entities do
			if entities[index] == entity then
				remove(entities, index)
				break
			end
		end
		return self:TriggerOutput("OnEndTouch", entity)
	end
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
		return func(self, activator, caller, data)
	end
end
do
	local defaultVector = Vector(0, 0, 1)
	local IsValid = IsValid
	ENT.ApplyImpulse = function(self)
		if self.Disabled then
			return
		end
		local _list_0 = self.Entities
		for _index_0 = 1, #_list_0 do
			local entity = _list_0[_index_0]
			if not IsValid(entity) then
				goto _continue_0
			end
			local velocity = (self.ImpulseDir or defaultVector) * (self.Force or 0)
			if entity:IsPlayer() then
				entity:SetVelocity(velocity)
			else
				local phys = entity:GetPhysicsObject()
				if IsValid(phys) then
					phys:ApplyForceCenter(velocity)
				end
			end
			::_continue_0::
		end
	end
end
do
	local Angle = Angle
	ENT.KeyValue = function(self, key, value)
		if "StartDisabled" == key then
			self.Disabled = tobool(value)
		elseif "impulse_dir" == key then
			self.ImpulseDir = Angle(value):Forward()
		elseif "force" == key then
			self.Force = tonumber(value)
		elseif "targetname" == key then
			self.TargetName = value
		elseif "OnStartTouch" == key then
			return self:StoreOutput(key, value)
		end
	end
end
