local Jailbreak = Jailbreak
local ceil, floor, log, max, min, Clamp
do
	local _obj_0 = math
	ceil, floor, log, max, min, Clamp = _obj_0.ceil, _obj_0.floor, _obj_0.log, _obj_0.max, _obj_0.min, _obj_0.Clamp
end
local dark_grey, black, white
do
	local _obj_0 = Jailbreak.Colors
	dark_grey, black, white = _obj_0.dark_grey, _obj_0.black, _obj_0.white
end
local DrawRect, SetDrawColor
do
	local _obj_0 = surface
	DrawRect, SetDrawColor = _obj_0.DrawRect, _obj_0.SetDrawColor
end
local VoiceFraction = PLAYER.VoiceFraction
local IsValid = IsValid
local VMin = Jailbreak.VMin
local select = select
local NULL = NULL
local Run = hook.Run
Jailbreak.Font("Jailbreak::Voice Chat", "Roboto Mono Medium", 2)
do
	local LEFT, BOTTOM, FILL = LEFT, BOTTOM, FILL
	local FrameTime = FrameTime
	local PANEL = { }
	PANEL.Init = function(self)
		self:SetAlpha(0)
		self:Dock(BOTTOM)
		self.Player = NULL
		local avatar = self:Add("AvatarImage")
		self.Avatar = avatar
		avatar:Dock(LEFT)
		local label = self:Add("DLabel")
		self.Label = label
		label:SetExpensiveShadow(1, dark_grey)
		label:SetFont("Jailbreak::Voice Chat")
		label:SetContentAlignment(4)
		label:SetTextColor(white)
		label:Dock(FILL)
		self.VoiceData = { }
		self.NextVoiceData = 0
		self.VoiceDataLength = 0
	end
	PANEL.PerformLayout = function(self, width)
		local height, padding = VMin(4), VMin(0.5)
		self.VoiceDataLength = ceil(max(width, 4) / padding)
		self:DockPadding(padding, padding, padding, padding)
		self:DockMargin(0, padding, 0, 0)
		self.Label:DockMargin(padding, 0, 0, 0)
		height = max(height, select(2, self.Label:GetTextSize()) + padding * 2)
		local avatar = self.Avatar
		local avatarHeight = avatar:GetTall()
		avatar:SetWide(avatarHeight)
		local ply = self.Player
		if IsValid(ply) then
			avatar:SetPlayer(ply, Clamp(2 ^ floor(log(ceil(avatarHeight), 2)), 16, 512))
		end
		return self:SetTall(height)
	end
	PANEL.Setup = function(self, ply)
		if not ply:IsValid() then
			self:Remove()
			return
		end
		local label = self.Label
		if label and label:IsValid() then
			label:SetTextColor(ply:GetModelColor())
			label:SetText(ply:Nick())
		end
		self.Player = ply
		return self:InvalidateLayout()
	end
	do
		local remove = table.remove
		PANEL.Think = function(self)
			if self.NextVoiceData < CurTime() then
				local ply = self.Player
				if IsValid(ply) then
					local voiceData = self.VoiceData
					local length = #voiceData
					if length > self.VoiceDataLength then
						remove(voiceData, 1)
					end
					voiceData[length + 1] = max(0.05, VoiceFraction(ply))
					self.NextVoiceData = CurTime() + 0.025
				end
			end
			local animationType = self.AnimationType
			if animationType ~= nil then
				if animationType then
					local alpha = self:GetAlpha()
					if alpha > 0 then
						return self:SetAlpha(max(0, self:GetAlpha() - 255 * FrameTime() * 2))
					else
						self.AnimationType = nil
						if self:IsVisible() then
							return self:Hide()
						end
					end
				else
					local alpha = self:GetAlpha()
					if alpha < 255 then
						return self:SetAlpha(min(self:GetAlpha() + 255 * FrameTime() * 2, 255))
					else
						self.AnimationType = nil
					end
				end
			end
		end
	end
	PANEL.FadeIn = function(self)
		self.AnimationType = true
	end
	PANEL.FadeOut = function(self)
		self.AnimationType = false
		if not self:IsVisible() then
			return self:Show()
		end
	end
	PANEL.IsInAnimation = function(self)
		return self.AnimationType ~= nil
	end
	PANEL.Paint = function(self, width, height)
		for index = 1, self.VoiceDataLength do
			local volume = self.VoiceData[index]
			if volume ~= nil then
				local r, g, b = 255, 255, 255
				local ply = self.Player
				if IsValid(ply) and ply:Alive() then
					r, g, b = ply:GetTeamColorUpacked()
				end
				SetDrawColor(r, g, b, floor(volume * 255))
				local leftPadding, topPadding = self:GetDockPadding()
				local voiceDataHeight = ceil((height - topPadding) * volume)
				DrawRect((index - 1) * leftPadding, height - voiceDataHeight, leftPadding, voiceDataHeight)
			end
		end
		SetDrawColor(black.r, black.g, black.b, 50)
		DrawRect(0, 0, width - 1, height - 1)
		SetDrawColor(black.r, black.g, black.b, 120)
		DrawRect(0, 0, width + 2, height + 2)
		SetDrawColor(dark_grey.r, dark_grey.g, dark_grey.b, 200)
		return DrawRect(0, 0, width, height)
	end
	vgui.Register("Jailbreak::VoiceNotify", PANEL, "Panel")
