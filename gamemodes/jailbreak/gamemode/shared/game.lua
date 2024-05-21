local ENTITY, PLAYER = ENTITY, PLAYER
local Jailbreak = Jailbreak
local GM = GM
local GetClass, GetTable, WaterLevel, IsOnGround, IsValid, GetNW2Bool, IsFlagSet = ENTITY.GetClass, ENTITY.GetTable, ENTITY.WaterLevel, ENTITY.IsOnGround, ENTITY.IsValid, ENTITY.GetNW2Bool, ENTITY.IsFlagSet
local Length = VECTOR.Length
local Alive = PLAYER.Alive
local CLIENT = CLIENT
local Run = hook.Run
local TEAM_GUARD = TEAM_GUARD
do
	local IsRoundPreparing, GuardsFriendlyFire = Jailbreak.IsRoundPreparing, Jailbreak.GuardsFriendlyFire
	local HasGodMode = PLAYER.HasGodMode
	GM.CanPlayerTakeDamage = function(self, ply, damageInfo, teamID)
		if HasGodMode(ply) or not Alive(ply) then
			return false
		end
		local attacker = damageInfo:GetAttacker()
		if not (IsValid(attacker) and attacker:IsPlayer()) then
			return true
		end
		if attacker == ply then
			return true
		end
		if IsRoundPreparing() then
			return false
		end
		if not GuardsFriendlyFire:GetBool() and teamID == TEAM_GUARD and teamID == attacker:Team() then
			return false
		end
		return true
	end
end
do
	local SetPlaybackRate = ENTITY.SetPlaybackRate
	GM.UpdateAnimation = function(self, ply, velocity, maxSeqGroundSpeed)
		local speed = Length(velocity)
		local rate = 1.0
		if GetTable(ply).m_bWasNoclipping or GetNW2Bool(ply, "in-flight") then
			rate = speed < 32 and 0.25 or 0
		elseif WaterLevel(ply) > 1 then
			rate = 0.5
		else
			if speed > 0.2 then
				rate = speed / maxSeqGroundSpeed
			end
			if rate > 2 then
				rate = 2
			end
			if WaterLevel(ply) >= 2 then
				if rate < 0.5 then
					rate = 0.5
				end
			elseif not IsOnGround(ply) and speed >= 1000 then
				rate = 0.1
			end
		end
		SetPlaybackRate(ply, rate)
		if CLIENT and not ply:IsBot() then
			if not ply:IsLocalPlayer() then
				Run("PerformPlayerVoice", ply)
			end
			if Alive(ply) then
				Run("MouthMoveAnimation", ply)
				return Run("GrabEarAnimation", ply)
			end
		end
	end
end
GM.ShouldCollide = function(self, entity, ply)
	if not (ply:IsPlayer() and Alive(ply)) then
		return
	end
	if GetClass(entity) == "func_respawnroomvisualizer" and not entity:IsDisabled() then
		return ply:Team() ~= entity:Team()
	end
end
do
	local PlayerSlowWalkSpeed = Jailbreak.PlayerSlowWalkSpeed
	GM.PlayerFootstep = function(self, ply, pos, foot, soundPath, volume, recipientFilter)
		if IsFlagSet(ply, 4) or Length(ply:GetVelocity()) < PlayerSlowWalkSpeed:GetInt() then
			return true
		end
	end
end
do
	local HITGROUP_HEAD = HITGROUP_HEAD
	local hitGroups = {
		[HITGROUP_GENERIC] = 1,
		[HITGROUP_HEAD] = 5,
		[HITGROUP_CHEST] = 1,
		[HITGROUP_STOMACH] = 1,
		[HITGROUP_LEFTARM] = 0.25,
		[HITGROUP_RIGHTARM] = 0.25,
		[HITGROUP_LEFTLEG] = 0.25,
		[HITGROUP_RIGHTLEG] = 0.25,
		[HITGROUP_GEAR] = 0.25
	}
	local jb_instant_kill_on_headshot = nil
	do
		local FCVAR_FLAGS = bit.bor(FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED)
		local CreateConVar = CreateConVar
		local AddChangeCallback = cvars.AddChangeCallback
		local tostring = tostring
		local tonumber = tonumber
		jb_instant_kill_on_headshot = CreateConVar("jb_instant_kill_on_headshot", "0", FCVAR_FLAGS, "If true, players will always be instantly killed on headshots.", 0, 1)
		for index, default in pairs(hitGroups) do
			local conVarName = "jb_hitgroup" .. index .. "_scale"
			hitGroups[index] = CreateConVar(conVarName, tostring(default), FCVAR_FLAGS, "https://wiki.facepunch.com/gmod/Enums/HITGROUP", 0, 1000):GetFloat()
			AddChangeCallback(conVarName, function(_, __, str)
				hitGroups[index] = tonumber(str) or 0
			end, "Jailbreak::HitGroups")
		end
	end
	do
		local isnumber = isnumber
		local damageScale = 0
		GM.ScaleHitGroupDamage = function(self, hitGroup, damageInfo)
			damageScale = hitGroups[hitGroup]
			if isnumber(damageScale) then
				return damageInfo:ScaleDamage(damageScale)
			end
		end
	end
	GM.ScalePlayerDamage = function(self, ply, hitGroup, damageInfo)
		if hitGroup == HITGROUP_HEAD and jb_instant_kill_on_headshot:GetBool() then
			damageInfo:SetDamage(ply:Health() + 1)
		else
			Run("ScaleHitGroupDamage", hitGroup, damageInfo)
		end
		if CLIENT and Run("CanPlayerTakeDamage", ply, damageInfo, ply:Team()) ~= true then
			return true
		end
	end
