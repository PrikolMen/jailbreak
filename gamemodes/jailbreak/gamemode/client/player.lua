local Alive, IsPlayingTaunt
do
	local _obj_0 = PLAYER
	Alive, IsPlayingTaunt = _obj_0.Alive, _obj_0.IsPlayingTaunt
end
local Jailbreak = Jailbreak
local FrameTime = FrameTime
local drive = drive
local Run = hook.Run
local GM = GM
GM.ShouldDrawLocalPlayer = function(self, ply)
	if ply ~= Jailbreak.ViewEntity then
		if Jailbreak.PlayingTaunt then
			Jailbreak.PlayingTaunt = false
		end
		return true
	end
	if IsPlayingTaunt(ply) and Alive(ply) then
		Jailbreak.PlayingTaunt = true
		return true
	end
	Jailbreak.PlayingTaunt = false
	return Jailbreak.TauntFraction > 0
end
do
	local LookupBone, GetBonePosition
	do
		local _obj_0 = ENTITY
		LookupBone, GetBonePosition = _obj_0.LookupBone, _obj_0.GetBonePosition
	end
	local LerpVector = LerpVector
	local LerpAngle = LerpAngle
	local TraceHull = util.TraceHull
	local CalcView = drive.CalcView
	local Forward = ANGLE.Forward
	local traceResult = { }
	local trace = {
		mins = Vector(-8, -8, -8),
		maxs = Vector(8, 8, 8),
		output = traceResult,
		mask = MASK_SHOT
	}
	local view = Jailbreak.PlayerView
	if not istable(view) then
		view = { }
		Jailbreak.PlayerView = view
	end
	local boneID = 0
	GM.CalcView = function(self, ply, origin, angles, fov, znear, zfar)
		view.origin = origin
		view.angles = angles
		view.fov = fov
		view.znear = znear
		view.zfar = zfar
		view.drawviewer = false
		if CalcView(ply, view) then
			return view
		end
		local entity = nil
		if Alive(ply) then
			if ply:IsLoseConsciousness() then
				if Jailbreak.TauntViewAngles then
					Jailbreak.TauntViewAngles = nil
				end
				if Jailbreak.TauntDistance then
					Jailbreak.TauntDistance = nil
				end
				if Jailbreak.TauntEyeAngles then
					Jailbreak.TauntEyeAngles = nil
				end
				entity = ply:GetRagdollEntity()
				if not entity:IsValid() then
					return view
				end
				local attachmentID = entity:LookupAttachment("eyes")
				if attachmentID >= 0 then
					local attachment = entity:GetAttachment(attachmentID)
					if attachment then
						view.origin = attachment.Pos
						view.angles = attachment.Ang
					end
				end
				view.drawviewer = false
				return view
			end
		else
			entity = ply:GetObserverTarget()
		end
		if not (entity and entity:IsValid()) then
			entity = ply:GetViewEntity()
		end
		if not (entity and entity:IsValid()) then
			entity = ply
		end
		Jailbreak.ViewEntity = entity
		if ply ~= entity then
			if Jailbreak.TauntViewAngles then
				Jailbreak.TauntViewAngles = nil
			end
			if Jailbreak.TauntDistance then
				Jailbreak.TauntDistance = nil
			end
			if Jailbreak.TauntEyeAngles then
				Jailbreak.TauntEyeAngles = nil
			end
			return view
		end
		if not Alive(ply) then
			if Jailbreak.TauntViewAngles then
				Jailbreak.TauntViewAngles = nil
			end
			if Jailbreak.TauntDistance then
				Jailbreak.TauntDistance = nil
			end
			if Jailbreak.TauntEyeAngles then
				Jailbreak.TauntEyeAngles = nil
			end
			return view
		end
		if entity:Health() < 1 then
			if Jailbreak.TauntViewAngles then
				Jailbreak.TauntViewAngles = nil
			end
			if Jailbreak.TauntDistance then
				Jailbreak.TauntDistance = nil
			end
			if Jailbreak.TauntEyeAngles then
				Jailbreak.TauntEyeAngles = nil
			end
			local attachmentID = entity:LookupAttachment("eyes")
			if attachmentID >= 0 then
				local attachment = entity:GetAttachment(attachmentID)
				if attachment then
					view.origin = attachment.Pos
					view.angles = attachment.Ang
				end
			end
			view.drawviewer = true
			return view
		end
		if Jailbreak.PlayingTaunt or Jailbreak.TauntFraction > 0 then
			local viewAngles = Jailbreak.TauntViewAngles
			if not viewAngles then
				viewAngles = angles
				viewAngles[1], viewAngles[3] = 0, 0
				Jailbreak.TauntViewAngles = viewAngles
			end
			local distance = Jailbreak.TauntDistance
			if not distance then
				distance = 128
				Jailbreak.TauntDistance = distance
			end
			boneID = LookupBone(ply, "ValveBiped.Bip01_Head1")
			if boneID and boneID >= 0 then
				origin = GetBonePosition(ply, boneID)
			end
			local targetOrigin = origin - Forward(viewAngles) * distance
			trace.start = origin
			trace.endpos = targetOrigin
			trace.filter = entity
			TraceHull(trace)
			targetOrigin = traceResult.HitPos + traceResult.HitNormal
			local eyeAngles = Jailbreak.TauntEyeAngles
			if not eyeAngles then
				eyeAngles = Angle(viewAngles)
				Jailbreak.TauntEyeAngles = eyeAngles
			end
			local fraction = Jailbreak.TauntFraction
			if Jailbreak.PlayingTaunt then
				if fraction < 1 then
					fraction = fraction + (FrameTime() * 4)
					Jailbreak.TauntFraction = fraction
					view.origin = LerpVector(fraction, origin, targetOrigin)
					view.angles = LerpAngle(fraction, eyeAngles, viewAngles)
					return view
				end
			elseif fraction > 0 then
				fraction = fraction - (FrameTime() * 2)
				Jailbreak.TauntFraction = fraction
				view.origin = LerpVector(fraction, origin, targetOrigin)
				view.angles = LerpAngle(fraction, eyeAngles, viewAngles)
				return view
			end
			view.origin = targetOrigin
			view.angles = viewAngles
			return view
		end
		if Jailbreak.TauntViewAngles then
			Jailbreak.TauntViewAngles = nil
		end
		if Jailbreak.TauntDistance then
			Jailbreak.TauntDistance = nil
		end
		if Jailbreak.TauntEyeAngles then
			Jailbreak.TauntEyeAngles = nil
		end
		if ply:InVehicle() then
			return Run("CalcVehicleView", ply:GetVehicle(), ply, view)
		end
		local weapon = ply:GetActiveWeapon()
		if weapon and weapon:IsValid() then
			local func = weapon.CalcView
			if func then
				origin, angles, fov = func(weapon, ply, Vector(view.origin), Angle(view.angles), view.fov)
				view.origin, view.angles, view.fov = origin or view.origin, angles or view.angles, fov or view.fov
			end
		end
		return view
	end
