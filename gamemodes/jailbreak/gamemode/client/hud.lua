local Jailbreak = Jailbreak
local Run = hook.Run
local GM = GM
local Colors, VMin, GetTeamColor, GetTeamColorUpacked = Jailbreak.Colors, Jailbreak.VMin, Jailbreak.GetTeamColor, Jailbreak.GetTeamColorUpacked
local asparagus, white, black, dark_grey, light_grey, red, dark_white, horizon, butterfly_bush, au_chico = Colors.asparagus, Colors.white, Colors.black, Colors.dark_grey, Colors.light_grey, Colors.red, Colors.dark_white, Colors.horizon, Colors.butterfly_bush, Colors.au_chico
local DrawRect, SetMaterial, SetDrawColor, SetFont, GetTextSize, DrawText, SetTextColor, SetTextPos, SetAlphaMultiplier, DrawTexturedRectRotated
do
	local _obj_0 = surface
	DrawRect, SetMaterial, SetDrawColor, SetFont, GetTextSize, DrawText, SetTextColor, SetTextPos, SetAlphaMultiplier, DrawTexturedRectRotated = _obj_0.DrawRect, _obj_0.SetMaterial, _obj_0.SetDrawColor, _obj_0.SetFont, _obj_0.GetTextSize, _obj_0.DrawText, _obj_0.SetTextColor, _obj_0.SetTextPos, _obj_0.SetAlphaMultiplier, _obj_0.DrawTexturedRectRotated
end
local Clamp, min, max, sin, floor, ceil, Round, Rand
do
	local _obj_0 = math
	Clamp, min, max, sin, floor, ceil, Round, Rand = _obj_0.Clamp, _obj_0.min, _obj_0.max, _obj_0.sin, _obj_0.floor, _obj_0.ceil, _obj_0.Round, _obj_0.Rand
end
local sub, format, match, upper
do
	local _obj_0 = string
	sub, format, match, upper = _obj_0.sub, _obj_0.format, _obj_0.match, _obj_0.upper
end
local Create, Register
do
	local _obj_0 = vgui
	Create, Register = _obj_0.Create, _obj_0.Register
end
local GetPhrase = language.GetPhrase
local FrameTime = FrameTime
local Material = Material
local CurTime = CurTime
local EyePos = EyePos
local Lerp = Lerp
local Add = hook.Add
do
	local sourceHUD = {
		CHudSecondaryAmmo = true,
		CHudSuitPower = true,
		CHudBattery = true,
		CHudHealth = true,
		CHudAmmo = true
	}
	GM.HUDShouldDraw = function(self, name)
		if Jailbreak.DrawHUD then
			if sourceHUD[name] or Jailbreak.PlayingTaunt and name == "CHudWeaponSelection" then
				return false
			end
			return true
		end
		return false
	end
end
do
	local OBS_MODE_IN_EYE = OBS_MODE_IN_EYE
	local IgnoreZ = cam.IgnoreZ
	GM.PreDrawViewModels = function()
		local ply = Jailbreak.Player
		if not (ply:IsValid() and ply:GetObserverMode() == OBS_MODE_IN_EYE) then
			return
		end
		local viewEntity = Jailbreak.ViewEntity
		if not (viewEntity:IsPlayer() and viewEntity:Alive()) then
			return
		end
		IgnoreZ(true)
		for index = 0, 2 do
			local viewModel = viewEntity:GetViewModel(index)
			if viewModel and viewModel:IsValid() then
				viewModel:DrawModel()
			end
		end
		local hands = viewEntity:GetHands()
		if hands and hands:IsValid() then
			hands:DrawModel()
		end
		return IgnoreZ(false)
	end
end
do
	local GetRoundState, GetRemainingTime, GetWinningTeam, Teams = Jailbreak.GetRoundState, Jailbreak.GetRemainingTime, Jailbreak.GetWinningTeam, Jailbreak.Teams
	local ROUND_WAITING_PLAYERS = ROUND_WAITING_PLAYERS
	local ROUND_RUNNING = ROUND_RUNNING
	local ROUND_FINISHED = ROUND_FINISHED
	Jailbreak.Font("Jailbreak::Winners", "Roboto Mono Bold Italic", 4)
	Jailbreak.Font("Jailbreak::RoundState", "Roboto Mono Medium", 4)
	Add("HUDPaint", "Jailbreak::RoundInfo", function()
		if not Jailbreak.DrawHUD then
			return
		end
		local state = GetRoundState()
		if state == ROUND_RUNNING then
			return
		end
		local text = GetPhrase("jb.round." .. state)
		if state ~= ROUND_WAITING_PLAYERS then
			local remainingTime = GetRemainingTime()
			if remainingTime == 0 then
				return
			end
			text = format(text, remainingTime)
		end
		SetFont("Jailbreak::RoundState")
		local screenCenterX = Jailbreak.ScreenCenterX
		local textWidth, textHeight = GetTextSize(text)
		local x, y = screenCenterX - textWidth / 2, VMin(1)
		SetTextPos(x - 1, y - 1)
		SetTextColor(black.r, black.g, black.b, 50)
		DrawText(text)
		SetTextPos(x + 3, y + 3)
		SetTextColor(black.r, black.g, black.b, 120)
		DrawText(text)
		SetTextColor(white)
		SetTextPos(x, y)
		DrawText(text)
		y = y + textHeight
		if state == ROUND_FINISHED then
			local teamID = GetWinningTeam()
			local r, g, b = dark_white.r, dark_white.g, dark_white.b
			if Teams[teamID] then
				text = format(GetPhrase("#jb.victory"), GetPhrase("jb.team." .. teamID))
				r, g, b = GetTeamColorUpacked(teamID)
			else
				text = GetPhrase("#jb.draw")
			end
			text = "[" .. text .. "]"
			textWidth, textHeight = GetTextSize(text)
			x, y = screenCenterX - textWidth / 2, y
			SetTextPos(x - 1, y - 1)
			SetTextColor(black.r, black.g, black.b, 50)
			DrawText(text)
			SetTextPos(x + 3, y + 3)
			SetTextColor(black.r, black.g, black.b, 120)
			DrawText(text)
			SetTextColor(r, g, b, 255)
			SetTextPos(x, y)
			return DrawText(text)
		end
	end)
end
do
	local TargetID, DeathNotice = Jailbreak.TargetID, Jailbreak.DeathNotice
	local Start, End3D
	do
		local _obj_0 = cam
		Start, End3D = _obj_0.Start, _obj_0.End3D
	end
	local view = {
		["type"] = "3D"
	}
	GM.HUDPaint = function(self)
		if not Jailbreak.DrawHUD then
			return
		end
		Start(view)
		Run("HUDPaint3D")
		End3D()
		if TargetID:GetBool() then
			Run("HUDDrawTargetID")
		end
		if DeathNotice:GetBool() then
			return Run("DrawDeathNotice", 0.85, 0.04)
		end
	end
