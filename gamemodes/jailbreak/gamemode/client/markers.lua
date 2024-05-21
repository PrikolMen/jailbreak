local Jailbreak = Jailbreak
local Markers, MarkersLifetime = Jailbreak.Markers, Jailbreak.MarkersLifetime
local SetMaterial, DrawSprite
do
	local _obj_0 = render
	SetMaterial, DrawSprite = _obj_0.SetMaterial, _obj_0.DrawSprite
end
local max, sin, Rand
do
	local _obj_0 = math
	max, sin, Rand = _obj_0.max, _obj_0.sin, _obj_0.Rand
end
local Material = Material
local CurTime = CurTime
local remove = table.remove
local EyePos = EyePos
local find = string.find
local TEAM_PRISONER = TEAM_PRISONER
local TEAM_GUARD = TEAM_GUARD
local UserOrangeIcon = Material("icon16/user_orange.png")
local UserSuitIcon = Material("icon16/user_suit.png")
local UserIcon = Material("icon16/user.png")
local BricksIcon = Material("icon16/bricks.png")
local OrangeFlagIcon = Material("icon16/flag_orange.png")
local BlueFlagIcon = Material("icon16/flag_blue.png")
local DoorIcon = Material("icon16/door.png")
local ImageIcon = Material("icon16/image.png")
local PhotoIcon = Material("icon16/photo.png")
local GunIcon = Material("icon16/gun.png")
local ErrorIcon = Material("icon16/error.png")
local PaintCanIcon = Material("icon16/paintcan.png")
local markers = { }
local classNames = {
	["class C_BaseEntity"] = Material("icon16/keyboard.png"),
	sent_soccerball = Material("icon16/sport_basketball.png"),
	prop_ragdoll = Material("icon16/user_delete.png"),
	prop_combine_ball = ErrorIcon,
	npc_grenade_frag = ErrorIcon,
	npc_satchel = ErrorIcon,
	crossbow_bolt = ErrorIcon,
	grenade_ar2 = ErrorIcon,
	npc_tripmine = ErrorIcon
}
do
	local ReadEntity, ReadBool, ReadVector
	do
		local _obj_0 = net
		ReadEntity, ReadBool, ReadVector = _obj_0.ReadEntity, _obj_0.ReadBool, _obj_0.ReadVector
	end
	net.Receive("Jailbreak::Markers", function()
		local owner = ReadEntity()
		if not (owner:IsValid() and owner:Alive()) then
			return
		end
		local material = owner:IsPrisoner() and OrangeFlagIcon or BlueFlagIcon
		local entity = nil
		if ReadBool() then
			entity = ReadEntity()
			if entity and entity:IsValid() then
				if entity:IsPaintCan() then
					material = PaintCanIcon
				elseif entity:IsWeapon() then
					if entity:GetOwner():IsValid() then
						return
					end
					material = GunIcon
				elseif entity:IsPlayer() then
					if entity:IsLocalPlayer() then
						return
					end
					if not entity:Alive() then
						return
					end
					local _exp_0 = entity:Team()
					if TEAM_GUARD == _exp_0 then
						material = UserSuitIcon
					elseif TEAM_PRISONER == _exp_0 then
						material = UserOrangeIcon
					else
						material = UserIcon
					end
				else
					local className = entity:GetClass()
					local classIcon = classNames[className]
					if classIcon then
						material = classIcon
					elseif find(className, "^func_breakable", 1, false) then
						material = ImageIcon
					elseif find(className, "^%w+_door", 1, false) then
						material = DoorIcon
					elseif find(className, "^prop_physics.*", 1, false) then
						material = PhotoIcon
					else
						material = BricksIcon
					end
				end
			end
		end
		markers[#markers + 1] = {
			deathtime = CurTime() + MarkersLifetime:GetInt(),
			amplitude = Rand(0.5, 1.5),
			origin = ReadVector(),
			material = material,
			entity = entity,
			owner = owner
		}
	end)
end
do
	local proxyVector, eyePos = Vector()
	hook.Add("HUDPaint3D", "Jailbreak::Markers", function()
		if not Markers:GetBool() then
			return
		end
		eyePos = EyePos()
		for index = 1, #markers do
			local data = markers[index]
			if not data then
				goto _continue_0
			end
			local owner = data.owner
			if not owner:IsValid() then
				remove(markers, index)
				goto _continue_0
			end
			local fraction = max(0, (data.deathtime - CurTime()) / MarkersLifetime:GetInt())
			if fraction == 0 then
				remove(markers, index)
				goto _continue_0
			end
			local origin = data.origin
			local entity = data.entity
			if entity then
				if entity:IsValid() then
					if (entity:IsPlayer() and not entity:Alive()) or (entity:IsWeapon() and entity:GetOwner():IsValid()) then
						remove(markers, index)
						goto _continue_0
					end
					origin = entity:LocalToWorld(origin)
				else
					remove(markers, index)
					goto _continue_0
				end
			end
			local scale = max(4, (origin:Distance(eyePos) / Jailbreak.ScreenWidth) * 64) * fraction
			local amplitude = data.amplitude
			proxyVector[1] = origin[1]
			proxyVector[2] = origin[2]
			proxyVector[3] = origin[3] + 1 + sin(CurTime() * (4 + amplitude)) * (1.5 + amplitude) * fraction
			SetMaterial(data.material)
			DrawSprite(proxyVector, scale, scale, white)
			::_continue_0::
		end
	end)
end
do
	local IN_WALK = IN_WALK
	return hook.Add("PreventScreenClicks", "Jailbreak::Markers", function()
		local ply = Jailbreak.Player
		if ply:IsValid() and ply:KeyDown(IN_WALK) then
			return true
		end
	end)
end
