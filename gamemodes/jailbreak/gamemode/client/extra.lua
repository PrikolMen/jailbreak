local Jailbreak = Jailbreak
local Add = hook.Add
do
	local DrawColorModify = DrawColorModify
	local GetGlobal2Bool = GetGlobal2Bool
	local DrawSunbeams = DrawSunbeams
	local DrawSharpen = DrawSharpen
	local DrawToyTown = DrawToyTown
	local DrawBloom = DrawBloom
	local heaven = {
		["$pp_colour_addr"] = 0,
		["$pp_colour_addg"] = 0,
		["$pp_colour_addb"] = 0,
		["$pp_colour_brightness"] = 0.05,
		["$pp_colour_contrast"] = 1.25,
		["$pp_colour_colour"] = 1.25,
		["$pp_colour_mulr"] = 0.025,
		["$pp_colour_mulg"] = 0.025,
		["$pp_colour_mulb"] = 0
	}
	local hell = {
		["$pp_colour_addr"] = 0.05,
		["$pp_colour_addg"] = 0,
		["$pp_colour_addb"] = 0,
		["$pp_colour_brightness"] = -0.05,
		["$pp_colour_contrast"] = 1.25,
		["$pp_colour_colour"] = 0.8,
		["$pp_colour_mulr"] = 1.5,
		["$pp_colour_mulg"] = 0,
		["$pp_colour_mulb"] = 0
	}
	Add("RenderScreenspaceEffects", "Jailbreak::Heaven & Hell", function()
		if GetGlobal2Bool("Jailbreak::Heaven") then
			DrawColorModify(heaven)
			DrawToyTown(2, Jailbreak.ScreenHeight / 2)
			DrawSunbeams(0.1, 0.013, 0.14, 0.2, 0.6)
			DrawBloom(1, 1, 8, 8, 1, 1, 1, 1, 1)
			return
		end
		if GetGlobal2Bool("Jailbreak::Hell") then
			DrawColorModify(hell)
			DrawBloom(1, 1, 8, 8, 1, 1, 1, 1, 1)
			DrawSharpen(0.8, 0.8)
			return
		end
	end)
	local FogStart, FogEnd, FogMode, FogMaxDensity, FogColor
	do
		local _obj_0 = render
		FogStart, FogEnd, FogMode, FogMaxDensity, FogColor = _obj_0.FogStart, _obj_0.FogEnd, _obj_0.FogMode, _obj_0.FogMaxDensity, _obj_0.FogColor
	end
	Add("SetupWorldFog", "Jailbreak::Heaven & Hell", function()
		if GetGlobal2Bool("Jailbreak::Heaven") then
			FogStart(512)
			FogEnd(2048)
			FogMode(1)
			FogMaxDensity(0.5)
			FogColor(255, 255, 255)
			return true
		end
		if GetGlobal2Bool("Jailbreak::Hell") then
			FogStart(256)
			FogEnd(1048)
			FogMode(1)
			FogMaxDensity(1)
			FogColor(33, 33, 33)
			return true
		end
	end)
end
do
	local FrameTime = FrameTime
	Add("InputMouseApply", "Jailbreak::jb_ragdoll_mover", function(cmd, x, y, viewAngles)
		local ply = Jailbreak.Player
		if not (ply:IsValid() and ply:Alive()) then
			return
		end
		local entity = ply:GetHoldingEntity()
		if entity and entity:IsValid() then
			if entity.RagdollMover then
				return true
			end
			local frameTime = entity:GetNW2Int("entity-mass", 0)
			if frameTime < 1 then
				frameTime = 1
			end
			frameTime = FrameTime() / frameTime
			local _update_0 = 1
			viewAngles[_update_0] = viewAngles[_update_0] + (y * frameTime)
			local _update_1 = 2
			viewAngles[_update_1] = viewAngles[_update_1] - (x * frameTime)
			cmd:SetViewAngles(viewAngles)
			return true
		end
	end)
