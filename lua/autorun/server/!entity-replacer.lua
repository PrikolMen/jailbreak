local Create, Iterator
do
	local _obj_0 = ents
	Create, Iterator = _obj_0.Create, _obj_0.Iterator
end
local isfunction = isfunction
local Add, Remove
do
	local _obj_0 = hook
	Add, Remove = _obj_0.Add, _obj_0.Remove
end
local isstring = isstring
local IsValid = IsValid
local Simple = timer.Simple
local assert = assert
local find = string.find
local _class_0
local _base_0 = {
	Perform = function(self, entity)
		if not (entity:IsValid() and find(entity:GetClass(), self.Pattern, 1, false) ~= nil) then
			return
		end
		local filter = self.Filter
		if filter ~= nil and not filter(entity, self) then
			return
		end
		local newEntity = Create(self.ClassName)
		if not IsValid(newEntity) then
			return
		end
		newEntity:SetPos(entity:WorldSpaceCenter())
		newEntity:SetAngles(entity:GetAngles())
		local init = self.Init
		if init ~= nil then
			init(newEntity, entity, self)
		end
		newEntity:Spawn()
		local _list_0 = entity:GetBodyGroups()
		for _index_0 = 1, #_list_0 do
			local bodygroup = _list_0[_index_0]
			newEntity:SetBodygroup(bodygroup.id, entity:GetBodygroup(bodygroup.id))
		end
		newEntity:SetFlexScale(entity:GetFlexScale())
		for flexID = 0, entity:GetFlexNum() do
			newEntity:SetFlexWeight(flexID, entity:GetFlexWeight(flexID))
		end
		newEntity:SetPlayerColor(entity:GetPlayerColor())
		newEntity:SetMaterial(entity:GetMaterial())
		newEntity:SetColor(entity:GetColor())
		newEntity:SetSkin(entity:GetSkin())
		for index = 1, #entity:GetMaterials() do
			local materialPath = entity:GetSubMaterial(index)
			if materialPath ~= "" then
				newEntity:SetSubMaterial(index, materialPath)
			end
		end
		newEntity:SetCollisionGroup(entity:GetCollisionGroup())
		for bone = 0, entity:GetBoneCount() - 1 do
			newEntity:ManipulateBonePosition(bone, entity:GetManipulateBonePosition(bone))
			newEntity:ManipulateBoneAngles(bone, entity:GetManipulateBoneAngles(bone))
			newEntity:ManipulateBoneJiggle(bone, entity:GetManipulateBoneJiggle(bone))
			newEntity:ManipulateBoneScale(bone, entity:GetManipulateBoneScale(bone))
		end
		if newEntity:IsRagdoll() then
			for physNum = 0, newEntity:GetPhysicsObjectCount() - 1 do
				local phys = newEntity:GetPhysicsObjectNum(physNum)
				if not IsValid(phys) then
					goto _continue_0
				end
				local bone = newEntity:TranslatePhysBoneToBone(physNum)
				if bone and bone >= 0 then
					local origin, angles = entity:GetBonePosition(bone)
					phys:SetAngles(angles)
					phys:SetPos(origin)
				end
				local phys2 = entity:GetPhysicsObjectNum(physNum)
				if IsValid(phys2) then
					phys:SetVelocity(phys2:GetVelocity())
					if phys2:IsAsleep() then
						phys:Sleep()
					else
						phys:Wake()
					end
				end
				::_continue_0::
			end
		else
			local phys, phys2 = newEntity:GetPhysicsObject(), entity:GetPhysicsObject()
			if IsValid(phys) and IsValid(phys2) then
				phys:SetVelocity(phys2:GetVelocity())
				if phys2:IsAsleep() then
					phys:Sleep()
				else
					phys:Wake()
				end
			end
		end
		return entity:Remove()
	end,
	PerformAll = function(self)
		for _, entity in Iterator() do
			self:Perform(entity)
		end
	end,
	Remove = function(self)
		local className = self.ClassName
		Remove("OnEntityCreated", "EntityReplacer::" .. className)
		return Remove("PostCleanupMap", "EntityReplacer::" .. className)
	end
}
if _base_0.__index == nil then
	_base_0.__index = _base_0
end
_class_0 = setmetatable({
	__init = function(self, pattern, className, filter, init)
		assert(isstring(pattern), "Second argument must be a 'string'!")
		self.Pattern = pattern
		assert(isstring(className), "Third argument must be a 'string'!")
		self.ClassName = className
		if isfunction(filter) then
			self.Filter = filter
		end
		if isfunction(init) then
			self.Init = init
		end
		Add("PostCleanupMap", "EntityReplacer::" .. className, function()
			return self:PerformAll()
		end)
		return Add("OnEntityCreated", "EntityReplacer::" .. className, function(entity)
			return Simple(0.25, function()
				if entity:IsValid() then
					return self:Perform(entity)
				end
			end)
		end)
	end,
	__base = _base_0,
	__name = "EntityReplacer"
}, {
	__index = _base_0,
	__call = function(cls, ...)
		local _self_0 = setmetatable({ }, _base_0)
		cls.__init(_self_0, ...)
		return _self_0
	end
})
_base_0.__class = _class_0
EntityReplacer = _class_0