end
do
	local VoiceChatMinDistance, GetWeaponName, IsProp, FoodEatingTime, RagdollLootingTime = Jailbreak.VoiceChatMinDistance, Jailbreak.GetWeaponName, Jailbreak.IsProp, Jailbreak.FoodEatingTime, Jailbreak.RagdollLootingTime
	local ScreenToVector = gui.ScreenToVector
	local CursorVisible = vgui.CursorVisible
	local GetCursorPos = input.GetCursorPos
	local MASK_SHOT = MASK_SHOT
	local TraceLine = util.TraceLine
	local traceResult = { }
	local trace, useDistance = {
		mask = MASK_SHOT,
		output = traceResult
	}, 75 ^ 2
	Jailbreak.Font("Jailbreak::TargetID", "Roboto Mono Bold", 2.5)
	Jailbreak.Font("Jailbreak::TargetID - Team", "Roboto Mono SemiBold Italic", 2.25)
	Jailbreak.Font("Jailbreak::TargetID - Health", "Roboto Mono", 1.8)
	Jailbreak.Font("Jailbreak::TargetID - Use", "Roboto Mono Bold", 2)
	local targetIDClasses = Jailbreak.TargetIDClasses
	if not targetIDClasses then
		targetIDClasses = {
			func_door_rotating = true,
			prop_door_rotating = true,
			sent_soccerball = true,
			prop_ragdoll = true,
			func_button = true
		}
		Jailbreak.TargetIDClasses = targetIDClasses
	end
	local models = {
		["models/props_junk/metal_paintcan001a.mdl"] = "#jb.paint-can",
		["models/props_junk/metal_paintcan001b.mdl"] = "#jb.paint-can",
		["models/props_junk/gascan001a.mdl"] = "#jb.gas-can"
	}
	GM.HUDDrawTargetID = function(self)
		local ply = Jailbreak.ViewEntity
		if not ply:IsValid() then
			return
		end
		local screenCenterX = Jailbreak.ScreenCenterX
		local mouseX, mouseY = screenCenterX, Jailbreak.ScreenCenterY
		trace.start = EyePos()
		if ply:IsPlayer() then
			if ply:IsLoseConsciousness() then
				return
			end
			local isWorldClicking = ply:IsWorldClicking()
			if isWorldClicking and CursorVisible() then
				mouseX, mouseY = GetCursorPos()
				trace.endpos = trace.start + ScreenToVector(mouseX, mouseY) * 1024
			else
				trace.endpos = trace.start + ScreenToVector(mouseX, mouseY) * VoiceChatMinDistance:GetInt()
			end
		else
			trace.endpos = trace.start + ScreenToVector(mouseX, mouseY) * VoiceChatMinDistance:GetInt()
		end
		if not Jailbreak.IsPlayingTaunt and ply:Alive() then
			trace.filter = ply
		else
			trace.filter = nil
		end
		TraceLine(trace)
		if not traceResult.Hit or traceResult.HitWorld then
			return
		end
		local entity = traceResult.Entity
		if not entity:IsValid() then
			return
		end
		local entityType, text = 0, nil
		local r, g, b = 255, 255, 255
		if entity:IsPlayer() then
			if not entity:Alive() then
				return
			end
			r, g, b = entity:GetModelColorUnpacked()
			text = entity:Nick()
			entityType = 1
		elseif entity:IsRagdoll() then
			text = entity:GetRagdollOwnerNickname()
			r, g, b = entity:GetModelColorUnpacked()
			entityType = 2
		elseif entity:IsWeapon() then
			text = GetWeaponName(entity)
			entityType = 3
		elseif entity:IsFood() then
			text = "#jb.food"
			entityType = 4
		elseif entity:IsButton() then
			text = "#jb.func_button"
			entityType = 5
		else
			local className = entity:GetClass()
			if IsProp(className) then
				text, entityType = models[entity:GetModel()], 6
			elseif targetIDClasses[className] then
				local placeholder = "jb." .. className
				text = GetPhrase(placeholder)
				if text == placeholder then
					return
				end
				entityType = 7
			end
		end
		if entityType == 0 then
			return
		end
		local x, y = 0, mouseY + VMin(2)
		if text ~= nil then
			SetFont("Jailbreak::TargetID")
			local textWidth, textHeight = GetTextSize(text)
			x = mouseX - textWidth / 2
			SetTextPos(x - 1, y - 1)
			SetTextColor(black.r, black.g, black.b, 50)
			DrawText(text)
			SetTextPos(x + 3, y + 3)
			SetTextColor(black.r, black.g, black.b, 120)
			DrawText(text)
			SetTextColor(r, g, b)
			SetTextPos(x, y)
			DrawText(text)
			y = y + textHeight
			if entityType == 1 and entity:IsDeveloper() then
				text = "#jb.player.developer"
				SetFont("Jailbreak::TargetID - Team")
				textWidth, textHeight = GetTextSize(text)
				x = mouseX - textWidth / 2
				SetTextColor(dark_grey.r, dark_grey.g, dark_grey.b, 100)
				for sx = -2, 2 do
					for sy = -2, 2 do
						SetTextPos(x + sx, y + sy)
						DrawText(text)
					end
				end
				SetTextColor(butterfly_bush.r, butterfly_bush.g, butterfly_bush.b)
				SetTextPos(x, y)
				DrawText(text)
				y = y + textHeight
			end
		end
		if entityType == 1 or entityType == 2 then
			if entityType == 1 then
				local teamID = entity:Team()
				if entity:IsWarden() then
					text = "#jb.player.warden"
				elseif teamID == TEAM_GUARD then
					text = "#jb.player.guard"
				elseif teamID == TEAM_PRISONER then
					text = "#jb.player.prisoner"
				else
					text = "#jb.unknown"
				end
				r, g, b = GetTeamColorUpacked(teamID)
			else
				text = entity:Alive() and "#jb.player.unconscious" or "#jb.player.dead"
				r, g, b = dark_white.r, dark_white.g, dark_white.b
			end
			SetFont("Jailbreak::TargetID - Team")
			local textWidth, textHeight = GetTextSize(text)
			x = mouseX - textWidth / 2
			SetTextPos(x - 1, y - 1)
			SetTextColor(black.r, black.g, black.b, 50)
			DrawText(text)
			SetTextPos(x + 3, y + 3)
			SetTextColor(black.r, black.g, black.b, 120)
			DrawText(text)
			SetTextColor(r, g, b)
			SetTextPos(x, y)
			DrawText(text)
			y = y + textHeight
		end
		text = nil
		if entityType == 1 then
			if entity:HasGodMode() then
				text = "#jb.player.health.invincible"
				r, g, b = 254, 242, 0
			else
				local frac = entity:Health() / ply:GetMaxHealth()
				if frac <= 0 then
					text = "#jb.player.health.dead"
				elseif frac < 0.25 then
					text = "#jb.player.health.half-dead"
				elseif frac < 0.5 then
					text = "#jb.player.health.badly-wounded"
				elseif frac < 0.75 then
					text = "#jb.player.health.wounded"
				elseif frac < 0.90 then
					text = "#jb.player.health.hurt"
				else
					text = "#jb.player.health.healthy"
				end
				r, g, b = Lerp(frac, red.r, asparagus.r), Lerp(frac, red.g, asparagus.g), Lerp(frac, red.b, asparagus.b)
			end
		else
			local health = entity:Health()
			if health >= 1 then
				local frac = max(0, Round(1 - (health / entity:GetMaxHealth()), 2))
				if frac ~= 0 then
					text = GetPhrase("#jb.entity.damaged") .. " " .. (frac * 100) .. "%"
					r, g, b = dark_white.r, dark_white.g, dark_white.b
				end
			end
		end
		if text ~= nil then
			SetFont("Jailbreak::TargetID - Health")
			local textWidth, textHeight = GetTextSize(text)
			x = mouseX - textWidth / 2
			SetTextColor(dark_grey.r, dark_grey.g, dark_grey.b, 100)
			for sx = -2, 2 do
				for sy = -2, 2 do
					SetTextPos(x + sx, y + sy)
					DrawText(text)
				end
			end
			SetTextColor(r, g, b)
			SetTextPos(x, y)
			DrawText(text)
			y = y + textHeight
		end
		if trace.start:DistToSqr(traceResult.HitPos) > useDistance then
			return
		end
		local keyName = input.LookupBinding("use")
		if ply:IsPlayer() and keyName ~= nil and ply:Alive() then
			local progress
			text, progress = nil, 0
			if entityType == 1 then
				local weapon = ply:GetActiveWeapon()
				if weapon and weapon:IsValid() and weapon:GetClass() == "jb_hands" and weapon:GetHoldType() == "fist" then
					text = "#jb.player.push"
				end
			elseif entityType == 2 then
				local useTime = ply:GetUseTime()
				if useTime ~= 0 then
					progress = Clamp(useTime / RagdollLootingTime:GetInt(), 0, 1)
				end
				text = GetPhrase("jb.player.search")
			elseif entityType == 5 then
				text = "#jb.player.press-button"
			elseif entityType == 3 then
				if ply:HasWeapon(entity:GetClass()) then
					if (entity:Clip1() > 0 or entity:Clip2() > 0) and (ply:GetPickupAmmoCount(entity:GetPrimaryAmmoType()) > 1 or ply:GetPickupAmmoCount(entity:GetSecondaryAmmoType()) ~= 0) then
						text = "#jb.player.pickup-ammo"
					end
				else
					text = "#jb.player.pickup-weapon"
				end
			elseif entityType == 4 then
				local useTime = ply:GetUseTime()
				if useTime ~= 0 then
					progress = Clamp(useTime / FoodEatingTime:GetInt(), 0, 1)
				end
				text = GetPhrase("jb.player.eat")
			else
				local className = entity:GetClass()
				if className == "prop_door_rotating" or className == "func_door_rotating" then
					if entity:IsDoorLocked() then
						text = "#jb.player.door-locked"
					elseif entity:GetDoorState() == 0 then
						text = "#jb.player.door-open"
					else
						text = "#jb.player.door-close"
					end
				end
			end
			if text ~= nil then
				keyName = upper(keyName)
				SetFont("Jailbreak::TargetID - Use")
				local textWidth, textHeight = GetTextSize(text)
				local margin = VMin(0.5)
				local width, height = textWidth * 1.2, textHeight * 1.25
				x = mouseX - (width + margin + height) / 2
				y = y + ((height - textHeight) / 2 + margin)
				if progress ~= 0 then
					SetDrawColor(dark_grey.r, dark_grey.g, dark_grey.b, 240)
					SetTextColor(dark_grey.r, dark_grey.g, dark_grey.b)
					DrawRect(x, y - (height - textHeight) / 2, height, height)
					SetDrawColor(light_grey.r, light_grey.g, light_grey.b, 240)
					local rectHeight = ceil(height * progress)
					DrawRect(x, (y - (height - textHeight) / 2 + height) - rectHeight, height, rectHeight)
				else
					if ply:KeyDown(32) then
						SetDrawColor(light_grey.r, light_grey.g, light_grey.b, 240)
						SetTextColor(dark_grey.r, dark_grey.g, dark_grey.b)
					else
						SetDrawColor(dark_grey.r, dark_grey.g, dark_grey.b, 240)
						SetTextColor(dark_white.r, dark_white.g, dark_white.b)
					end
					DrawRect(x, y - (height - textHeight) / 2, height, height)
				end
				SetTextPos(x + (height - GetTextSize(keyName)) / 2, y)
				DrawText(keyName)
				x = x + (height + margin)
				SetDrawColor(dark_grey.r, dark_grey.g, dark_grey.b, 240)
				DrawRect(x, y - (height - textHeight) / 2, width, height)
				x = x + ((width - textWidth) / 2)
				SetTextColor(dark_white.r, dark_white.g, dark_white.b)
				SetTextPos(x, y)
				return DrawText(text)
			end
		end
	end
