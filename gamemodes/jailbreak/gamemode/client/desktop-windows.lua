local Jailbreak = Jailbreak
local Colors, VMin, GameInProgress, VoiceChatProximity = Jailbreak.Colors, Jailbreak.VMin, Jailbreak.GameInProgress, Jailbreak.VoiceChatProximity
local RunConsoleCommand = RunConsoleCommand
local min, floor, random, Round
do
	local _obj_0 = math
	min, floor, random, Round = _obj_0.min, _obj_0.floor, _obj_0.random, _obj_0.Round
end
local sub, upper, Explode
do
	local _obj_0 = string
	sub, upper, Explode = _obj_0.sub, _obj_0.upper, _obj_0.Explode
end
local GetPhrase = language.GetPhrase
local PlaySound = surface.PlaySound
local Set = list.Set
local black = Colors.black
do
	local securityRadio = CreateConVar("jb_security_radio", "0", FCVAR_USERINFO, "Responsible for turning the radio on or off.", 0, 1)
	cvars.AddChangeCallback(securityRadio:GetName(), function(_, __, value)
		return PlaySound(value == "1" and "npc/overwatch/radiovoice/on3.wav" or "npc/overwatch/radiovoice/off2.wav")
	end, "Jailbreak::SecurityRadio")
	Set("DesktopWindows", "walkie-talkie", {
		title = "#jb.walkie-talkie",
		icon = "icon16/phone.png",
		order = 500,
		think = function(self)
			if not VoiceChatProximity:GetBool() then
				if self:IsVisible() then
					self:InvalidateParent()
					self:Hide()
				end
				return
			end
			if Jailbreak.Player:HasSecurityRadio() then
				local state = securityRadio:GetBool()
				local image = state and "icon16/phone_sound.png" or "icon16/phone.png"
				if self:GetImage() ~= image then
					self:SetImage(image)
				end
				if self:IsVisible() then
					return
				end
				self:InvalidateParent()
				return self:Show()
			elseif self:IsVisible() then
				self:InvalidateParent()
				return self:Hide()
			end
		end,
		click = function(self)
			return securityRadio:SetBool(not securityRadio:GetBool())
		end
	})
end
do
	local AllowPlayersLoseConsciousness = Jailbreak.AllowPlayersLoseConsciousness
	Set("DesktopWindows", "lose-consciousness", {
		title = "#jb.player.lose-consciousness",
		icon = "icon16/user_delete.png",
		order = 2500,
		think = function(self)
			if not AllowPlayersLoseConsciousness:GetBool() then
				if self:IsVisible() then
					self:InvalidateParent()
					self:Hide()
				end
				return
			end
			local ply = Jailbreak.Player
			if not (GameInProgress() and ply:IsValid() and ply:Alive()) then
				if self:IsVisible() then
					self:InvalidateParent()
					self:Hide()
				end
				return
			end
			if not self:IsVisible() then
				self:InvalidateParent()
				self:Show()
			end
			local ragdoll = ply:GetRagdollEntity()
			if not (ragdoll:IsValid() and ragdoll:Alive()) then
				if self:GetImage() ~= "icon16/user_delete.png" then
					self:SetImage("icon16/user_delete.png")
				end
				local text = GetPhrase("jb.player.lose-consciousness")
				if self.Label:GetText() ~= text then
					self.Label:SetText(text)
					self:SetTooltip(text)
				end
				return
			end
			if self:GetImage() ~= "icon16/user_add.png" then
				self:SetImage("icon16/user_add.png")
			end
			local text = GetPhrase("jb.player.wake-up")
			if self.Label:GetText() ~= text then
				self.Label:SetText(text)
				return self:SetTooltip(text)
			end
		end,
		click = function(self)
			return RunConsoleCommand("jb_lose_consciousness")
		end
	})