end
do
	local PANEL = { }
	PANEL.Init = function(self)
		self:SetZPos(1000)
		return self:Dock(RIGHT)
	end
	PANEL.GetVoicePanel = function(self, ply)
		local _list_0 = self:GetChildren()
		for _index_0 = 1, #_list_0 do
			local panel = _list_0[_index_0]
			if panel.Player == ply then
				return panel
			end
		end
	end
	PANEL.StartVoice = function(self, ply)
		local panel = self:GetVoicePanel(ply)
		if not IsValid(panel) then
			panel = self:Add("Jailbreak::VoiceNotify")
		end
		panel:Setup(ply)
		panel:FadeOut()
		return self:InvalidateLayout()
	end
	PANEL.EndVoice = function(self, ply)
		local panel = self:GetVoicePanel(ply)
		if IsValid(panel) then
			return panel:FadeIn()
		end
	end
	PANEL.Think = function(self)
		local _list_0 = self:GetChildren()
		for _index_0 = 1, #_list_0 do
			local panel = _list_0[_index_0]
			if not IsValid(panel.Player) then
				if panel:GetAlpha() == 0 then
					panel:Remove()
				elseif not panel:IsInAnimation() then
					panel:FadeIn()
				end
			end
		end
	end
	PANEL.PerformLayout = function(self)
		local margin = VMin(1)
		self:DockMargin(0, margin, margin, margin)
		return self:SetWide(Jailbreak.ScreenWidth / 6)
	end
	vgui.Register("Jailbreak::VoiceChat", PANEL, "Panel")
end
do
	local VoiceChatNotifications = Jailbreak.VoiceChatNotifications
	GM.PlayerStartVoice = function(self, ply)
		if ply:IsLocalPlayer() then
			Run("LocalPlayerVoice", ply, true)
			Jailbreak.VoiceChatState = true
			return true
		end
		local voiceChat = Jailbreak.VoiceChat
		if not VoiceChatNotifications:GetBool() then
			if IsValid(voiceChat) then
				voiceChat:Remove()
			end
			return
		end
		if not IsValid(voiceChat) then
			voiceChat = vgui.Create("Jailbreak::VoiceChat", GetHUDPanel())
			Jailbreak.VoiceChat = voiceChat
		end
		voiceChat:StartVoice(ply)
		return true
	end
end
GM.PlayerEndVoice = function(self, ply)
	if ply:IsLocalPlayer() then
		Run("LocalPlayerVoice", ply, false)
		Jailbreak.VoiceChatState = false
		return
	end
	local voiceChat = Jailbreak.VoiceChat
	if IsValid(voiceChat) then
		return voiceChat:EndVoice(ply)
	end
end
do
	local ReadEntity, ReadFloat, ReadUInt
	do
		local _obj_0 = net
		ReadEntity, ReadFloat, ReadUInt = _obj_0.ReadEntity, _obj_0.ReadFloat, _obj_0.ReadUInt
	end
	local SetVoiceVolumeScale = PLAYER.SetVoiceVolumeScale
	net.Receive("JB::Communication", function()
		for i = 1, ReadUInt(10) do
			local ply, volume = ReadEntity(), ReadFloat()
			if ply:IsValid() then
				SetVoiceVolumeScale(ply, volume)
			end
		end
	end)
