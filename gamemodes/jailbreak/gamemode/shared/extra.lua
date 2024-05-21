local Jailbreak = Jailbreak
local CurTime = CurTime
local ENTITY = ENTITY
local PLAYER = PLAYER
local SERVER = SERVER
local CLIENT = CLIENT
local Add = hook.Add
local GetVelocity, SetVelocity
do
	local _obj_0 = CMOVEDATA
	GetVelocity, SetVelocity = _obj_0.GetVelocity, _obj_0.SetVelocity
end
local GetNW2Var, SetNW2Var = ENTITY.GetNW2Var, ENTITY.SetNW2Var
local Alive = PLAYER.Alive
do
	local IN_ATTACK = IN_ATTACK
	local IN_WALK = IN_WALK
	Add("StartCommand", "Jailbreak::Markers", function(self, cmd)
		if Alive(self) and cmd:KeyDown(IN_WALK) then
			cmd:RemoveKey(IN_ATTACK)
			return cmd:RemoveKey(IN_ATTACK2)
		end
	end)
end
Add("AllowPlayerMove", "Jailbreak::Death Animations", function(self)
	if GetNW2Var(self, "death-animation") == 0 then
		return
	end
	return false
end)
Add("PlayerEmitSound", "Jailbreak::Death Animations", function(self, data)
	if GetNW2Var(self, "death-animation") ~= 0 then
		return false
	end
end)
Add("CanPlayerTakeDamage", "Jailbreak::Death Animations", function(self)
	if GetNW2Var(self, "death-animation") == 2 then
		return false
	end
end)
do
	local IN_JUMP = IN_JUMP
	local IN_DUCK = IN_DUCK
	local IN_SPEED = IN_SPEED
	local IN_FORWARD = IN_FORWARD
	local IN_BACK = IN_BACK
	local IN_MOVELEFT = IN_MOVELEFT
	local IN_MOVERIGHT = IN_MOVERIGHT
	local sv_gravity = GetConVar("sv_gravity")
	local FrameTime = FrameTime
	local IsOnGround = ENTITY.IsOnGround
	local Lerp = Lerp
	local band = bit.band
	local abs = math.abs
	Add("Move", "Jailbreak::Developer", function(self, mv)
		if not self:IsFlightAllowed() then
			if not CLIENT and GetNW2Var(self, "in-flight") then
				SetNW2Var(self, "in-flight", false)
			end
			return
		end
		if IsOnGround(self) then
			if not CLIENT and GetNW2Var(self, "in-flight") then
				return SetNW2Var(self, "in-flight", false)
			end
		elseif GetNW2Var(self, "in-flight") then
			local velocity = GetVelocity(mv)
			local angles = mv:GetMoveAngles()
			local buttons = mv:GetButtons()
			if band(buttons, IN_FORWARD) ~= 0 then
				velocity = velocity + (angles:Forward() * 16)
				buttons = buttons - IN_FORWARD
			end
			if band(buttons, IN_BACK) ~= 0 then
				velocity = velocity + (angles:Forward() * -16)
				buttons = buttons - IN_BACK
			end
			if band(buttons, IN_MOVELEFT) ~= 0 then
				velocity = velocity + (angles:Right() * -16)
				buttons = buttons - IN_MOVELEFT
			end
			if band(buttons, IN_MOVERIGHT) ~= 0 then
				velocity = velocity + (angles:Right() * 16)
				buttons = buttons - IN_MOVERIGHT
			end
			if band(buttons, IN_JUMP) ~= 0 then
				velocity = velocity + (angles:Up() * 16)
				buttons = buttons - IN_JUMP
			end
			if band(buttons, IN_DUCK) ~= 0 then
				velocity = velocity + (angles:Up() * -16)
				buttons = buttons - IN_DUCK
			end
			local frameTime = FrameTime()
			if band(buttons, IN_SPEED) ~= 0 then
				velocity[1] = Lerp(frameTime, velocity[1], 0)
				velocity[2] = Lerp(frameTime, velocity[2], 0)
				velocity[3] = Lerp(frameTime, velocity[3], 0)
				buttons = buttons - IN_SPEED
			end
			if abs(velocity[1]) < 1 then
				velocity[1] = 0
			end
			if abs(velocity[2]) < 1 then
				velocity[2] = 0
			end
			if abs(velocity[3]) < 1 then
				velocity[3] = 0
			end
			local _update_0 = 3
			velocity[_update_0] = velocity[_update_0] + ((self:GetGravity() + 1) * sv_gravity:GetFloat() * 0.5 * frameTime)
			SetVelocity(mv, velocity)
			return mv:SetButtons(buttons)
		elseif not CLIENT and mv:KeyPressed(IN_JUMP) then
			return SetNW2Var(self, "in-flight", true)
		end
	end)