end
do
	local Megaphone = CreateConVar("jb_megaphone", "1", FCVAR_USERINFO, "Activates the warden's ability to speak for the entire map.", 0, 1)
	Set("DesktopWindows", "megaphone", {
		title = "#jb.megaphone",
		icon = "icon16/sound_mute.png",
		order = 500,
		think = function(self)
			if not VoiceChatProximity:GetBool() then
				if self:IsVisible() then
					self:InvalidateParent()
					self:Hide()
				end
				return
			end
			if Jailbreak.Player:IsWarden() then
				local image = Megaphone:GetBool() and "icon16/sound.png" or "icon16/sound_mute.png"
				if self:GetImage() ~= image then
					self:SetImage(image)
				end
				if not self:IsVisible() then
					self:InvalidateParent()
					return self:Show()
				end
			elseif self:IsVisible() then
				self:InvalidateParent()
				return self:Hide()
			end
		end,
		click = function(self)
			return Megaphone:SetBool(not Megaphone:GetBool())
		end
	})
end
Set("DesktopWindows", "warden-request", {
	title = "#jb.warden.join",
	icon = "icon16/user_suit.png",
	order = 1000,
	think = function(self)
		if Jailbreak.IsRoundRunning() then
			local ply = Jailbreak.Player
			if ply:Alive() then
				if Jailbreak.HasWarden() then
					if ply:IsWarden() then
						local image = "icon16/user_go.png"
						if self:GetImage() ~= image then
							self:SetImage(image)
						end
						local text = GetPhrase("jb.warden.leave")
						if self.Label:GetText() ~= text then
							self.Label:SetText(text)
							self:SetTooltip(text)
						end
						if not self:IsVisible() then
							self:InvalidateParent()
							self:Show()
						end
						return
					end
				elseif ply:IsGuard() then
					local image = "icon16/user_suit.png"
					if self:GetImage() ~= image then
						self:SetImage(image)
					end
					local text = GetPhrase("jb.warden.join")
					if self.Label:GetText() ~= text then
						self.Label:SetText(text)
						self:SetTooltip(text)
					end
					if not self:IsVisible() then
						self:InvalidateParent()
						self:Show()
					end
					return
				end
			end
		end
		if self:IsVisible() then
			self:InvalidateParent()
			return self:Hide()
		end
	end,
	click = function(self)
		return RunConsoleCommand("jb_warden")
	end
})
Set("DesktopWindows", "shock-collars", {
	title = "#jb.shock-collars",
	icon = "icon16/lightning.png",
	order = 500,
	think = function(self)
		if GameInProgress() then
			local ply = Jailbreak.Player
			if ply:IsWarden() and ply:Alive() then
				local state = Jailbreak.IsShockCollarsActive()
				local image = state and "icon16/lightning.png" or "icon16/lightning_delete.png"
				if self:GetImage() ~= image then
					self:SetImage(image)
				end
				if not self:IsVisible() then
					self:InvalidateParent()
					self:Show()
				end
				return
			end
		end
		if self:IsVisible() then
			self:InvalidateParent()
			return self:Hide()
		end
	end,
	click = function(self)
		return RunConsoleCommand("jb_shock_collars")
	end
})
local margin = 0
do
	Jailbreak.Font("Jailbreak::Coins", "Roboto Mono Bold", 1.8)
	local PANEL = { }
	PANEL.Init = function(self)
		self.OverlayFade = nil
		local label = self:Add("DLabel")
		self.Label = label
		label:SetExpensiveShadow(3, Color(0, 0, 0, 125))
		label:SetFont("Jailbreak::Coins")
		label:SetContentAlignment(1)
		label:SetWrap(true)
		label:Dock(FILL)
		return self.Icon:Dock(FILL)
	end
	PANEL.Setup = function(self, item)
		self:SetModelName(item.model)
		self:SetSkinID(item.skin or 0)
		self.Icon:SetModel(item.model, item.skin, item.bodygroups)
		self.Label:SetText("$" .. item.price)
		self:SetTooltip(item.title)
		self.ItemName = item.name
		self.Price = item.price
	end
	PANEL.DoRightClick = function() end
	PANEL.DoClick = function(self)
		return RunConsoleCommand("jb_buy", self.ItemName)
	end
	PANEL.PerformLayout = function(self)
		local size = VMin(10)
		self:SetSize(size, size)
		margin = VMin(0.5)
		return self:DockPadding(margin, margin, margin, margin)
	end
	do
		local CanWardenAfford = Jailbreak.CanWardenAfford
		local spectators, grey = Colors.spectators, Colors.grey
		local color = nil
		PANEL.Think = function(self)
			color = CanWardenAfford(self.Price or 0) and spectators or grey
			if self.Label:GetTextColor() ~= color then
				self.Label:SetTextColor(color)
				return self:InvalidateLayout()
			end
		end
	end
	do
		local SetDrawColor, DrawRect
		do
			local _obj_0 = surface
			SetDrawColor, DrawRect = _obj_0.SetDrawColor, _obj_0.DrawRect
		end
		PANEL.Paint = function(self, width, height)
			if self:IsHovered() and not dragndrop.IsDragging() then
				if self:IsDown() and not self.Dragging then
					SetDrawColor(255, 255, 255, 25)
				else
					SetDrawColor(255, 255, 255, 10)
				end
				return DrawRect(0, 0, width, height)
			end
		end
	end
	PANEL.PaintOver = function(self, width, height)
		return self:DrawSelections()
	end
	vgui.Register("Jailbreak:ShopItem", PANEL, "SpawnIcon")