end
do
	local SetFlexWeight, LookupBone, ManipulateBoneAngles, GetFlexNum, GetFlexName, GetModel
	do
		local _obj_0 = ENTITY
		SetFlexWeight, LookupBone, ManipulateBoneAngles, GetFlexNum, GetFlexName, GetModel = _obj_0.SetFlexWeight, _obj_0.LookupBone, _obj_0.ManipulateBoneAngles, _obj_0.GetFlexNum, _obj_0.GetFlexName, _obj_0.GetModel
	end
	local VoiceFlexLess, VoiceForceFlexLess = Jailbreak.VoiceFlexLess, Jailbreak.VoiceForceFlexLess
	local abs, sin, Rand
	do
		local _obj_0 = math
		abs, sin, Rand = _obj_0.abs, _obj_0.sin, _obj_0.Rand
	end
	local angle_zero = angle_zero
	local LerpAngle = LerpAngle
	local SetUnpacked = ANGLE.SetUnpacked
	local IsSpeaking = PLAYER.IsSpeaking
	local find = string.find
	local patterns = {
		"right_corner_puller",
		"left_corner_puller",
		"right_cheek_raiser",
		"left_cheek_raiser",
		"right_part",
		"left_part",
		"right_mouth_drop",
		"left_mouth_drop",
		"jaw_drop",
		"smile",
		"lower_lip"
	}
	local mults = {
		right_corner_puller = 0.125,
		left_corner_puller = 0.125,
		right_cheek_raiser = 0.125,
		left_cheek_raiser = 0.125,
		lower_lip = 0.5,
		jaw_drop = 0.5,
		smile = 0.25
	}
	local cache, found, flexCount = { }, false, 0
	local fraction, flexLessMode = 0, 0
	local tempAngle, angle = Angle(), 0
	GM.MouthMoveAnimation = function(self, ply)
		local flexes = cache[GetModel(ply)]
		if flexes == nil then
			flexes = { }
			local length = 0
			for flexID = 0, GetFlexNum(ply) - 1 do
				local flexName = GetFlexName(ply, flexID)
				if not flexName then
					goto _continue_0
				end
				found = false
				for index = 1, #patterns do
					if flexName == patterns[index] or find(flexName, patterns[index], 1, false) ~= nil then
						found = true
						break
					end
				end
				if found then
					length = length + 1
					flexes[length] = {
						flexID,
						flexName,
						ply:GetFlexBounds(flexID)
					}
				end
				::_continue_0::
			end
			if length == 0 then
				flexes = false
			end
			cache[GetModel(ply)] = flexes
		end
		if IsSpeaking(ply) then
			fraction = VoiceFraction(ply)
		else
			fraction = 0
		end
		if flexes and not VoiceForceFlexLess:GetBool() then
			flexCount = #flexes
			if fraction > 0 then
				for i = 1, flexCount do
					local data = flexes[i]
					SetFlexWeight(ply, data[1], Clamp(abs(sin(data[1] * (1 / flexCount) + CurTime())) * fraction + fraction, data[3], data[4]) * (mults[data[2]] or 1) * 2)
				end
			else
				for i = 1, flexCount do
					SetFlexWeight(ply, flexes[i][1], 0)
				end
			end
			return
		end
		flexLessMode = VoiceFlexLess:GetInt()
		SetUnpacked(tempAngle, 0, 0, 0)
		if flexLessMode ~= 0 and fraction > 0.05 then
			if flexLessMode <= 2 then
				SetUnpacked(tempAngle, Rand(-45, 45) * fraction, Rand(-90, 90) * fraction, 0)
			elseif flexLessMode <= 5 then
				angle = min(360, flexLessMode * 72) * fraction
				SetUnpacked(tempAngle, Rand(-angle, angle), Rand(-angle, angle), 0)
			else
				angle = min(360, flexLessMode * 36) * fraction
				SetUnpacked(tempAngle, Rand(-angle, angle), Rand(-angle, angle), Rand(-angle, angle))
			end
		end
		ply.m_aMouthLessAngles = LerpAngle(0.25, ply.m_aMouthLessAngles or angle_zero, tempAngle)
		if flexLessMode > 1 then
			local boneID = LookupBone(ply, "ValveBiped.Bip01_Head1")
			if boneID and boneID >= 0 then
				ManipulateBoneAngles(ply, boneID, angle_zero, false)
			end
			ManipulateBoneAngles(ply, 0, ply.m_aMouthLessAngles, false)
			return
		end
		local boneID = LookupBone(ply, "ValveBiped.Bip01_Head1")
		if boneID and boneID >= 0 then
			ManipulateBoneAngles(ply, boneID, ply.m_aMouthLessAngles, false)
			ManipulateBoneAngles(ply, 0, angle_zero, false)
			return
		end
		return ManipulateBoneAngles(ply, 0, ply.m_aMouthLessAngles, false)
	end
end
