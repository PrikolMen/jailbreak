include("shared.lua")
local IsValid = IsValid
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
do
	local match = string.match
	ENT.IsValidURL = function(self, str)
		return #str ~= 0 and match(str, "^https?://(%w[%w._-]+%.%w+)/?") ~= nil
	end
end
do
	local VoiceChatMinDistance, VoiceChatMaxDistance
	do
		local _obj_0 = Jailbreak
		VoiceChatMinDistance, VoiceChatMaxDistance = _obj_0.VoiceChatMinDistance, _obj_0.VoiceChatMaxDistance
	end
	local PlayURL = sound.PlayURL
	local url, volume, origin, direction = "", 0, nil, nil
	ENT.Think = function(self)
		local channel = self.Channel
		if channel == true then
			return
		end
		url = self:GetURL()
		if (channel == false and self.ChannelURL == url) then
			return
		end
		if not self:IsValidURL(url) then
			self.ChannelURL = url
			self.Channel = false
			if IsValid(channel) then
				channel:Stop()
			end
			return
		end
		if IsValid(channel) then
			if self.ChannelURL == url then
				if channel:GetState() == 0 then
					channel:Play()
					return
				end
				volume = self:GetVolume()
				if volume == 0 then
					channel:Pause()
					return
				end
				channel:Set3DFadeDistance(VoiceChatMinDistance:GetInt(), VoiceChatMaxDistance:GetInt())
				channel:SetVolume(volume)
				direction = self:GetAngles():Forward()
				origin = self:WorldSpaceCenter() + direction * 12
				channel:SetPos(origin, direction)
				if channel:GetState() == 2 then
					channel:Play()
				end
				return
			end
			channel:Stop()
		end
		self.ChannelURL = url
		self.Channel = true
		return PlayURL(url, "3d noplay noblock", function(object)
			if not self:IsValid() then
				if IsValid(object) then
					object:Stop()
				end
				return
			end
			if not IsValid(object) then
				print("[" .. tostring(self) .. "] Failed to play '" .. url .. "'")
				self.Channel = false
				return
			end
			self.Channel = object
			object:Set3DEnabled(true)
			return object:Play()
		end)
	end
end
do
	local VMin = Jailbreak.VMin
	local PANEL = { }
	PANEL.Init = function(self)
		self:SetTitle("#jb.jb_radio")
		self:SetIcon("icon16/sound.png")
		self:SetSize(VMin(40), VMin(20))
		self:SetSizable(true)
		self:MakePopup()
		self:Center()
		local entry = self:Add("DTextEntry")
		self.Entry = entry
		entry:SetPlaceholderText("Webstream URL here...")
		entry:SetHistoryEnabled(true)
		entry:Dock(FILL)
		entry:SetValue("https://radio.r4v3.party/listen/edm/radio.mp3")
		entry:AddHistory("http://195.150.20.5:8000/rmf_dance")
		entry:AddHistory("https://radio.r4v3.party/listen/edm/radio.mp3")
		entry:AddHistory("https://radio.r4v3.party/listen/rock/radio.mp3")
		entry:AddHistory("https://radio.r4v3.party/listen/hardstyle/radio.mp3")
		local volume = self:Add("DNumSlider")
		self.Volume = volume
		volume:SetText("#jb.volume")
		volume:SetMinMax(0, 1)
		volume:SetDecimals(2)
		volume:Dock(BOTTOM)
		volume:SetZPos(1000)
		volume.PerformLayout = function(...)
			volume:DockMargin(0, VMin(0.5), 0, 0)
			return DNumSlider.PerformLayout(...)
		end
		local button = self:Add("DButton")
		self.Button = button
		button:Dock(BOTTOM)
		button:SetText("#jb.apply")
		button:SetZPos(10)
		button.PerformLayout = function(...)
			button:DockMargin(0, VMin(0.5), 0, 0)
			return DButton.PerformLayout(...)
		end
		button.DoClick = function()
			net.Start("Jailbreak::Radio")
			net.WriteEntity(self.Entity)
			net.WriteString(entry:GetValue())
			net.WriteFloat(volume:GetValue())
			net.SendToServer()
			return self:Close()
		end
	end
	PANEL.PerformLayout = function(self, width, height)
		self:SetMinWidth(VMin(20))
		self:SetMinHeight(VMin(10))
		local entity = self.Entity
		if entity and entity:IsValid() then
			local entry = self.Entry
			if IsValid(entry) and #entry:GetValue() == 0 then
				entry:SetText(entity:GetURL())
			end
			local volume = self.Volume
			if IsValid(volume) then
				volume:SetMax(entity.MaxVolume or 1)
				volume:SetValue(entity:GetVolume())
			end
		end
		local button = self.Button
		if IsValid(button) then
			button:SetTall(math.ceil(height * 0.20))
		end
		return DFrame.PerformLayout(self, width, height)
	end
	vgui.Register("Jailbreak::RadioMenu", PANEL, "DFrame")
end
do
	local panel = NULL
	net.Receive("Jailbreak::Radio", function()
		if panel:IsValid() then
			panel:Remove()
			return
		end
		local entity = net.ReadEntity()
		if not (entity and entity:IsValid()) then
			return
		end
		if entity:GetClass() ~= "jb_radio" or entity:GetPos():Distance(Jailbreak.Player:GetPos()) > 72 then
			return
		end
		panel = vgui.Create("Jailbreak::RadioMenu")
		panel.Entity = entity
	end)
end
do
	local playing = Material("icon16/control_play_blue.png")
	local stopped = Material("icon16/control_stop_blue.png")
	local paused = Material("icon16/control_pause_blue.png")
	local connecting = Material("icon16/disconnect.png")
	local failed = Material("icon16/exclamation.png")
	local DrawSprite, SetMaterial
	do
		local _obj_0 = render
		DrawSprite, SetMaterial = _obj_0.DrawSprite, _obj_0.SetMaterial
	end
	local color_white = color_white
	local CurTime = CurTime
	local sin = math.sin
	local originOffset = Vector(0, 0, 0)
	local channel, material = nil, nil
	ENT.Draw = function(self, flags)
		self:DrawModel(flags)
		channel = self.Channel
		if channel == true then
			material = connecting
		elseif channel == false then
			material = failed
		elseif IsValid(channel) then
			local _exp_0 = channel:GetState()
			if 0 == _exp_0 then
				material = stopped
			elseif 1 == _exp_0 then
				material = playing
			elseif 2 == _exp_0 then
				material = paused
			elseif 3 == _exp_0 then
				material = connecting
			else
				material = failed
			end
		else
			material = failed
		end
		SetMaterial(material)
		originOffset[3] = 28 + sin(CurTime() * 4) * 1.5
		return DrawSprite(self:LocalToWorld(originOffset), 16, 16, color_white)
	end
end