end
do
	local speakingIcon = Material("icon16/sound.png")
	do
		Jailbreak.Font("Jailbreak::VoiceChatIcon", "Roboto Mono Medium", 3)
		local alpha = 0
		Add("DrawOverlay", "Jailbreak::VoiceChatIcon", function()
			if Jailbreak.VoiceChatState then
				if alpha < 1 then
					alpha = min(1, alpha + FrameTime())
				end
			elseif alpha > 0 then
				alpha = max(0, alpha - FrameTime())
				if alpha < 0.01 then
					alpha = 0
				end
			end
			if alpha == 0 then
				return
			end
			SetAlphaMultiplier(alpha)
			local iconSize = VMin(12)
			local x, y = Jailbreak.ScreenCenterX, Jailbreak.ScreenHeight - iconSize / 2
			local rotation = sin(CurTime() * 3) * 30
			SetMaterial(speakingIcon)
			SetDrawColor(black.r, black.g, black.b, 50)
			DrawTexturedRectRotated(x - 1, y - 1, iconSize, iconSize, rotation)
			SetDrawColor(black.r, black.g, black.b, 120)
			DrawTexturedRectRotated(x + 3, y + 3, iconSize, iconSize, rotation)
			SetDrawColor(255, 255, 255, 255)
			DrawTexturedRectRotated(x, y, iconSize, iconSize, rotation)
			SetFont("Jailbreak::VoiceChatIcon")
			local text = GetPhrase("jb.hud.speaking")
			local textWidth, textHeight = GetTextSize(text)
			x, y = (Jailbreak.ScreenWidth - textWidth) / 2, Jailbreak.ScreenHeight - iconSize - textHeight
			SetTextPos(x - 1, y - 1)
			SetTextColor(black.r, black.g, black.b, 50)
			DrawText(text)
			SetTextPos(x + 3, y + 3)
			SetTextColor(black.r, black.g, black.b, 120)
			DrawText(text)
			SetTextColor(255, 255, 255)
			SetTextPos(x, y)
			DrawText(text)
			return SetAlphaMultiplier(1)
		end)
	end
	do
		local StatusIcons, VoiceChatMaxDistance = Jailbreak.StatusIcons, Jailbreak.VoiceChatMaxDistance
		local render_SetMaterial = render.SetMaterial
		local render_DrawSprite = render.DrawSprite
		local LocalToWorld = LocalToWorld
		local angle_zero = angle_zero
		local typingIcon = Material("icon16/comment_edit.png")
		local radioIcon = Material("icon16/phone_sound.png")
		local isSpeaking = false
		Add("PostPlayerDraw", "Jailbreak::StatusIcons", function(self)
			if not (StatusIcons:GetBool() and self:Alive()) then
				return
			end
			isSpeaking = self:IsSpeaking()
			if not (isSpeaking or self:IsTyping()) then
				return
			end
			local origin = nil
			local bone = self:LookupBone("ValveBiped.Bip01_Head1")
			if bone and bone >= 0 then
				local angles
				origin, angles = self:GetBonePosition(bone)
				local hitboxset = self:GetHitboxSet()
				for hitbox = 0, self:GetHitBoxCount(hitboxset) do
					if bone == self:GetHitBoxBone(hitbox, hitboxset) then
						local mins, maxs = self:GetHitBoxBounds(hitbox, hitboxset)
						origin = LocalToWorld((maxs + mins) / 2, angle_zero, origin, angles) + angles:Forward() * (maxs[3] - mins[3]) * 1.5
						break
					end
				end
			else
				origin = self:EyePos()
				local _update_0 = 3
				origin[_update_0] = origin[_update_0] + 14
			end
			local distance = origin:Distance(EyePos())
			if distance > VoiceChatMaxDistance:GetInt() then
				return
			end
			origin[3] = 1 + origin[3] + sin(CurTime() * 4) * 1.5
			render_SetMaterial(isSpeaking and (self:UsingSecurityRadio() and radioIcon or speakingIcon) or typingIcon)
			return render_DrawSprite(origin, 12, 12, white)
		end)
	end
