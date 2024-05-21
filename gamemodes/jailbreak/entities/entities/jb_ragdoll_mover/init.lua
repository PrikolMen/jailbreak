AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
ENT.DoNotDuplicate = true
ENT.DisableDuplicator = true
local mins, maxs = Vector(-1, -1, -1), Vector(1, 1, 1)
ENT.Initialize = function(self)
	self:SetCollisionGroup(12)
	self:PhysicsInitBox(mins, maxs, "dirt")
	self:DrawShadow(false)
	local phys = self:GetPhysicsObject()
	if phys and phys:IsValid() then
		local ragdoll = self.Ragdoll
		if ragdoll and ragdoll:IsValid() then
			return phys:SetMass(ragdoll:GetPhysicsMass())
		end
	end
end
ENT.OnRemove = function(self)
	local owner = self:GetOwner()
	if owner:IsValid() and owner:IsPlayer() and owner:Alive() then
		return owner:DropObject()
	end
end