end
Set("DesktopWindows", "warden-shop", {
	title = "#jb.warden.shop",
	icon = "icon16/cart.png",
	onewindow = true,
	order = 500,
	think = function(self)
		if GameInProgress() then
			local ply = Jailbreak.Player
			if ply:IsWarden() and ply:Alive() then
				if not self:IsVisible() then
					self:InvalidateParent()
					self:Show()
				end
				return
			end
		end
		if self:IsVisible() then
			self:InvalidateParent()
			self:Hide()
		end
		if self.Window and self.Window:IsValid() then
			return self.Window:Remove()
		end
	end,
	init = function(self, window)
		window:SetTitle("#jb.warden.shop")
		window:SetIcon("icon16/cart.png")
		window:SetSize(VMin(60), VMin(40))
		window:SetSizable(true)
		window:Center()
		window.PerformLayout = function(...)
			window:SetMinWidth(VMin(40))
			window:SetMinHeight(VMin(20))
			return DFrame.PerformLayout(...)
		end
		hook.Add("LanguageChanged", window, function()
			hook.Remove("LanguageChanged", window)
			return window:Remove()
		end)
		local ShopItems = Jailbreak.ShopItems
		do
			local menuBar = vgui.Create("DMenuBar", window)
			menuBar:DockMargin(-3, -6, -3, 0)
			menuBar:Dock(TOP)
			do
				local coins = menuBar:Add("DLabel")
				coins:SetFont("Jailbreak::Coins")
				coins:SetMouseInputEnabled(true)
				coins:SetTextColor(black)
				coins:Dock(RIGHT)
				local GetWardenCoins = Jailbreak.GetWardenCoins
				local count = 0
				coins.Think = function(self)
					count = GetWardenCoins()
					if self.Count ~= count then
						self.Count = count
						self:SetText("$" .. count)
						self:SetTooltip("$" .. count)
						return self:SizeToContentsX(VMin(1))
					end
				end
			end
			local other = menuBar:AddMenu("#jb.shop.other")
			menuBar.Other = other
			other:AddOption("#jb.shop.buy.random", function()
				local item = ShopItems[random(1, #ShopItems)]
				if not item then
					MsgN("#jb.shop.no-items")
					return
				end
				return RunConsoleCommand("jb_buy", item.name)
			end)
			xpcall(hook.Run, ErrorNoHaltWithStack, "Jailbreak::WardenShopMenuBar", menuBar, window)
		end
		margin = VMin(0.5)
		local scroll = window:Add("DScrollPanel")
		scroll:DockMargin(0, margin, 0, 0)
		scroll:Dock(FILL)
		local items = scroll:Add("DIconLayout")
		items:Dock(FILL)
		items:SetSpaceX(margin)
		items:SetSpaceY(margin)
		for _index_0 = 1, #ShopItems do
			local item = ShopItems[_index_0]
			items:Add("Jailbreak:ShopItem"):Setup(item)
		end
	end
})
do
	local AllowCustomPlayerModels, PlayerColor, PlayerWeaponColor, PlayerModel, PlayerSkin, PlayerBodyGroups = Jailbreak.AllowCustomPlayerModels, Jailbreak.PlayerColor, Jailbreak.PlayerWeaponColor, Jailbreak.PlayerModel, Jailbreak.PlayerSkin, Jailbreak.PlayerBodyGroups
	local previewOffset = Vector(-100, 0, -61)
	local TranslatePlayerModel = player_manager.TranslatePlayerModel
	local ACT_HL2MP_IDLE = ACT_HL2MP_IDLE
	local vector_origin = vector_origin
	local FixModelPath = Jailbreak.FixModelPath
	local GetCursorPos = input.GetCursorPos
	local tostring = tostring
	local concat = table.concat
	return Set("DesktopWindows", "player-options", {
		title = "#jb.player.options",
		icon = "icon16/group_gear.png",
		onewindow = true,
		order = 200,
		init = function(_, window)
			window:SetTitle("#jb.player.options")
			window:SetIcon("icon16/group_gear.png")
			window:SetSize(VMin(80), VMin(50))
			window:SetMinWidth(VMin(60))
			window:SetMinHeight(VMin(30))
			window:SetSizable(true)
			window:Center()
			local modelPreview = window:Add("DModelPanel")
			modelPreview:Dock(FILL)
			modelPreview:SetFOV(36)
			modelPreview:SetCamPos(vector_origin)
			modelPreview:SetDirectionalLight(BOX_RIGHT, Color(255, 160, 80))
			modelPreview:SetDirectionalLight(BOX_LEFT, Color(80, 160, 255))
			modelPreview:SetAmbientLight(Vector(-64, -64, -64))
			modelPreview:SetAnimated(true)
			modelPreview:SetLookAt(Vector(-100, 0, -22))
			modelPreview.Angles = Angle()
			modelPreview.DragMousePress = function(self)
				self.PressX, self.PressY = GetCursorPos()
				self.Pressed = true
			end
			modelPreview.DragMouseRelease = function(self)
				self.Pressed = false
			end
			modelPreview.LayoutEntity = function(self, entity)
				if self.bAnimated then
					self:RunAnimation()
				end
				if self.Pressed then
					local x, y = GetCursorPos()
					self.Angles[2] = self.Angles[2] - ((self.PressX or x) - x) / 2
					self.PressX, self.PressY = x, y
				end
				return entity:SetAngles(self.Angles)
			end
			local sheet = window:Add("DPropertySheet")
			sheet:Dock(RIGHT)
			sheet:SetSize(430, 0)
			do
				local panel = window:Add("DPanel")
				panel:DockPadding(8, 8, 8, 8)
				local scrollPanel = panel:Add("DScrollPanel")
				scrollPanel:Dock(FILL)
				local icons = scrollPanel:Add("DIconLayout")
				icons:Dock(FILL)
				icons.PerformLayout = function(...)
					margin = VMin(0.5)
					icons:SetSpaceX(margin)
					icons:SetSpaceY(margin)
					return DIconLayout.PerformLayout(...)
				end
				do
					local selectModel
					selectModel = function(self)
						return PlayerModel:SetString(self.ModelName)
					end
					local openMenu
					openMenu = function(self)
						local menu = DermaMenu()
						menu:AddOption("#spawnmenu.menu.copy", function()
							return SetClipboardText(self.ModelPath)
						end):SetIcon("icon16/page_copy.png")
						return menu:Open()
					end
					local isFemalePrison, allowedPlayerModels = Jailbreak.IsFemalePrison(), { }
					local _list_0 = Jailbreak.PlayerModels[TEAM_PRISONER][isFemalePrison]
					for _index_0 = 1, #_list_0 do
						local modelPath = _list_0[_index_0]
						allowedPlayerModels[modelPath] = true
					end
					local _list_1 = Jailbreak.PlayerModels[TEAM_GUARD][isFemalePrison]
					for _index_0 = 1, #_list_1 do
						local modelPath = _list_1[_index_0]
						allowedPlayerModels[modelPath] = true
					end
					local customAllowed = AllowCustomPlayerModels:GetBool()
					for name, modelPath in SortedPairs(player_manager.AllValidModels()) do
						modelPath = FixModelPath(modelPath)
						if not (customAllowed or allowedPlayerModels[modelPath]) then
							goto _continue_0
						end
						local icon = icons:Add("SpawnIcon")
						icon:SetModel(modelPath)
						icon:SetSize(64, 64)
						icon:SetTooltip(name)
						icon.ModelPath = modelPath
						icon.ModelName = name
						icon.DoClick = selectModel
						icon.OpenMenu = openMenu
						::_continue_0::
					end
				end
				sheet:AddSheet("#smwidget.model", panel, "icon16/user_edit.png")
			end
			do
				local panel = window:Add("DPanel")
				panel:DockPadding(8, 8, 8, 8)
				local scrollPanel = panel:Add("DScrollPanel")
				scrollPanel:Dock(FILL)
				scrollPanel.PerformLayout = function(...)
					local canvas = scrollPanel:GetCanvas()
					if canvas and canvas:IsValid() then
						margin = VMin(1)
						canvas:DockPadding(margin, margin, margin, margin)
					end
					return DScrollPanel.PerformLayout(...)
				end
				do
					local label = scrollPanel:Add("DLabel")
					label:SetText("#smwidget.color_plr")
					label:SetTextColor(black)
					label:Dock(TOP)
					local playerColor = scrollPanel:Add("DColorMixer")
					playerColor:SetAlphaBar(false)
					playerColor:SetPalette(false)
					playerColor:Dock(TOP)
					playerColor:SetSize(200, min(window:GetTall() / 3, 260))
					playerColor.ValueChanged = function(self)
						local vector = self:GetVector()
						local entity = modelPreview.Entity
						if entity and entity:IsValid() then
							entity:SetPlayerColor(vector)
						else
							timer.Simple(0, function()
								if playerColor:IsValid() then
									return playerColor:ValueChanged()
								end
							end)
						end
						return PlayerColor:SetString(tostring(vector))
					end
					playerColor:SetVector(Vector(PlayerColor:GetString()))
				end
				do
					local label = scrollPanel:Add("DLabel")
					label:SetText("#smwidget.color_wep")
					label:DockMargin(0, 32, 0, 0)
					label:SetTextColor(black)
					label:Dock(TOP)
					local weaponColor = scrollPanel:Add("DColorMixer")
					weaponColor:SetAlphaBar(false)
					weaponColor:SetPalette(false)
					weaponColor:Dock(TOP)
					weaponColor:SetSize(200, min(window:GetTall() / 3, 260))
					weaponColor.ValueChanged = function(self)
						return PlayerWeaponColor:SetString(tostring(self:GetVector()))
					end
					weaponColor:SetVector(Vector(PlayerWeaponColor:GetString()))
				end
				sheet:AddSheet("#smwidget.colors", panel, "icon16/paintcan.png")
			end
			do
				local panel = window:Add("DPanel")
				panel:DockPadding(8, 8, 8, 8)
				local scrollPanel = panel:Add("DScrollPanel")
				scrollPanel:Dock(FILL)
				scrollPanel.PerformLayout = function(...)
					local canvas = scrollPanel:GetCanvas()
					if canvas and canvas:IsValid() then
						margin = VMin(1)
						canvas:DockPadding(margin, margin, margin, margin)
					end
					return DScrollPanel.PerformLayout(...)
				end
				local bodygroupsSheet = sheet:AddSheet("#smwidget.bodygroups", panel, "icon16/text_list_bullets.png")
				local UpdateBodyGroups
				UpdateBodyGroups = function(pnl, value)
					local previewEntity = modelPreview.Entity
					if previewEntity then
						previewEntity:SetBodygroup(pnl.BodygroupID, Round(value))
					end
					local str = Explode(" ", PlayerBodyGroups:GetString())
					if #str < pnl.BodygroupID + 1 then
						for index = 1, pnl.BodygroupID + 1 do
							str[index] = str[index] or 0
						end
					end
					str[pnl.BodygroupID + 1] = Round(value)
					return PlayerBodyGroups:SetString(concat(str, " "))
				end
				local SetSkin
				SetSkin = function(self, value)
					value = floor(value)
					local previewEntity = modelPreview.Entity
					if previewEntity then
						previewEntity:SetSkin(value)
					end
					return PlayerSkin:SetString(value)
				end
				local SetupModel
				SetupModel = function(modelName)
					if not scrollPanel:IsValid() then
						return
					end
					scrollPanel:Clear()
					if not modelPreview:IsValid() then
						return
					end
					modelPreview:SetModel(FixModelPath(TranslatePlayerModel(modelName)))
					local previewEntity = modelPreview.Entity
					if not previewEntity then
						return
					end
					previewEntity:SetPos(previewOffset)
					previewEntity:SetPlayerColor(Vector(PlayerColor:GetString()))
					local bodygroupsTab = bodygroupsSheet.Tab
					if bodygroupsTab and bodygroupsTab:IsValid() then
						if bodygroupsTab:IsVisible() then
							bodygroupsTab:SetVisible(false)
							bodygroupsTab:InvalidateParent()
						end
						local skinCount = previewEntity:SkinCount() - 1
						if skinCount > 0 then
							local skins = scrollPanel:Add("DNumSlider")
							skins:Dock(TOP)
							skins:SetText("#jb.skin")
							skins:SetDark(true)
							skins:SetTall(50)
							skins:SetDecimals(0)
							skins:SetMax(skinCount)
							skins:SetValue(PlayerSkin:GetInt())
							skins.OnValueChanged = SetSkin
							if not bodygroupsTab:IsVisible() then
								bodygroupsTab:SetVisible(true)
								bodygroupsTab:InvalidateParent()
							end
						end
						local groups = Explode(" ", PlayerBodyGroups:GetString())
						for index = 0, previewEntity:GetNumBodyGroups() - 1 do
							if previewEntity:GetBodygroupCount(index) <= 1 then
								goto _continue_0
							end
							local bodygroup = scrollPanel:Add("DNumSlider")
							bodygroup:Dock(TOP)
							local str = previewEntity:GetBodygroupName(index)
							bodygroup:SetText(upper(sub(str, 1, 1)) .. sub(str, 2))
							bodygroup:SetDark(true)
							bodygroup:SetTall(50)
							bodygroup:SetDecimals(0)
							bodygroup.BodygroupID = index
							bodygroup:SetMax(previewEntity:GetBodygroupCount(index) - 1)
							bodygroup:SetValue(groups[index + 1] or 0)
							bodygroup.OnValueChanged = UpdateBodyGroups
							previewEntity:SetBodygroup(index, groups[index + 1] or 0)
							if not bodygroupsTab:IsVisible() then
								bodygroupsTab:SetVisible(true)
								bodygroupsTab:InvalidateParent()
							end
							::_continue_0::
						end
					end
					sheet.tabScroller:InvalidateLayout()
					local sequence = previewEntity:SelectWeightedSequence(ACT_HL2MP_IDLE)
					if sequence > 0 then
						return previewEntity:ResetSequence(sequence)
					end
				end
				hook.Add("PlayerModelChanged", window, function(_, modelName)
					SetupModel(modelName)
					return
				end)
				SetupModel(Jailbreak.SelectedPlayerModel)
			end
			do
				local panel = window:Add("DPanel")
				panel:DockPadding(8, 8, 8, 8)
				local scrollPanel = panel:Add("DScrollPanel")
				scrollPanel:Dock(FILL)
				scrollPanel.PerformLayout = function(...)
					local canvas = scrollPanel:GetCanvas()
					if canvas and canvas:IsValid() then
						margin = VMin(1)
						canvas:DockPadding(margin, margin, margin, margin)
					end
					return DScrollPanel.PerformLayout(...)
				end
				do
					local handsTransparency = scrollPanel:Add("DNumSlider")
					handsTransparency:Dock(TOP)
					handsTransparency:SetText("#jb.hands-transparency")
					handsTransparency:SetDark(true)
					handsTransparency:SetTall(50)
					handsTransparency:SetDecimals(2)
					handsTransparency:SetMax(1)
					handsTransparency:SetValue(Jailbreak.HandsTransparency:GetFloat())
					handsTransparency.OnValueChanged = function(self, value)
						return Jailbreak.HandsTransparency:SetFloat(value)
					end
				end
				do
					local notifyLifetime = scrollPanel:Add("DNumSlider")
					notifyLifetime:Dock(TOP)
					notifyLifetime:SetText("#jb.pickup-notify-lifetime")
					notifyLifetime:SetDecimals(0)
					notifyLifetime:SetDark(true)
					notifyLifetime:SetTall(50)
					notifyLifetime:SetMax(60)
					notifyLifetime:SetValue(Jailbreak.PickupNotifyLifetime:GetInt())
					notifyLifetime.OnValueChanged = function(self, value)
						return Jailbreak.PickupNotifyLifetime:SetInt(value)
					end
				end
				hook.Call("ClientOptionsLoaded", nil, scrollPanel)
				return sheet:AddSheet("#jb.options", panel, "icon16/cog.png")
			end
		end
	})
end