end
do
	local VMin = Jailbreak.VMin
	local PANEL = { }
	PANEL.Init = function(self)
		self:SetTitle("#jb.paint-can")
		self:SetIcon("icon16/paintcan.png")
		self:SetSizable(true)
		self:MakePopup()
		self:Center()
		local mixer = self:Add("DColorMixer")
		self.Mixer = mixer
		mixer:Dock(FILL)
		mixer:SetAlphaBar(false)
		local button = self:Add("DButton")
		self.Button = button
		button:Dock(BOTTOM)
		button:SetText("#jb.apply")
		button.DoClick = function()
			local color = mixer:GetColor()
			RunConsoleCommand("jb_paint_entity_apply", self.EntIndex or 0, color.r .. " " .. color.g .. " " .. color.b)
			return self:Close()
		end
	end
	PANEL.PerformLayout = function(self, ...)
		local size = VMin(40)
		self:SetSize(size, size)
		self:SetMinWidth(size)
		self:SetMinHeight(size)
		local mixer = self.Mixer
		if mixer and mixer:IsValid() then
			mixer:DockMargin(0, 0, 0, VMin(0.5))
		end
		local button = self.Button
		if button and button:IsValid() then
			button:SetTall(VMin(5))
		end
		return DFrame.PerformLayout(self, ...)
	end
	vgui.Register("Jailbreak::PaintMenu", PANEL, "DFrame")
end
do
	local panel = nil
	concommand.Add("jb_paint_entity", function(self, _, args)
		if panel and panel:IsValid() then
			panel:Remove()
			return
		end
		if not self:Alive() then
			return
		end
		local entity = Entity(tonumber(args[1] or "0") or 0)
		if not (entity and entity:IsValid() and entity:IsPaintCan()) then
			return
		end
		if entity:GetPos():Distance(self:GetPos()) > 72 then
			return
		end
		panel = vgui.Create("Jailbreak::PaintMenu")
		panel.EntIndex = entity:EntIndex()
	end)
end
Add("NotifyShouldTransmit", "Jailbreak::AutoMute", function(entity, shouldTransmit)
	if not shouldTransmit or not entity:IsPlayer() or entity.m_bBlacklistMuted then
		return
	end
	if not entity:IsMuted() and entity:GetFriendStatus() == "blocked" then
		entity.m_bBlacklistMuted = true
		return entity:SetMuted(true)
	end
end)
if render.GetDXLevel() < 80 then
	return
end
local UpdateRefractTexture, PushCustomClipPlane, SetColorModulation, PopCustomClipPlane, MaterialOverride, EnableClipping, GetBlend, SetBlend
do
	local _obj_0 = render
	UpdateRefractTexture, PushCustomClipPlane, SetColorModulation, PopCustomClipPlane, MaterialOverride, EnableClipping, GetBlend, SetBlend = _obj_0.UpdateRefractTexture, _obj_0.PushCustomClipPlane, _obj_0.SetColorModulation, _obj_0.PopCustomClipPlane, _obj_0.MaterialOverride, _obj_0.EnableClipping, _obj_0.GetBlend, _obj_0.SetBlend
end
local LocalToWorld, GetModelRenderBounds
do
	local _obj_0 = ENTITY
	LocalToWorld, GetModelRenderBounds = _obj_0.LocalToWorld, _obj_0.GetModelRenderBounds
end
local GetPlayerColor, GetSpawnTime
do
	local _obj_0 = PLAYER
	GetPlayerColor, GetSpawnTime = _obj_0.GetPlayerColor, _obj_0.GetSpawnTime
end
local Dot, Normalize
do
	local _obj_0 = VECTOR
	Dot, Normalize = _obj_0.Dot, _obj_0.Normalize
end
local LerpVector = LerpVector
local CurTime = CurTime
local Clamp = math.Clamp
local material = Material("models/wireframe")
local PlayerSpawnTime = Jailbreak.PlayerSpawnTime
local blend, clipping, frac = 0, false, 0
Add("PrePlayerDraw", "Jailbreak::SpawnEffect", function(self, flags)
	frac = 1 - Clamp((CurTime() - GetSpawnTime(self)) / PlayerSpawnTime:GetFloat(), 0, 1)
	if frac == 0 then
		return
	end
	local mins, maxs = GetModelRenderBounds(self)
	local normal = (mins - maxs)
	Normalize(normal)
	clipping = EnableClipping(true)
	PushCustomClipPlane(normal, Dot(normal, LerpVector(frac, LocalToWorld(self, maxs), LocalToWorld(self, mins))))
	UpdateRefractTexture()
	blend = GetBlend()
	local color = GetPlayerColor(self)
	SetColorModulation(color[1], color[2], color[3])
	material:SetFloat("$refractamount", frac * 0.1)
	MaterialOverride(material)
	return SetBlend(1 - frac)
end)
return Add("PostPlayerDraw", "Jailbreak::SpawnEffect", function(self, flags)
	if frac == 0 then
		return
	end
	SetColorModulation(1, 1, 1)
	MaterialOverride(0)
	SetBlend(blend)
	PopCustomClipPlane()
	return EnableClipping(clipping)
end)