end
Jailbreak.Font("Jailbreak::HUD", "Roboto Mono SemiBold Italic", 2)
do
	local Color = Color
	local date = os.date
	local PANEL = { }
	PANEL.Init = function(self)
		local placeholder = GetPhrase("jb.unknown")
		self.PlaceholderName = placeholder
		self.HeaderColor = dark_white
		self.EntityName = placeholder
		self.TimeX, self.TimeY = 0, 0
		self.Time = "00:00"
		self.Health, self.MaxHealth = 0, 0
		self.Armor, self.MaxArmor = 0, 0
		self.HealthRectX, self.HealthRectY = 0, 0
		self.ArmorRectX, self.ArmorRectY = 0, 0
		self.BarsWidth, self.BarsHeight = 0, 0
		self.HealthTextX, self.HealthTextY = 0, 0
		self.HealthText, self.ArmorText = "", ""
		self.ArmorTextX, self.ArmorTextY = 0, 0
		self.HealthRects = { }
		self.ArmorRects = { }
		Add("LanguageChanged", self, self.InvalidateLayout)
		return self:InvalidateLayout(true)
	end
	PANEL.Think = function(self)
		local time = date("%H:%M")
		if self.Time ~= time then
			self.Time = time
			self:InvalidateLayout()
		end
		local entity = Jailbreak.ViewEntity
		if not entity:IsValid() then
			if self.EntityName ~= self.PlaceholderName then
				self.EntityName = self.PlaceholderName
				self:InvalidateLayout()
			end
			return
		end
		local isPlayer = entity:IsPlayer()
		if self.IsPlayer ~= isPlayer then
			self.IsPlayer = isPlayer
			if not isPlayer then
				self.Alive = false
				self.Health = 0
			end
			self:InvalidateLayout()
		end
		if not isPlayer then
			if self.Color ~= light_grey then
				self.Color = light_grey
			end
			if entity:IsPlayerRagdoll() then
				local nickname = GetPhrase(entity:GetRagdollOwnerNickname())
				if self.EntityName ~= nickname then
					self.EntityName = nickname
					self:InvalidateLayout()
				end
			else
				local className = "#jb." .. entity:GetClass()
				if self.EntityName ~= className then
					self.EntityName = className
					self:InvalidateLayout()
				end
			end
			return
		end
		local teamID = entity:Team()
		if self.TeamID ~= teamID then
			self.TeamID = teamID
			self:InvalidateLayout()
		end
		local nickname = entity:Nick()
		if self.EntityName ~= nickname then
			self.EntityName = nickname
			self:InvalidateLayout()
		end
		local alive, health = entity:Alive(), entity:Health()
		if health <= 0 then
			alive = false
		end
		if self.Alive ~= alive then
			self.Alive = alive
			if not alive then
				self.Health = 0
				self.Armor = 0
			end
			self:InvalidateLayout()
		end
		if not alive then
			return
		end
		if self.Health ~= health then
			self.Health = health
			self:InvalidateLayout()
		end
		if self.MaxHealth ~= entity:GetMaxHealth() then
			self.MaxHealth = entity:GetMaxHealth()
			self:InvalidateLayout()
		end
		if self.Armor ~= entity:Armor() then
			self.Armor = entity:Armor()
			self:InvalidateLayout()
		end
		if self.MaxArmor ~= entity:GetMaxArmor() then
			self.MaxArmor = entity:GetMaxArmor()
			return self:InvalidateLayout()
		end
	end
	PANEL.PerformLayout = function(self)
		self.PlaceholderName = GetPhrase("jb.unknown")
		local margin, offset = VMin(0.25), VMin(1)
		local width = Jailbreak.ScreenWidth / 6
		SetFont("Jailbreak::HUD")
		local headerText = self.EntityName
		if #headerText > 48 then
			headerText = sub(headerText, 1, 48) .. "..."
		end
		local headerTextWidth, headerTextHeight = GetTextSize(headerText)
		local headerHeight = margin + headerTextHeight + margin
		local headerTextX = offset
		width = max(width, headerTextX + headerTextWidth)
		self.HeaderTextX, self.HeaderTextY = headerTextX, (headerHeight - headerTextHeight) / 2
		self.HeaderText = headerText
		self.HeaderHeight = headerHeight
		self.BackgroundY = headerHeight
		local timeWidth, timeHeight = GetTextSize(self.Time)
		local height
		width, height = max(width, headerTextX + headerTextWidth + margin + timeWidth + offset), headerHeight
		local rectCount = ceil((width - offset) / (offset + margin))
		width = offset + rectCount * (offset + margin) + offset - margin
		self.TimeX, self.TimeY = width - timeWidth - offset, (headerHeight - timeHeight) / 2
		if self.Alive then
			self.HeaderColor = GetTeamColor(self.TeamID)
			local healthRects = self.HealthRects
			for index = 1, #healthRects do
				healthRects[index] = nil
			end
			local healthFrac = self.Health / self.MaxHealth
			local health = rectCount * Clamp(healthFrac, 0, 1)
			local healthCount = ceil(health)
			local isOverhealth, overhealth, overhealthCount = false, nil, nil
			if healthFrac > 1 then
				isOverhealth = true
				overhealth = rectCount * Clamp(healthFrac - 1, 0, 1)
				overhealthCount = ceil(overhealth)
			end
			local x, y = offset, height + offset
			self.HealthRectX, self.HealthRectY = x - margin, y - margin
			SetFont("Jailbreak::HUD")
			local healthText, armorText = format(GetPhrase("jb.hud.health"), self.Health, self.MaxHealth), format(GetPhrase("jb.hud.armor"), self.Armor, self.MaxArmor)
			self.HealthText, self.ArmorText = healthText, armorText
			local healthTextWidth, healthTextHeight = GetTextSize(healthText)
			local armorTextWidth, armorTextHeight = GetTextSize(armorText)
			local rectHeight = margin + max(healthTextHeight, armorTextHeight) + margin
			local barsWidth, barsHeight = width - offset * 2 + margin * 2, margin + rectHeight + margin
			self.BarsWidth, self.BarsHeight = barsWidth, barsHeight
			self.HealthTextX, self.HealthTextY = x + (barsWidth - healthTextWidth) / 2, y + (rectHeight - healthTextHeight) / 2
			local backgroundHeight = offset + rectHeight
			for index = 1, healthCount do
				local rect = {
					x,
					y,
					offset,
					rectHeight,
					asparagus
				}
				if isOverhealth then
					if index <= overhealthCount then
						if index == overhealthCount and overhealthCount ~= overhealth then
							local frac = overhealth % 1
							rect[5] = Color(Lerp(frac, asparagus.r, butterfly_bush.r), Lerp(frac, asparagus.g, butterfly_bush.g), Lerp(frac, asparagus.b, butterfly_bush.b))
						else
							rect[5] = butterfly_bush
						end
					end
				elseif index == healthCount then
					if healthCount ~= health then
						local frac = health % 1
						rect[5] = Color(Lerp(frac, red.r, asparagus.r), Lerp(frac, red.g, asparagus.g), Lerp(frac, red.b, asparagus.b), floor(frac * 255))
						local _update_0 = 3
						rect[_update_0] = rect[_update_0] * frac
					end
				end
				healthRects[index] = rect
				x = x + (offset + margin)
			end
			local armor = self.Armor
			if armor > 0 then
				local armorRects = self.ArmorRects
				for index = 1, #armorRects do
					armorRects[index] = nil
				end
				local armorFrac = armor / self.MaxArmor
				armor = rectCount * Clamp(armorFrac, 0, 1)
				local armorCount = ceil(armor)
				local isOverarmor, overarmor, overarmorCount = false, nil, nil
				if armorFrac > 1 then
					isOverarmor = true
					overarmor = rectCount * Clamp(armorFrac - 1, 0, 1)
					overarmorCount = ceil(overarmor)
				end
				x, y = offset, y + offset + rectHeight + margin
				self.ArmorRectX, self.ArmorRectY = x - margin, y - margin
				self.ArmorTextX, self.ArmorTextY = x + (barsWidth - armorTextWidth) / 2, y + (rectHeight - armorTextHeight) / 2
				for index = 1, armorCount do
					local rect = {
						x,
						y,
						offset,
						rectHeight,
						horizon
					}
					if isOverarmor then
						if index <= overarmorCount then
							if index == overarmorCount and overarmorCount ~= overarmor then
								local frac = overarmor % 1
								rect[5] = Color(Lerp(frac, horizon.r, au_chico.r), Lerp(frac, horizon.g, au_chico.g), Lerp(frac, horizon.b, au_chico.b))
							else
								rect[5] = au_chico
							end
						end
					elseif index == armorCount and armorCount ~= armor then
						local frac = armor % 1
						rect[5] = Color(Lerp(frac, red.r, horizon.r), Lerp(frac, red.g, horizon.g), Lerp(frac, red.b, horizon.b), floor(frac * 255))
						local _update_0 = 3
						rect[_update_0] = rect[_update_0] * frac
					end
					armorRects[index] = rect
					x = x + (offset + margin)
				end
				backgroundHeight = backgroundHeight + (offset + margin + rectHeight)
			end
			backgroundHeight = backgroundHeight + offset
			self.BackgroundHeight = backgroundHeight
			height = height + backgroundHeight
		else
			self.HeaderColor = dark_white
			local text = GetPhrase("jb.player.dead")
			self.RectText = text
			local rectTextWidth, rectTextHeight = GetTextSize(text)
			local backgroundHeight = margin + rectTextHeight + margin
			self.RectTextY = headerHeight + (backgroundHeight - rectTextHeight) / 2
			self.BackgroundHeight = backgroundHeight
			height = height + backgroundHeight
			self.RectTextX = (max(1, width - rectTextWidth)) / 2
		end
		self:SetSize(width, height)
		return self:InvalidateParent()
	end
	PANEL.Paint = function(self, width, height)
		local headerColor = self.HeaderColor
		SetDrawColor(headerColor.r, headerColor.g, headerColor.b, 240)
		DrawRect(0, 0, width, self.HeaderHeight)
		SetDrawColor(dark_grey.r, dark_grey.g, dark_grey.b, 240)
		DrawRect(0, self.BackgroundY, width, self.BackgroundHeight)
		SetFont("Jailbreak::HUD")
		SetTextColor(dark_grey.r, dark_grey.g, dark_grey.b)
		SetTextPos(self.HeaderTextX, self.HeaderTextY)
		DrawText(self.HeaderText)
		SetTextPos(self.TimeX, self.TimeY)
		DrawText(self.Time)
		if self.Alive then
			SetDrawColor(light_grey.r, light_grey.g, light_grey.b, 25)
			DrawRect(self.HealthRectX, self.HealthRectY, self.BarsWidth, self.BarsHeight)
			local color = nil
			local _list_0 = self.HealthRects
			for _index_0 = 1, #_list_0 do
				local rect = _list_0[_index_0]
				color = rect[5]
				SetDrawColor(color.r, color.g, color.b, color.a)
				DrawRect(rect[1], rect[2], rect[3], rect[4])
			end
			SetFont("Jailbreak::HUD")
			local x, y = self.HealthTextX, self.HealthTextY
			local text = self.HealthText
			SetTextColor(dark_grey.r, dark_grey.g, dark_grey.b, 100)
			for sx = -2, 2 do
				for sy = -2, 2 do
					SetTextPos(x + sx, y + sy)
					DrawText(text)
				end
			end
			SetTextColor(dark_white.r, dark_white.g, dark_white.b)
			SetTextPos(x, y)
			DrawText(text)
			if self.Armor > 0 then
				SetDrawColor(light_grey.r, light_grey.g, light_grey.b, 25)
				DrawRect(self.ArmorRectX, self.ArmorRectY, self.BarsWidth, self.BarsHeight)
				local _list_1 = self.ArmorRects
				for _index_0 = 1, #_list_1 do
					local rect = _list_1[_index_0]
					color = rect[5]
					SetDrawColor(color.r, color.g, color.b, color.a)
					DrawRect(rect[1], rect[2], rect[3], rect[4])
				end
				x, y = self.ArmorTextX, self.ArmorTextY
				text = self.ArmorText
				SetTextColor(dark_grey.r, dark_grey.g, dark_grey.b, 100)
				for sx = -2, 2 do
					for sy = -2, 2 do
						SetTextPos(x + sx, y + sy)
						DrawText(text)
					end
				end
				SetTextColor(dark_white.r, dark_white.g, dark_white.b)
				SetTextPos(x, y)
				return DrawText(text)
			end
		else
			SetTextColor(dark_white.r, dark_white.g, dark_white.b)
			SetTextPos(self.RectTextX, self.RectTextY)
			return DrawText(self.RectText)
		end
	end
	Register("Jailbreak::HUDInfo", PANEL, "Panel")
