local vector_origin = vector_origin
local LocalToWorld = LocalToWorld
local angle_zero = angle_zero
local Register = weapons.Register
local isstring = isstring
local isvector = isvector
local isangle = isangle
local istable = istable
local SERVER = SERVER
local assert = assert
local Create = ents.Create
local Set = list.Set
local Handlers = WeaponHandlers
if not istable(Handlers) then
	Handlers = { }
	WeaponHandlers = Handlers
end
local TemporaryWeapon = {
	WorldModel = "models/weapons/w_smg1.mdl",
	ViewModel = "models/weapons/c_smg1.mdl",
	IsTemporaryWeapon = true,
	Base = "weapon_base",
	Spawnable = false
}
if SERVER then
	TemporaryWeapon.Deploy = function(self)
		self:Remove()
		return false
	end
	TemporaryWeapon.Initialize = function(self)
		local handler = Handlers[self:GetClass()]
		if not handler then
			self:Remove()
			return
		end
		local className = handler.Alternative
		local spawnOffsets = handler.SpawnOffsets
		if istable(spawnOffsets) then
			spawnOffsets = spawnOffsets[className]
			if not istable(spawnOffsets) then
				spawnOffsets = nil
			end
		else
			spawnOffsets = nil
		end
		return timer.Simple(0, function()
			if not (self:IsValid() and not self:GetOwner():IsValid()) then
				return
			end
			local entity = Create(className)
			if not entity:IsValid() then
				return
			end
			local origin, angles = self:GetPos(), self:GetAngles()
			if spawnOffsets ~= nil then
				origin, angles = LocalToWorld(spawnOffsets[1], spawnOffsets[2], origin, angles)
			end
			entity:SetPos(origin)
			entity:SetAngles(angles)
			entity:AddFlags(self:GetFlags())
			entity:AddEFlags(self:GetEFlags())
			entity:AddSolidFlags(self:GetSolidFlags())
			entity:Spawn()
			entity:Activate()
			entity:SetCollisionGroup(self:GetCollisionGroup())
			entity:SetMoveType(self:GetMoveType())
			entity:SetNoDraw(self:GetNoDraw())
			entity:SetColor(self:GetColor())
			local oldPhys, newPhys = self:GetPhysicsObject(), entity:GetPhysicsObject()
			if oldPhys and oldPhys:IsValid() and newPhys and newPhys:IsValid() then
				newPhys:EnableMotion(oldPhys:IsMotionEnabled())
				newPhys:SetVelocity(oldPhys:GetVelocity())
				if oldPhys:IsAsleep() then
					newPhys:Sleep()
				else
					newPhys:Wake()
				end
			end
			self:SetParent(entity)
			return self:SetNotSolid(true)
		end)
	end
	TemporaryWeapon.Equip = function(self, owner)
		local weapon = self:GetParent()
		if weapon:IsValid() and weapon:IsWeapon() then
			owner:PickupWeapon(weapon, false)
		end
		return self:Remove()
	end
	TemporaryWeapon.OnRemove = function(self)
		local parent = self:GetParent()
		if parent:IsValid() and not parent:GetOwner():IsValid() then
			return parent:Remove()
		end
	end
end
if CLIENT then
	TemporaryWeapon.DrawWorldModel = function() end
	TemporaryWeapon.Deploy = function(self)
		return false
	end
end
do
	local _class_0
	local _base_0 = {
		Weapons = list.GetForEdit("Weapon"),
		Exists = function(self, className)
			return istable(self.Weapons[className])
		end,
		GetClassSpawnOffsets = function(self, className)
			return self.SpawnOffsets[className]
		end,
		SetClassSpawnOffsets = function(self, className, vector, angles)
			if not isvector(vector) then
				vector = vector_origin
			end
			if not isangle(angles) then
				angles = angle_zero
			end
			self.SpawnOffsets[className] = {
				vector,
				angles
			}
		end,
		SetClassSpawnOffsets = function(self, value)
			assert(istable(value), "Second argument must be a 'table'!")
			self.SpawnOffsets = value
		end,
		Register = function(self)
			if not self.Registered then
				local className = self.ClassName
				Register(TemporaryWeapon, className)
				Set("Weapon", className, nil)
				self.Registered = true
			end
		end,
		AddAlternative = function(self, className)
			if not self.Registered and self:Exists(className) then
				self.Alternative = className
				return self:Register()
			end
		end,
		AddAlternatives = function(self, alternatives)
			assert(istable(alternatives), "Second argument must be a 'table'!")
			for _index_0 = 1, #alternatives do
				local className = alternatives[_index_0]
				if self.Registered then
					break
				end
				self:AddAlternative(className)
			end
		end
	}
	if _base_0.__index == nil then
		_base_0.__index = _base_0
	end
	_class_0 = setmetatable({
		__init = function(self, className, alternative, spawnOffsets, force)
			assert(isstring(className), "Second argument must be a 'string'!")
			Handlers[className] = self
			self.ClassName = className
			self.Registered = self:Exists(className) and not force
			if self.Registered then
				return
			end
			if isstring(alternative) then
				self:AddAlternative(alternative)
			elseif istable(alternative) then
				self:AddAlternatives(alternative)
			end
			if istable(spawnOffsets) then
				self.SpawnOffsets = spawnOffsets
			else
				self.SpawnOffsets = { }
			end
		end,
		__base = _base_0,
		__name = "WeaponHandler"
	}, {
		__index = _base_0,
		__call = function(cls, ...)
			local _self_0 = setmetatable({ }, _base_0)
			cls.__init(_self_0, ...)
			return _self_0
		end
	})
	_base_0.__class = _class_0
	WeaponHandler = _class_0
end
if SERVER then
	hook.Add("PlayerCanPickupWeapon", "WeaponHandler::Block temporary weapon pickup", function(self, weapon)
		if weapon.IsTemporaryWeapon then
			return false
		end
	end)
	hook.Add("AllowPlayerPickup", "WeaponHandler::Block temporary weapon pickup", function(self, weapon)
		if weapon.IsTemporaryWeapon then
			return false
		end
	end)
	return hook.Add("WeaponEquip", "WeaponHandler::Remove temporary weapon on real weapon pickup", function(self, owner)
		if self.IsTemporaryWeapon then
			return
		end
		local _list_0 = self:GetChildren()
		for _index_0 = 1, #_list_0 do
			local weapon = _list_0[_index_0]
			if weapon:IsValid() and weapon.IsTemporaryWeapon then
				weapon:Remove()
			end
		end
	end)
end