end
do
	local SetViewAngles, GetMouseX, GetMouseY, GetMouseWheel
	do
		local _obj_0 = CUSERCMD
		SetViewAngles, GetMouseX, GetMouseY, GetMouseWheel = _obj_0.SetViewAngles, _obj_0.GetMouseX, _obj_0.GetMouseY, _obj_0.GetMouseWheel
	end
	local CreateMove = drive.CreateMove
	local Clamp = math.Clamp
	local frameTime = 0
	GM.CreateMove = function(self, cmd)
		if CreateMove(cmd) then
			return true
		end
		if Jailbreak.PlayingTaunt then
			local viewAngles = Jailbreak.TauntViewAngles
			if viewAngles then
				frameTime = FrameTime()
				local _update_0 = 1
				viewAngles[_update_0] = viewAngles[_update_0] + (GetMouseY(cmd) * frameTime)
				local _update_1 = 2
				viewAngles[_update_1] = viewAngles[_update_1] - (GetMouseX(cmd) * frameTime)
			end
			local distance = Jailbreak.TauntDistance
			if distance then
				Jailbreak.TauntDistance = Clamp(distance - GetMouseWheel(cmd) * (distance * 0.1), 16, 1024)
			end
			local eyeAngles = Jailbreak.TauntEyeAngles
			if eyeAngles then
				SetViewAngles(cmd, eyeAngles)
				return
			end
		end
	end
end
GM.PreDrawViewModel = function(self, vm, ply, weapon)
	local func = weapon.PreDrawViewModel
	if func == nil then
		return false
	end
	return func(weapon, vm, weapon, ply)
end
do
	local MATERIAL_CULLMODE_CCW = MATERIAL_CULLMODE_CCW
	local MATERIAL_CULLMODE_CW = MATERIAL_CULLMODE_CW
	local DrawModel = ENTITY.DrawModel
	local GetHands = PLAYER.GetHands
	local CullMode = render.CullMode
	GM.PostDrawViewModel = function(self, vm, ply, weapon)
		if weapon.UseHands or not weapon:IsScripted() then
			local hands = GetHands(ply)
			if hands and hands:IsValid() and hands:GetParent():IsValid() then
				if not Run("PreDrawPlayerHands", hands, vm, ply, weapon) then
					if weapon.ViewModelFlip then
						CullMode(MATERIAL_CULLMODE_CW)
					end
					DrawModel(hands)
					CullMode(MATERIAL_CULLMODE_CCW)
				end
				Run("PostDrawPlayerHands", hands, vm, ply, weapon)
			end
		end
		local func = weapon.PostDrawViewModel
		if func == nil then
			return false
		end
		return func(weapon, vm, weapon, ply)
	end
end
do
	local HandsTransparency = Jailbreak.HandsTransparency
	local handsAlpha = 1 - HandsTransparency:GetFloat()
	local tonumber = tonumber
	local SetBlend = render.SetBlend
	cvars.AddChangeCallback(HandsTransparency:GetName(), function(_, __, value)
		handsAlpha = 1 - (tonumber(value) or 0)
	end, "Jailbreak::HandsTransparency")
	GM.PreDrawPlayerHands = function(self)
		return SetBlend(handsAlpha)
	end
	GM.PostDrawPlayerHands = function(self)
		return SetBlend(1)
	end
end