end
do
	local lightning_delete = Material("icon16/lightning_delete.png")
	local lightning_add = Material("icon16/lightning_add.png")
	local lightning = Material("icon16/lightning.png")
	local PANEL = { }
	PANEL.Init = function(self)
		self.LineColor = dark_white
		self.Color = dark_grey
		self:SetAlpha(0)
		self.SuitPowerFraction = 1
		self.Direction = true
		self.Value = 100
		self.RotateOffset = 0
		self.IconRotate = 0
		return self:InvalidateLayout(true)
	end
	PANEL.Think = function(self)
		local entity = Jailbreak.ViewEntity
		if not (entity:IsValid() and entity:IsPlayer()) then
			return
		end
		if not entity:Alive() then
			if self:GetAlpha() ~= 0 then
				self:SetAlpha(0)
			end
			return
		end
		self.IconRotate = self.RotateOffset + sin(CurTime() * 2) * 15
		local teamID = entity:Team()
		if self.TeamID ~= teamID then
			self.TeamID = teamID
			self.Color = entity:GetTeamColor()
		end
		local value, oldValue = entity:GetSuitPower(), self.Value
		local fraction = value / 100
		if oldValue ~= value then
			local color = self.Color
			self.LineColor = Color(Lerp(fraction, red.r, color.r), Lerp(fraction, red.g, color.g), Lerp(fraction, red.b, color.b))
			self.SuitPowerFraction = fraction
			if fraction % 1 == 0 then
				self:InvalidateLayout()
			end
			self.Direction = value > oldValue
			self.Value = value
		end
		local alpha = self:GetAlpha()
		if fraction == 1 then
			if alpha > 0 then
				alpha = max(0, alpha - FrameTime() * 255 * 2)
				return self:SetAlpha(alpha)
			end
		elseif alpha < 255 then
			alpha = min(255, alpha + FrameTime() * 255 * 4)
			return self:SetAlpha(alpha)
		end
	end
	PANEL.PerformLayout = function(self)
		local width, height = VMin(4), self:GetTall()
		local margin = VMin(0.25)
		local lineHeight = VMin(1.5)
		local lineBackgroundWidth, lineBackgroundHeight = width - margin * 2, lineHeight - margin
		local lineBackgroundX, lineBackgroundY = margin, height - (lineHeight + margin)
		self.LineBackgroundWidth, self.LineBackgroundHeight = lineBackgroundWidth, lineBackgroundHeight
		self.LineBackgroundX, self.LineBackgroundY = lineBackgroundX, lineBackgroundY
		self.LineWidth, self.LineHeight = lineBackgroundWidth - margin * 2, lineBackgroundHeight - margin * 2
		self.LineX, self.LineY = lineBackgroundX + margin, lineBackgroundY + margin
		local iconSize = floor(min(width, height - lineHeight) / 2)
		self.IconX, self.IconY = width / 2, (height - lineHeight) / 2
		self.IconSize = iconSize
		self.RotateOffset = Rand(1, 10)
		return self:SetWide(width)
	end
	PANEL.Paint = function(self, width, height)
		local fraction = self.SuitPowerFraction
		if fraction == 1 and self:GetAlpha() == 0 then
			return
		end
		SetDrawColor(dark_grey.r, dark_grey.g, dark_grey.b, 240)
		DrawRect(0, 0, width, height)
		if fraction == 1 then
			SetMaterial(lightning)
		elseif self.Direction then
			SetMaterial(lightning_add)
		else
			SetMaterial(lightning_delete)
		end
		SetDrawColor(255, 255, 255)
		DrawTexturedRectRotated(self.IconX, self.IconY, self.IconSize, self.IconSize, self.IconRotate)
		SetDrawColor(light_grey.r, light_grey.g, light_grey.b, 25)
		DrawRect(self.LineBackgroundX, self.LineBackgroundY, self.LineBackgroundWidth, self.LineBackgroundHeight)
		SetDrawColor(self.LineColor)
		return DrawRect(self.LineX, self.LineY, self.LineWidth * fraction, self.LineHeight)
	end
	Register("Jailbreak::HUDPower", PANEL, "Panel")
