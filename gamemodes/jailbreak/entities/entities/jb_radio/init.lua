AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
util.AddNetworkString("Jailbreak::Radio")
ENT.Initialize = function(self)
	self:SetModel(self.Model)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	return self:DrawShadow(true)
end
do
	local Start, WriteEntity, Send
	do
		local _obj_0 = net
		Start, WriteEntity, Send = _obj_0.Start, _obj_0.WriteEntity, _obj_0.Send
	end
	ENT.Use = function(self, ply)
		Start("Jailbreak::Radio")
		WriteEntity(self)
		return Send(ply)
	end
end
do
	local ReadEntity, ReadString, ReadFloat
	do
		local _obj_0 = net
		ReadEntity, ReadString, ReadFloat = _obj_0.ReadEntity, _obj_0.ReadString, _obj_0.ReadFloat
	end
	return net.Receive("Jailbreak::Radio", function(_, ply)
		if not (ply and ply:IsValid() and ply:Alive()) then
			return
		end
		local entity = ReadEntity()
		if not (entity and entity:IsValid()) then
			return
		end
		if entity:GetClass() ~= "jb_radio" or entity:GetPos():Distance(ply:GetPos()) > 72 then
			return
		end
		entity:SetURL(ReadString())
		return entity:SetVolume(math.Clamp(ReadFloat(), 0, entity.MaxVolume or 1))
	end)
end