end
do
	local sv_cheats, host_timescale = GetConVar("sv_cheats"), GetConVar("host_timescale")
	local GetDemoPlaybackTimeScale = engine.GetDemoPlaybackTimeScale
	local GetTimeScale = game.GetTimeScale
	local Clamp = math.Clamp
	GM.EntityEmitSound = function(self, data)
		local pitch = data.Pitch
		local timeScale = GetTimeScale()
		if timeScale ~= 1 then
			pitch = pitch * timeScale
		end
		timeScale = sv_cheats:GetBool() and host_timescale:GetFloat() or 1
		if timeScale ~= 1 then
			pitch = pitch * timeScale
		end
		local entity = data.Entity
		if IsValid(entity) then
			if entity:IsPlayer() then
				local result = Run("PlayerEmitSound", entity, data)
				if result ~= nil then
					return result
				end
			else
				local result = Run("ValidEntityEmitSound", entity, data)
				if result ~= nil then
					return result
				end
			end
		elseif entity:IsWorld() then
			local result = Run("WorldEmitSound", entity, data)
			if result ~= nil then
				return result
			end
		end
		if pitch ~= data.Pitch then
			data.Pitch = Clamp(pitch, 0, 255)
			return true
		end
		if CLIENT then
			timeScale = GetDemoPlaybackTimeScale()
			if timeScale ~= 1 then
				data.Pitch = Clamp(data.Pitch * timeScale, 0, 255)
				return true
			end
		end
	end