end
do
	local GetWeaponName = Jailbreak.GetWeaponName
	local PANEL = { }
	PANEL.Init = function(self)
		self.HeaderColor = dark_white
		self.AmmoTextColor = white
		self.WeaponName = ""
		self.AmmoText = ""
		self.PrimaryCount, self.SecondaryCount = -1, -1
		self.Clip1, self.Clip2 = -1, -1
		self.WeaponNameX, self.WeaponNameY = 0, 0
		self.AmmoTextX, self.AmmoTextY = 0, 0
		self.RectHeight = 0
		Add("LanguageChanged", self, self.InvalidateLayout)
		return self:InvalidateLayout(true)
	end
	PANEL.Think = function(self)
		local entity = Jailbreak.ViewEntity
		if not (entity:IsValid() and entity:IsPlayer() and entity:Alive()) then
			if self.HeaderColor ~= dark_white then
				self.HeaderColor = dark_white
				self:InvalidateLayout()
			end
			local weaponName = GetPhrase("jb.nothing")
			if self.WeaponName ~= weaponName then
				self.WeaponName = weaponName
				self:InvalidateLayout()
			end
			if self.AmmoTextColor ~= dark_white then
				self.AmmoTextColor = dark_white
				self:InvalidateLayout()
			end
			local text = GetPhrase("jb.unknown")
			if self.AmmoText ~= text then
				self.AmmoText = text
				self:InvalidateLayout()
			end
			return
		end
		local headerColor = GetTeamColor(entity:Team())
		if self.HeaderColor ~= headerColor then
			self.HeaderColor = headerColor
			self:InvalidateLayout()
		end
		local weapon = entity:GetActiveWeapon()
		if not weapon:IsValid() then
			local weaponName = GetPhrase("jb.nothing")
			if self.WeaponName ~= weaponName then
				self.WeaponName = weaponName
				self:InvalidateLayout()
			end
			if self.AmmoTextColor ~= dark_white then
				self.AmmoTextColor = dark_white
				self:InvalidateLayout()
			end
			local text = GetPhrase("jb.unknown")
			if self.AmmoText ~= text then
				self.AmmoText = text
				self.Clip1, self.Clip2 = -1, -1
				self.PrimaryCount, self.SecondaryCount = -1, -1
				self:InvalidateLayout()
			end
			return
		end
		local weaponName = GetWeaponName(weapon)
		if self.WeaponName ~= weaponName then
			self.WeaponName = weaponName
			self:InvalidateLayout()
		end
		local clip1 = weapon:Clip1()
		if self.Clip1 ~= clip1 then
			self.Clip1 = clip1
			self:InvalidateLayout()
		end
		local clip2 = weapon:Clip2()
		if self.Clip2 ~= clip2 then
			self.Clip2 = clip2
			self:InvalidateLayout()
		end
		local primaryAmmoType, primaryAmmoCount = weapon:GetPrimaryAmmoType(), -1
		if primaryAmmoType >= 0 then
			primaryAmmoCount = entity:GetAmmoCount(primaryAmmoType)
		end
		if self.PrimaryCount ~= primaryAmmoCount then
			self.PrimaryCount = primaryAmmoCount
			self:InvalidateLayout()
		end
		local secondaryAmmoType, secondaryAmmoCount = weapon:GetSecondaryAmmoType(), -1
		if secondaryAmmoType >= 0 then
			secondaryAmmoCount = entity:GetAmmoCount(secondaryAmmoType)
		end
		if self.SecondaryCount ~= secondaryAmmoCount then
			self.SecondaryCount = secondaryAmmoCount
			return self:InvalidateLayout()
		end
	end
	PANEL.PerformLayout = function(self)
		local width, height = VMin(4), 0
		local margin1, margin2 = VMin(0.25), VMin(1)
		SetFont("Jailbreak::HUD")
		local weaponNameWidth, weaponNameHeight = GetTextSize(self.WeaponName)
		width = max(width, margin2 + weaponNameWidth + margin2)
		height = height + (margin1 + weaponNameHeight + margin1)
		local text = ""
		local clip1, primaryCount = self.Clip1, self.PrimaryCount
		if clip1 >= 0 then
			text = text .. clip1
			if primaryCount >= 1 then
				text = text .. (" / " .. primaryCount)
			end
		elseif primaryCount >= 0 then
			text = text .. primaryCount
		end
		local clip2, secondaryCount = self.Clip2, self.SecondaryCount
		if clip2 >= 1 then
			text = text .. (" ( " .. clip2)
			if secondaryCount >= 1 then
				text = text .. (" / " .. secondaryCount)
			end
			text = text .. " )"
		elseif secondaryCount >= 1 then
			text = text .. (" ( " .. secondaryCount .. " )")
		end
		if #text == 0 then
			text = GetPhrase("jb.unknown")
			self.AmmoTextColor = dark_white
		else
			self.AmmoTextColor = white
		end
		self.AmmoText = text
		local ammoTextWidth, ammoTextHeight = GetTextSize(text)
		height = height + (margin1 + ammoTextHeight + margin1)
		width = max(width, margin2 + ammoTextWidth + margin2)
		local headerHeight = margin1 + weaponNameHeight + margin1
		self.HeaderHeight = headerHeight
		local rectHeight = height - headerHeight
		self.RectHeight = rectHeight
		self.WeaponNameX, self.WeaponNameY = (width - weaponNameWidth) / 2, (headerHeight - weaponNameHeight) / 2
		self.AmmoTextX, self.AmmoTextY = (width - ammoTextWidth) / 2, headerHeight + (rectHeight - ammoTextHeight) / 2
		return self:SetSize(width, height)
	end
	PANEL.Paint = function(self, width, height)
		local headerColor = self.HeaderColor
		SetDrawColor(headerColor.r, headerColor.g, headerColor.b, 240)
		DrawRect(0, 0, width, self.HeaderHeight)
		SetDrawColor(dark_grey.r, dark_grey.g, dark_grey.b, 240)
		DrawRect(0, self.HeaderHeight, width, self.RectHeight)
		SetFont("Jailbreak::HUD")
		SetTextColor(dark_grey.r, dark_grey.g, dark_grey.b)
		SetTextPos(self.WeaponNameX, self.WeaponNameY)
		DrawText(self.WeaponName)
		SetTextPos(self.AmmoTextX, self.AmmoTextY)
		SetTextColor(self.AmmoTextColor)
		return DrawText(self.AmmoText)
	end
	Register("Jailbreak::HUDAmmo", PANEL, "Panel")