end
Add("Move", "Jailbreak::Shock", function(self, mv)
	local shockTime = GetNW2Var(self, "shock-time")
	if not shockTime or CurTime() > shockTime then
		return
	end
	mv:SetMaxSpeed(self:GetWalkSpeed() / 4)
	return
end)
Add("PlayerEmitSound", "Jailbreak::SilentDeath", function(self, data)
	if not Alive(self) then
		return false
	end
end)
do
	local IsSpawning = PLAYER.IsSpawning
	Add("AllowPlayerMove", "Jailbreak::PlayerSpawning", function(self)
		if IsSpawning(self) then
			return false
		end
	end)
end
do
	local IsPlayingTaunt = PLAYER.IsPlayingTaunt
	Add("StartCommand", "Jailbreak::Taunts", function(self, cmd)
		if IsPlayingTaunt(self) then
			return cmd:SetImpulse(0)
		end
	end, PRE_HOOK)
	Add("SetupMove", "Jailbreak::Taunts", function(self, _, cmd)
		if IsPlayingTaunt(self) then
			cmd:ClearMovement()
			return cmd:ClearButtons()
		end
	end, PRE_HOOK)
end
do
	local OBS_MODE_NONE = OBS_MODE_NONE
	local GetObserverMode = PLAYER.GetObserverMode
	Add("AllowPlayerMove", "Jailbreak::AliveSpectator", function(self)
		if Alive(self) and GetObserverMode(self) ~= OBS_MODE_NONE then
			return false
		end
	end)
end
Add("PlayerFootstep", "Jailbreak::LoseConsciousness", function(ply)
	if ply:IsLoseConsciousness() then
		return true
	end
end)
do
	local Length2D, SetUnpacked
	do
		local _obj_0 = VECTOR
		Length2D, SetUnpacked = _obj_0.Length2D, _obj_0.SetUnpacked
	end
	local speed = 0
	return Add("Move", "Jailbreak::PlayerPush", function(self, mv)
		local target = GetNW2Var(self, "push-target")
		if target and target:IsValid() and target:Alive() then
			local velocity = GetVelocity(mv)
			local direction
			speed, direction = Length2D(velocity), nil
			if speed == 0 then
				speed, direction = self:GetWalkSpeed(), self:GetAimVector()
			else
				direction = velocity:GetNormalized()
				SetUnpacked(velocity, velocity[1] * 0.5, velocity[2] * 0.5, velocity[3])
				SetVelocity(mv, velocity)
			end
			self.m_vPushVelocity = direction * speed
			return
		end
		local pusher = GetNW2Var(self, "pushing-player")
		if pusher and pusher:IsValid() and pusher:Alive() then
			if SERVER and self:GetPos():DistToSqr(pusher:GetPos()) > 5184 then
				SetNW2Var(pusher, "push-target", nil)
				SetNW2Var(self, "pushing-player", nil)
				return
			end
			local pushVelocity = pusher.m_vPushVelocity
			if not pushVelocity then
				return
			end
			pushVelocity = pushVelocity * 1.125
			pushVelocity[3] = GetVelocity(mv)[3]
			SetVelocity(mv, pushVelocity)
			return
		end
	end)
end