end
do
	local ACT_MP_CROUCH_IDLE = ACT_MP_CROUCH_IDLE
	local ACT_MP_STAND_IDLE = ACT_MP_STAND_IDLE
	local ACT_MP_CROUCHWALK = ACT_MP_CROUCHWALK
	local ACT_HL2MP_IDLE = ACT_HL2MP_IDLE
	local ACT_MP_JUMP = ACT_MP_JUMP
	local ACT_MP_SWIM = ACT_MP_SWIM
	local ACT_MP_WALK = ACT_MP_WALK
	local ACT_MP_RUN = ACT_MP_RUN
	local ACT_LAND = ACT_LAND
	do
		local InVehicle, GetWalkSpeed, GetRunSpeed, GetActiveWeapon, IsPrisoner, GetVehicle, GetAllowWeaponsInVehicle, InNoclip = PLAYER.InVehicle, PLAYER.GetWalkSpeed, PLAYER.GetRunSpeed, PLAYER.GetActiveWeapon, PLAYER.IsPrisoner, PLAYER.GetVehicle, PLAYER.GetAllowWeaponsInVehicle, PLAYER.InNoclip
		local LookupSequence, GetParent, GetModel = ENTITY.LookupSequence, ENTITY.GetParent, ENTITY.GetModel
		local ACT_HL2MP_RUN_PANICKED = ACT_HL2MP_RUN_PANICKED
		local ACT_HL2MP_RUN_FAST = ACT_HL2MP_RUN_FAST
		local GetHoldType = WEAPON.GetHoldType
		local Length2DSqr = VECTOR.Length2DSqr
		local singleHandHoldTypes = {
			grenade = true,
			normal = true,
			melee = true,
			knife = true,
			fist = true,
			slam = true
		}
		local isSwimming, isNoclipping, isOnGround = false, false, false
		local calcIdeal, seqOverride, playerSpeed = 0, 0, 0
		local vehicles = list.GetForEdit("Vehicles")
		GM.CalcMainActivity = function(self, ply, velocity)
			calcIdeal, seqOverride = ACT_MP_STAND_IDLE, -1
			isOnGround = IsOnGround(ply)
			local tbl = GetTable(ply)
			if InVehicle(ply) and IsValid(GetParent(ply)) then
				local vehicle = GetVehicle(ply)
				if vehicle.HandleAnimation == nil then
					local data = vehicles[vehicle:GetVehicleClass()]
					if data and data.Members and data.Members.HandleAnimation then
						vehicle.HandleAnimation = data.Members.HandleAnimation
					else
						vehicle.HandleAnimation = true
					end
				end
				if vehicle.HandleAnimation ~= true then
					seqOverride = vehicle:HandleAnimation(ply) or seqOverride
					if seqOverride ~= -1 then
						goto finish
					end
				end
				local className = GetClass(vehicle)
				if className == "prop_vehicle_jeep" then
					seqOverride = LookupSequence(ply, "drive_jeep")
				elseif className == "prop_vehicle_airboat" then
					seqOverride = LookupSequence(ply, "drive_airboat")
				elseif className == "prop_vehicle_prisoner_pod" and GetModel(vehicle) == "models/vehicles/prisoner_pod_inner.mdl" then
					seqOverride = LookupSequence(ply, "drive_pd")
				else
					if GetAllowWeaponsInVehicle(ply) then
						local weapon = GetActiveWeapon(ply)
						if IsValid(weapon) then
							local holdtype = GetHoldType(weapon)
							seqOverride = LookupSequence(ply, holdtype == "smg" and "sit_smg1" or ("sit_" .. holdtype))
						end
					end
					calcIdeal = ACT_HL2MP_SIT
				end
				goto finish
			end
			isNoclipping, isSwimming = InNoclip(ply), WaterLevel(ply) > 1
			if isNoclipping or isSwimming or GetNW2Bool(ply, "in-flight") then
				calcIdeal = ACT_MP_SWIM
				goto finish
			end
			if IsFlagSet(ply, 4) then
				if Length2DSqr(velocity) < 0.25 then
					local weapon = GetActiveWeapon(ply)
					if weapon and IsValid(weapon) and GetHoldType(weapon) ~= "normal" then
						calcIdeal = ACT_MP_CROUCH_IDLE
					else
						calcIdeal, seqOverride = ACT_MP_JUMP, LookupSequence(ply, "pose_ducking_01")
					end
				else
					calcIdeal = ACT_MP_CROUCHWALK
				end
			elseif isOnGround then
				if tbl.m_bWasOnGround then
					playerSpeed = Length2DSqr(velocity)
					if playerSpeed > GetWalkSpeed(ply) then
						if playerSpeed >= GetRunSpeed(ply) * 0.95 then
							local weapon = GetActiveWeapon(ply)
							if weapon and IsValid(weapon) then
								if IsPrisoner(ply) and GetHoldType(weapon) == "normal" then
									calcIdeal = ACT_HL2MP_RUN_PANICKED
									goto finish
								end
								if singleHandHoldTypes[GetHoldType(weapon)] then
									calcIdeal = ACT_HL2MP_RUN_FAST
									goto finish
								end
							end
						end
						calcIdeal = ACT_MP_RUN
					elseif playerSpeed > 0.25 then
						calcIdeal = ACT_MP_WALK
					end
				end
			else
				calcIdeal = ACT_MP_JUMP
			end
			::finish::
			tbl.m_bInSwim = isSwimming
			tbl.m_bWasOnGround = isOnGround
			tbl.m_bWasNoclipping = isNoclipping
			tbl.CalcIdeal, tbl.CalcSeqOverride = calcIdeal, seqOverride
			return calcIdeal, seqOverride
		end
	end
	do
		local idleActivityTranslate = {
			[ACT_MP_STAND_IDLE] = ACT_HL2MP_IDLE,
			[ACT_MP_WALK] = ACT_HL2MP_IDLE + 1,
			[ACT_MP_RUN] = ACT_HL2MP_IDLE + 2,
			[ACT_MP_CROUCH_IDLE] = ACT_HL2MP_IDLE + 3,
			[ACT_MP_CROUCHWALK] = ACT_HL2MP_IDLE + 4,
			[ACT_MP_ATTACK_STAND_PRIMARYFIRE] = ACT_HL2MP_IDLE + 5,
			[ACT_MP_ATTACK_CROUCH_PRIMARYFIRE] = ACT_HL2MP_IDLE + 5,
			[ACT_MP_RELOAD_STAND] = ACT_HL2MP_IDLE + 6,
			[ACT_MP_RELOAD_CROUCH] = ACT_HL2MP_IDLE + 6,
			[ACT_MP_JUMP] = ACT_HL2MP_JUMP_SLAM,
			[ACT_MP_SWIM] = ACT_HL2MP_IDLE + 9,
			[ACT_LAND] = ACT_LAND
		}
		local TranslateWeaponActivity = PLAYER.TranslateWeaponActivity
		local nextAct = 0
		GM.TranslateActivity = function(self, ply, act)
			nextAct = TranslateWeaponActivity(ply, act)
			if act == nextAct then
				return idleActivityTranslate[act]
			end
			return nextAct
		end
	end
end