end
do
	local PANEL = { }
	PANEL.Init = function(self)
		self.Info = self:Add("Jailbreak::HUDInfo")
		self.Power = self:Add("Jailbreak::HUDPower")
		self.Ammo = self:Add("Jailbreak::HUDAmmo")
		self:Dock(BOTTOM)
		self:InvalidateLayout(true)
		return self:SetVisible(Jailbreak.DrawHUD)
	end
	PANEL.PerformLayout = function(self)
		local margin = VMin(1)
		self:DockMargin(margin, 0, margin, margin)
		self:SetZPos(-1000)
		local width = self:GetWide()
		local info, power, ammo = self.Info, self.Power, self.Ammo
		info:SetPos(0, 0)
		local infoWidth, infoHeight = info:GetSize()
		power:SetPos(infoWidth + margin / 2, infoHeight - power:GetTall())
		power:SetTall(infoHeight - (info.HeaderHeight or 0))
		local ammoWidth, ammoHeight = ammo:GetSize()
		ammo:SetPos(width - ammoWidth, infoHeight - ammoHeight)
		return self:SetSize(width, infoHeight)
	end
	Register("Jailbreak::HUD", PANEL, "Panel")
end
Add("PlayerInitialized", "Jailbreak::HUD", function()
	if not IsValid(Jailbreak.HUD) then
		Jailbreak.HUD = Create("Jailbreak::HUD", GetHUDPanel())
	end
end)
local PICKUP_OTHER = PICKUP_OTHER
local PICKUP_WEAPON = PICKUP_WEAPON
local PICKUP_AMMO = PICKUP_AMMO
local PICKUP_HEALTH = PICKUP_HEALTH
local PICKUP_ARMOR = PICKUP_ARMOR
do
	Jailbreak.Font("Jailbreak::PickupNotices", "Roboto Mono Bold", 1.5)
	local PickupNotifyLifetime = Jailbreak.PickupNotifyLifetime
	local PANEL = { }
	PANEL.Init = function(self)
		self:SetAlpha(0)
		self:Dock(BOTTOM)
		local icon = self:Add("DImage")
		self.Icon = icon
		icon:Dock(LEFT)
		local label = self:Add("DLabel")
		self.Label = label
		label:SetFont("Jailbreak::PickupNotices")
		label:SetContentAlignment(5)
		label:Dock(FILL)
		return self:InvalidateLayout(true)
	end
	PANEL.Think = function(self)
		local time = self.Time
		if not time then
			return
		end
		local fraction = Clamp((CurTime() - time) / PickupNotifyLifetime:GetInt(), 0, 1)
		self.Progress = 1 - fraction
		if fraction == 1 then
			if self:GetAlpha() > 0 then
				return self:SetAlpha(max(0, self:GetAlpha() - FrameTime() * 255))
			else
				return self:Remove()
			end
		elseif self:GetAlpha() < 255 then
			return self:SetAlpha(min(self:GetAlpha() + FrameTime() * 255, 255))
		end
	end
	PANEL.PerformLayout = function(self)
		self:DockMargin(0, 0, 0, VMin(0.2))
		local margin = VMin(0.5)
		self:DockPadding(margin, margin, margin, margin)
		local textHeight = select(2, self.Label:GetTextSize())
		local height = margin + textHeight + margin
		self:SetTall(height)
		self.ProgressHeight = VMin(0.2)
		self.Label:DockMargin(margin, 0, 0, 0)
		return self.Icon:SetWide(textHeight)
	end
	do
		local tonumber = tonumber
		PANEL.Setup = function(self, itemName, pickupType, amount)
			self.Time = CurTime()
			local label = self.Label
			if label and label:IsValid() then
				label:SetText(format(GetPhrase("jb.hud.pickup"), GetPhrase(itemName)) .. " x" .. ((tonumber(match(label:GetText(), "x(%d+)$")) or 0) + amount))
			end
			local iconPath = "icon16/information.png"
			if PICKUP_WEAPON == pickupType then
				iconPath = "icon16/gun.png"
			elseif PICKUP_AMMO == pickupType then
				iconPath = "icon16/package_green.png"
			elseif PICKUP_HEALTH == pickupType then
				iconPath = "icon16/heart.png"
			elseif PICKUP_ARMOR == pickupType then
				iconPath = "icon16/shield.png"
			end
			self.Icon:SetImage(Run("PickupNotifyIcon", itemName, pickupType, amount) or iconPath)
			return self:InvalidateLayout(true)
		end
	end
	local progress, progressHeight = 0, 0
	PANEL.Paint = function(self, width, height)
		SetDrawColor(dark_grey.r, dark_grey.g, dark_grey.b, 240)
		DrawRect(0, 0, width, height)
		progressHeight = self.ProgressHeight
		SetDrawColor(0, 0, 0, 140)
		DrawRect(0, height - progressHeight, width, progressHeight)
		progress = self.Progress
		SetDrawColor(Lerp(progress, au_chico.r, asparagus.r), Lerp(progress, au_chico.g, asparagus.g), Lerp(progress, au_chico.b, asparagus.b), 240)
		return DrawRect(0, height - progressHeight, width * progress, progressHeight)
	end
	Register("Jailbreak::PickupNotify", PANEL, "Panel")
end
do
	local PANEL = { }
	PANEL.Init = function(self)
		self.Notices = { }
	end
	PANEL.PerformLayout = function(self)
		local screenWidth = Jailbreak.ScreenWidth
		local width = ceil(screenWidth / 4)
		self:SetSize(width, Jailbreak.ScreenHeight)
		return self:SetPos(floor((screenWidth - width) / 2), 0)
	end
	PANEL.AddNotify = function(self, itemName, pickupType, amount)
		local notify = self.Notices[itemName]
		if not (notify and notify:IsValid()) then
			notify = self:Add("Jailbreak::PickupNotify")
			self.Notices[itemName] = notify
		end
		return notify:Setup(itemName, pickupType, amount)
	end
	Register("Jailbreak::PickupNotices", PANEL, "Panel")
end
do
	local GetWeaponName = Jailbreak.GetWeaponName
	local pickupNotify
	pickupNotify = function(itemName, pickupType, amount)
		local pickupNotices = Jailbreak.PickupNotices
		if not (pickupNotices and pickupNotices:IsValid()) then
			pickupNotices = Create("Jailbreak::PickupNotices")
			if not (pickupNotices and pickupNotices:IsValid()) then
				return
			end
			Jailbreak.PickupNotices = pickupNotices
		end
		return pickupNotices:AddNotify(itemName or "jb.unknown", pickupType or PICKUP_OTHER, amount or 1)
	end
	Add("PickupNotifyReceived", "Jailbreak::PickupNotify", pickupNotify, PRE_HOOK)
	Jailbreak.PickupNotify = pickupNotify
	GM.HUDWeaponPickedUp = function(self, weapon)
		if weapon and weapon:IsValid() and weapon:IsWeapon() then
			pickupNotify(GetWeaponName(weapon), PICKUP_WEAPON, 1)
			return
		end
	end
	GM.HUDItemPickedUp = function(self, itemName)
		pickupNotify(itemName, PICKUP_OTHER, 1)
		return
	end
	GM.HUDAmmoPickedUp = function(self, itemName, amount)
		if itemName == "Grenade" then
			return
		end
		pickupNotify(itemName .. "_ammo", PICKUP_AMMO, amount)
		return
	end
end
Add("PickupNotifyIcon", "Jailbreak::DefaultIcons", function(itemName, pickupType, amount)
	if pickupType ~= PICKUP_OTHER then
		return
	end
	if "jb.flashlight" == itemName then
		return "icon16/lightbulb.png"
	elseif "jb.security.keys" == itemName then
		return "icon16/key.png"
	elseif "jb.walkie-talkie" == itemName then
		return "icon16/phone.png"
	elseif "jb.shock-collar" == itemName then
		return "icon16/lock.png"
	end
end)
GM.PickupHistory = nil
GM.PickupHistoryLast = nil
GM.PickupHistoryWide = nil
GM.PickupHistoryTop = nil
GM.PickupHistoryCorner = nil
GM.HUDDrawPickupHistory = nil
