local Jailbreak = Jailbreak
local GM = GM
local PlaySound, DrawRect, SetDrawColor, DrawText, SetTextColor, SetTextPos, GetTextSize, SetFont
do
	local _obj_0 = surface
	PlaySound, DrawRect, SetDrawColor, DrawText, SetTextColor, SetTextPos, GetTextSize, SetFont = _obj_0.PlaySound, _obj_0.DrawRect, _obj_0.SetDrawColor, _obj_0.DrawText, _obj_0.SetTextColor, _obj_0.SetTextPos, _obj_0.GetTextSize, _obj_0.SetFont
end
local TeamIsJoinable, ChangeTeam, Colors, VMin, Translate, GetTeamColor, GetTeamPlayersCount = Jailbreak.TeamIsJoinable, Jailbreak.ChangeTeam, Jailbreak.Colors, Jailbreak.VMin, Jailbreak.Translate, Jailbreak.GetTeamColor, Jailbreak.GetTeamPlayersCount
local ceil, min, max, floor, log, Clamp
do
	local _obj_0 = math
	ceil, min, max, floor, log, Clamp = _obj_0.ceil, _obj_0.min, _obj_0.max, _obj_0.floor, _obj_0.log, _obj_0.Clamp
end
local IsGameUIVisible, HideGameUI
do
	local _obj_0 = gui
	IsGameUIVisible, HideGameUI = _obj_0.IsGameUIVisible, _obj_0.HideGameUI
end
local Create, Register
do
	local _obj_0 = vgui
	Create, Register = _obj_0.Create, _obj_0.Register
end
local PANEL_META = PANEL_META
local GetPhrase = language.GetPhrase
local IsKeyDown = input.IsKeyDown
local Run, Add
do
	local _obj_0 = hook
	Run, Add = _obj_0.Run, _obj_0.Add
end
local IsValid = IsValid
local format = string.format
local GetScore = team.GetScore
local select = select
local pairs = pairs
local TEAM_SPECTATOR = TEAM_SPECTATOR
local ROUND_RUNNING = ROUND_RUNNING
local TEAM_PRISONER = TEAM_PRISONER
local TEAM_GUARD = TEAM_GUARD
local dark_grey, black, white, light_grey = Colors.dark_grey, Colors.black, Colors.white, Colors.light_grey
local InvalidateLayout, GetParent = PANEL_META.InvalidateLayout, PANEL_META.GetParent
do
	local GetText = PANEL_META.GetText
	DLabel.Think = function(self)
		if self.m_bAutoStretchVertical then
			local length = #GetText(self)
			if length ~= self.m_iLastTextLength then
				self.m_iLastTextLength = length
				return self:SizeToContentsY()
			end
		end
	end
end
do
	local dark_white = Colors.dark_white
	DButton.Paint = function(self, w, h)
		if self:GetPaintBackground() then
			SetDrawColor(dark_white.r, dark_white.g, dark_white.b, 240)
			DrawRect(0, 0, w, h)
			SetDrawColor(dark_grey.r, dark_grey.g, dark_grey.b, 255)
			DrawRect(0, 0, w, 1)
			DrawRect(0, 1, 1, h - 2)
			DrawRect(w - 1, 1, 1, h - 2)
			return DrawRect(0, h - 1, w, 1)
		end
	end
	Button.Paint = DButton.Paint
end
do
	local SkinChangeIndex, GetNamedSkin, GetDefaultSkin
	do
		local _obj_0 = derma
		SkinChangeIndex, GetNamedSkin, GetDefaultSkin = _obj_0.SkinChangeIndex, _obj_0.GetNamedSkin, _obj_0.GetDefaultSkin
	end
	local getSkin
	getSkin = function(self)
		local skin = nil
		if SkinChangeIndex() == self.m_iSkinIndex then
			skin = self.m_Skin
			if skin ~= nil then
				return skin
			end
		end
		if not skin and self.m_ForceSkinName then
			skin = GetNamedSkin(self.m_ForceSkinName)
		end
		local parent = GetParent(self)
		if not skin and parent and parent:IsValid() then
			skin = getSkin(parent)
		end
		if not skin then
			skin = GetDefaultSkin()
		end
		self.m_Skin, self.m_iSkinIndex = skin, SkinChangeIndex()
		InvalidateLayout(self, false)
		return skin
	end
	PANEL_META.GetSkin = getSkin
end
GM.ContextMenuEnabled = function()
	return true
end
GM.ContextMenuOpen = function()
	return true
end
do
	local GetRoundState, GetRemainingTime = Jailbreak.GetRoundState, Jailbreak.GetRemainingTime
	local GetCursorPos, SetCursorPos
	do
		local _obj_0 = input
		GetCursorPos, SetCursorPos = _obj_0.GetCursorPos, _obj_0.SetCursorPos
	end
	local CloseDermaMenus = CloseDermaMenus
	local PANEL = { }
	AccessorFunc(PANEL, "m_bHangOpen", "HangOpen")
	PANEL.Init = function(self)
		self.CursorX, self.CursorY = 0, 0
		self:SetWorldClicker(true)
		self.m_bHangOpen = false
		self:Dock(FILL)
		local scrollPanel = self:Add("DScrollPanel")
		self.ScrollPanel = scrollPanel
		scrollPanel.VBar:SetWide(0)
		scrollPanel:Dock(LEFT)
		scrollPanel.OnMousePressed = function(_, ...)
			return self:OnMousePressed(...)
		end
		Add("LanguageChanged", self, function()
			return self:InvalidateChildren(true)
		end)
		Run("ContextMenuCreated", self)
		self:SetVisible(false)
		local desktopWindows = { }
		do
			local index = 1
			for _, desktopWindow in pairs(list.Get("DesktopWindows")) do
				desktopWindows[index] = desktopWindow
				index = index + 1
			end
		end
		table.sort(desktopWindows, function(a, b)
			if a.order and b.order then
				return a.order < b.order
			end
			return a.title < b.title
		end)
		for _index_0 = 1, #desktopWindows do
			local data = desktopWindows[_index_0]
			self:AddItem(data)
		end
	end
	PANEL.PerformLayout = function(self)
		local scrollPanel = self.ScrollPanel
		local width = 0
		local _list_0 = scrollPanel:GetCanvas():GetChildren()
		for _index_0 = 1, #_list_0 do
			local child = _list_0[_index_0]
			if child:GetName() ~= "Jailbreak::ContextMenu - Button" then
				goto _continue_0
			end
			local paddingLeft, paddingRight = child:GetDockPadding()
			width = max(width, paddingLeft + child.Label:GetTextSize() + paddingRight)
			::_continue_0::
		end
		return scrollPanel:SetWide(width)
	end
	PANEL.AddItem = function(self, data)
		local scrollPanel = self.ScrollPanel
		if not scrollPanel:IsValid() then
			return
		end
		local title = data.title
		local button = scrollPanel:Add("Jailbreak::ContextMenu - Button")
		button.Image:SetImage(data.icon)
		button:SetTooltip(title)
		button.Title = title
		InvalidateLayout(self)
		local created = data.created
		if isfunction(created) then
			created(button)
		end
		local think = data.think
		if isfunction(think) then
			Add("Think", button, think)
		end
		local click = data.click
		if isfunction(click) then
			button.DoClick = click
		end
		local init = data.init
		if isfunction(init) then
			button.DoClick = function()
				local window = button.Window
				self.Window = window
				if data.onewindow and IsValid(window) then
					window:Remove()
				end
				local contextMenu = Jailbreak.ContextMenu
				if not IsValid(contextMenu) then
					return
				end
				window = contextMenu:Add("DFrame")
				button.Window = window
				window:SetSize(data.width or 960, data.height or 700)
				window:SetTitle(title)
				window:Center()
				return init(button, window)
			end
		end
		return button
	end
	PANEL.Open = function(self)
		self:SetHangOpen(false)
		if IsValid(g_SpawnMenu) and g_SpawnMenu:IsVisible() then
			g_SpawnMenu:Close(true)
		end
		if self:IsVisible() then
			return
		end
		CloseDermaMenus()
		self:MakePopup()
		self:SetVisible(true)
		self:SetKeyboardInputEnabled(false)
		self:SetMouseInputEnabled(true)
		SetCursorPos(self.CursorX, self.CursorY)
		return InvalidateLayout(self, true)
	end
	PANEL.Close = function(self, bSkipAnim)
		if self:GetHangOpen() then
			self:SetHangOpen(false)
			return
		end
		self.CursorX, self.CursorY = GetCursorPos()
		CloseDermaMenus()
		self:SetKeyboardInputEnabled(false)
		self:SetMouseInputEnabled(false)
		self:SetAlpha(255)
		return self:SetVisible(false)
	end
	PANEL.StartKeyFocus = function(self, pPanel)
		self:SetKeyboardInputEnabled(true)
		return self:SetHangOpen(true)
	end
	PANEL.EndKeyFocus = function(self, pPanel)
		return self:SetKeyboardInputEnabled(false)
	end
	do
		local ScreenToVector = gui.ScreenToVector
		PANEL.OnMousePressed = function(_, code)
			return Run("GUIMousePressed", code, ScreenToVector(GetCursorPos()))
		end
		PANEL.OnMouseReleased = function(_, code)
			return Run("GUIMouseReleased", code, ScreenToVector(GetCursorPos()))
		end
	end
	PANEL.Paint = function(self, width, height)
		if GetRoundState() ~= ROUND_RUNNING then
			return
		end
		local remainingTime = GetRemainingTime()
		if remainingTime == 0 then
			return
		end
		SetFont("Jailbreak::RoundState")
		local text = format(GetPhrase("jb.round.2"), remainingTime)
		local x, y = Jailbreak.ScreenCenterX - GetTextSize(text) / 2, VMin(1)
		SetTextPos(x - 1, y - 1)
		SetTextColor(black.r, black.g, black.b, 50)
		DrawText(text)
		SetTextPos(x + 3, y + 3)
		SetTextColor(black.r, black.g, black.b, 120)
		DrawText(text)
		SetTextColor(white)
		SetTextPos(x, y)
		return DrawText(text)
	end
	Register("Jailbreak::ContextMenu", PANEL, "EditablePanel")
	do
		Jailbreak.Font("Jailbreak::ContextMenu - Button", "Roboto Mono Bold", 1.25)
		PANEL = { }
		PANEL.Init = function(self)
			self:SetText("")
			self:Dock(TOP)
			self.Title = ""
			local label = self:Add("DLabel")
			self.Label = label
			label:SetTextColor(white)
			label:SetContentAlignment(5)
			label:SetFont("Jailbreak::ContextMenu - Button")
			label:SetExpensiveShadow(1, Color(0, 0, 0, 200))
			label:Dock(BOTTOM)
			local image = self:Add("DImage")
			self.Image = image
			image:SetMouseInputEnabled(false)
			return image:Dock(FILL)
		end
		PANEL.DoClick = function() end
		PANEL.GetImage = function(self)
			return self.Image:GetImage()
		end
		PANEL.SetImage = function(self, materialPath)
			self.Image:SetImage(materialPath)
			return InvalidateLayout(self)
		end
		PANEL.OnCursorEntered = function(self)
			if not self:IsEnabled() then
				return
			end
			return PlaySound("garrysmod/ui_hover.wav")
		end
		PANEL.OnMouseReleased = function(self, mousecode)
			self:MouseCapture(false)
			if not self:IsEnabled() then
				return
			end
			if not self.Depressed and dragndrop.m_DraggingMain ~= self then
				return
			end
			if self.Depressed then
				self.Depressed = nil
				self:OnReleased()
				InvalidateLayout(self, true)
			end
			if self:DragMouseRelease(mousecode) then
				return
			end
			if self:IsSelectable() and mousecode == MOUSE_LEFT then
				local canvas = self:GetSelectionCanvas()
				if canvas then
					canvas:UnselectAll()
				end
			end
			if not self.Hovered then
				return
			end
			self.Depressed = true
			PlaySound("garrysmod/ui_click.wav")
			if mousecode == MOUSE_RIGHT then
				self:DoRightClick()
			end
			if mousecode == MOUSE_LEFT then
				self:DoClickInternal()
				self:DoClick()
			end
			if mousecode == MOUSE_MIDDLE then
				self:DoMiddleClick()
			end
			self.Depressed = nil
		end
		PANEL.PerformLayout = function(self)
			local margin = VMin(0.5)
			local margin2 = margin * 2
			self.Image:DockMargin(margin2, margin2, margin2, 0)
			self:DockPadding(margin, margin, margin, 0)
			local width = self:GetWide()
			local height = width
			local label = self.Label
			if IsValid(label) then
				label:SetText(self.Title or label:GetText())
				height = height + select(2, label:GetTextSize())
			end
			return self:SetTall(height)
		end
		PANEL.Paint = function(width, height) end
		Register("Jailbreak::ContextMenu - Button", PANEL, "DButton")
	end
	GM.OnContextMenuOpen = function(self)
		if not Run("ContextMenuOpen") then
			return
		end
		local contextMenu = Jailbreak.ContextMenu
		if not Run("ContextMenuEnabled") then
			if IsValid(contextMenu) then
				contextMenu:Remove()
			end
			return
		end
		if not IsValid(contextMenu) then
			contextMenu = Create("Jailbreak::ContextMenu")
			Jailbreak.ContextMenu = contextMenu
		end
		if not IsValid(contextMenu) then
			return
		end
		if not contextMenu:IsVisible() then
			contextMenu:Open()
		end
		return Run("ContextMenuOpened", contextMenu)
	end
	GM.OnContextMenuClose = function(self)
		local contextMenu = Jailbreak.ContextMenu
		if not IsValid(contextMenu) then
			return
		end
		if Jailbreak.Developer then
			contextMenu:Remove()
		else
			contextMenu:Close()
		end
		return Run("ContextMenuClosed", contextMenu)
	end
end
do
	local showTeam
	showTeam = function()
		local menuIsVisible = IsGameUIVisible()
		local teamSelect = Jailbreak.TeamSelect
		if not IsValid(teamSelect) then
			if menuIsVisible then
				return
			end
			teamSelect = Create("Jailbreak::TeamSelect")
			Jailbreak.TeamSelect = teamSelect
		end
		if not IsValid(teamSelect) then
			return
		end
		if teamSelect:IsVisible() then
			return teamSelect:Hide()
		elseif not menuIsVisible then
			return teamSelect:Show()
		end
	end
	Jailbreak.ShowTeam = showTeam
	concommand.Add("jb_showteam", showTeam)
end
do
	Jailbreak.Font("Jailbreak::TeamSelect - Button", "Roboto Mono Medium", 4)
	local PANEL = { }
	PANEL.Init = function(self)
		self:SetTextColor(white)
		return self:SetFont("Jailbreak::TeamSelect - Button")
	end
	PANEL.OnCursorEntered = function(self)
		if not self:IsEnabled() then
			return
		end
		return PlaySound("garrysmod/ui_hover.wav")
	end
	PANEL.Paint = function(self, width, height)
		local color = self.Color
		if not color then
			return
		end
		local r, g, b = color:Unpack()
		local a = 180
		if not self:IsEnabled() then
			a = 150
		elseif self.Hovered then
			a = 250
		end
		SetDrawColor(r, g, b, a)
		return DrawRect(0, 0, width, height)
	end
	PANEL.DoClick = function(self)
		if not self:IsEnabled() then
			return
		end
		PlaySound("garrysmod/ui_click.wav")
		local teamID = self.TeamID
		if teamID then
			ChangeTeam(teamID)
		else
			local ply = Jailbreak.Player
			if not IsValid(ply) then
				return
			end
			for i = 1, 2 do
				if i ~= ply:Team() and TeamIsJoinable(i) then
					ChangeTeam(i)
					break
				end
			end
		end
		local panel = self.MainPanel
		if IsValid(panel) then
			return panel:Remove()
		end
	end
	PANEL.SetText = function(self, str)
		return PANEL_META.SetText(self, Translate(str))
	end
	PANEL.Think = function(self)
		local teamID = self.TeamID
		if not teamID then
			local enabled = false
			for i = 1, 2 do
				if TeamIsJoinable(i) then
					enabled = true
					break
				end
			end
			if enabled ~= self:IsEnabled() then
				self:SetEnabled(enabled)
				self:SetCursor(enabled and "hand" or "no")
			end
			return
		end
		if not self.Color then
			self.Color = GetTeamColor(teamID)
		end
		local count = GetTeamPlayersCount(nil, teamID)[1]
		if count ~= self.Count then
			self:SetText("#jb.team." .. teamID .. " x" .. count)
			self.Count = count
		end
		local ply = Jailbreak.Player
		if not IsValid(ply) then
			return
		end
		local enabled = teamID ~= ply:Team() and TeamIsJoinable(teamID)
		if enabled ~= self:IsEnabled() then
			self:SetEnabled(enabled)
			return self:SetCursor(enabled and "hand" or "no")
		end
	end
	Register("Jailbreak::TeamSelect - Button", PANEL, "DButton")
end
do
	local closeKeys = {
		[107] = true,
		[108] = true,
		[109] = true
	}
	Add("PlayerButtonDown", "Jailbreak::TeamSelect", function(self, key)
		if key == 70 then
			local panel = Jailbreak.TeamSelect
			if IsValid(panel) and panel:IsVisible() then
				HideGameUI()
				panel:Hide()
			end
			return
		end
		if closeKeys[key] == nil then
			return
		end
		local panel = Jailbreak.TeamSelect
		if IsValid(panel) and not (panel.Hovered or panel:IsChildHovered()) then
			return panel:Hide()
		end
	end)
end
do
	Jailbreak.Font("Jailbreak::TeamSelect", "Roboto Mono Bold", 4)
	local PANEL = { }
	PANEL.Init = function(self)
		self:SetKeyboardInputEnabled(false)
		self:SetVisible(false)
		do
			local title = self:Add("DLabel")
			self.Title = title
			title:SetText("#jb.team-select")
			title:SetTextColor(white)
			title:SetContentAlignment(5)
			title:SetFont("Jailbreak::TeamSelect")
			title:Dock(TOP)
			title.PerformLayout = function(self)
				local parent = GetParent(self)
				if IsValid(parent) then
					return self:SetTall(parent:GetTall() * 0.1)
				end
			end
		end
		local subPanel = self:Add("EditablePanel")
		subPanel:Dock(FILL)
		do
			local button = subPanel:Add("Jailbreak::TeamSelect - Button")
			self.Guards = button
			button.TeamID = TEAM_GUARD
			button.MainPanel = self
			button:Dock(LEFT)
			button.PerformLayout = function(self)
				return self:SetWide(subPanel:GetWide() * 0.5 - 8)
			end
			InvalidateLayout(button, true)
		end
		do
			local button = subPanel:Add("Jailbreak::TeamSelect - Button")
			self.Prisoners = button
			button.TeamID = TEAM_PRISONER
			button.MainPanel = self
			button:Dock(RIGHT)
			button.PerformLayout = function(self)
				return self:SetWide(subPanel:GetWide() * 0.5 - 8)
			end
			InvalidateLayout(button, true)
		end
		do
			local button = self:Add("Jailbreak::TeamSelect - Button")
			self.Spectators = button
			button:SetText("#jb.spectate")
			button.TeamID = TEAM_SPECTATOR
			button.MainPanel = self
			button:SetTextColor(dark_grey)
			button:Dock(BOTTOM)
			button.PerformLayout = function(self)
				local parent = GetParent(self)
				if IsValid(parent) then
					return self:SetTall(parent:GetTall() * 0.1)
				end
			end
			InvalidateLayout(button, true)
		end
		do
			local button = self:Add("Jailbreak::TeamSelect - Button")
			self.Random = button
			button:SetText("#jb.select-random-team")
			button.Color = Colors.asparagus
			button.MainPanel = self
			button:Dock(BOTTOM)
			button.PerformLayout = function(self)
				local parent = GetParent(self)
				if IsValid(parent) then
					return self:SetTall(parent:GetTall() * 0.1)
				end
			end
			InvalidateLayout(button, true)
		end
		return InvalidateLayout(self, true)
	end
	PANEL.Think = function(self)
		if not self:IsVisible() then
			return
		end
		if IsKeyDown(70) then
			return self:Hide()
		elseif IsKeyDown(2) then
			if not TeamIsJoinable(TEAM_GUARD) then
				return
			end
			ChangeTeam(TEAM_GUARD)
			return self:Hide()
		elseif IsKeyDown(3) then
			if not TeamIsJoinable(TEAM_PRISONER) then
				return
			end
			ChangeTeam(TEAM_PRISONER)
			return self:Hide()
		elseif IsKeyDown(4) then
			local ply = Jailbreak.Player
			if not IsValid(ply) then
				return
			end
			for teamID = 1, 2 do
				if teamID ~= ply:Team() and TeamIsJoinable(teamID) then
					ChangeTeam(teamID)
					self:Hide()
					break
				end
			end
		elseif IsKeyDown(5) then
			ChangeTeam(TEAM_SPECTATOR)
			return self:Hide()
		end
	end
	PANEL.PerformLayout = function(self, width, height)
		local padding = VMin(1.5)
		self:DockPadding(padding, padding, padding, padding)
		local title = self.Title
		if IsValid(title) then
			title:DockMargin(0, 0, 0, padding)
		end
		local spectators = self.Spectators
		if IsValid(spectators) then
			spectators:DockMargin(0, padding, 0, 0)
		end
		local random = self.Random
		if IsValid(random) then
			random:DockMargin(0, padding, 0, 0)
		end
		self:SetSize(Jailbreak.ScreenWidth * 0.5, Jailbreak.ScreenHeight * 0.5)
		return self:Center()
	end
	PANEL.Hide = function(self)
		if not self:IsVisible() then
			return
		end
		HideGameUI()
		if Jailbreak.Developer then
			self:Remove()
			return
		end
		return self:SetVisible(false)
	end
	PANEL.Show = function(self)
		if self:IsVisible() then
			return
		end
		InvalidateLayout(self, true)
		self:SetVisible(true)
		return self:MakePopup()
	end
	PANEL.Paint = function(self, width, height)
		SetDrawColor(dark_grey.r, dark_grey.g, dark_grey.b, 240)
		return DrawRect(0, 0, width, height)
	end
	Register("Jailbreak::TeamSelect", PANEL, "EditablePanel")
end
do
	Jailbreak.Font("Jailbreak::Scoreboard - Player", "Roboto Mono Bold", 2)
	local PANEL = { }
	PANEL.ToggleMenu = function(self)
		local menu = self.Menu
		if IsValid(menu) then
			menu:Remove()
			return
		end
		local ply = self.Player
		if not (IsValid(ply) and ply:IsPlayer()) then
			return
		end
		menu = DermaMenu()
		self.Menu = menu
		if not ply:IsBot() then
			local steamid64 = ply:SteamID64()
			local option = menu:AddOption("#jb.user.profile", function()
				return gui.OpenURL("https://steamcommunity.com/profiles/" .. steamid64)
			end)
			option:SetIcon("icon16/vcard.png")
			option = menu:AddOption("#jb.user.steamid64", function()
				notification.AddLegacy("#jb.notify.steamid64", NOTIFY_GENERIC, 3)
				PlaySound("buttons/button18.wav")
				return SetClipboardText(steamid64)
			end)
			option:SetIcon("icon16/page_copy.png")
		end
		do
			local isMuted = ply:IsMuted()
			local option = menu:AddOption("#jb.user." .. (isMuted and "un" or "") .. "mute", function()
				if ply:IsValid() then
					return ply:SetMuted(not isMuted)
				end
			end)
			option:SetIcon(isMuted and "icon16/sound_mute.png" or "icon16/sound.png")
		end
		local pl = Jailbreak.Player
		if pl and pl:IsValid() and pl:IsAdmin() then
			local subMenu, option = menu:AddSubMenu("#jb.team-select")
			option:SetIcon("icon16/user_go.png")
			option = subMenu:AddOption("#jb.team.1", function()
				if ply:IsValid() then
					return RunConsoleCommand("jb_move_player", ply:EntIndex(), TEAM_GUARD)
				end
			end)
			option:SetIcon("icon16/user.png")
			option = subMenu:AddOption("#jb.team.2", function()
				if ply:IsValid() then
					return RunConsoleCommand("jb_move_player", ply:EntIndex(), TEAM_PRISONER)
				end
			end)
			option:SetIcon("icon16/user_orange.png")
			option = subMenu:AddOption("#jb.team.1002", function()
				if ply:IsValid() then
					return RunConsoleCommand("jb_move_player", ply:EntIndex(), TEAM_SPECTATOR)
				end
			end)
			option:SetIcon("icon16/user_gray.png")
			option = menu:AddOption("#jb.user.respawn", function()
				if ply:IsValid() then
					return RunConsoleCommand("jb_respawn", ply:EntIndex())
				end
			end)
			option:SetIcon("icon16/arrow_refresh.png")
			option = menu:AddOption("#jb.user.kick", function()
				if ply:IsValid() then
					return RunConsoleCommand("jb_kick_player", ply:EntIndex())
				end
			end)
			option:SetIcon("icon16/user_delete.png")
		end
		return menu:Open()
	end
	do
		local DrawTexturedRect, SetMaterial
		do
			local _obj_0 = surface
			DrawTexturedRect, SetMaterial = _obj_0.DrawTexturedRect, _obj_0.SetMaterial
		end
		local GetFriendStatus = PLAYER.GetFriendStatus
		local Material = Jailbreak.Material
		local default = Material("icon16/user.png")
		local statuses = {
			["friend"] = Material("icon16/user_green.png"),
			["blocked"] = Material("icon16/user_delete.png"),
			["requesting"] = Material("icon16/user_add.png")
		}
		PANEL.AvatarPaintOver = function(self, width, height)
			local ply, material = self.m_ePlayer, nil
			if ply and ply:IsValid() and not ply:IsLocalPlayer() then
				if ply:IsWarden() then
					material = Material("icon16/user_suit.png")
				elseif ply:IsBot() then
					material = Material("icon16/tux.png")
				else
					material = statuses[GetFriendStatus(ply)]
				end
			end
			SetDrawColor(255, 255, 255)
			SetMaterial(material or default)
			return DrawTexturedRect(-8, height - 8, 16, 16)
		end
	end
	PANEL.Init = function(self)
		self:Dock(TOP)
		local avatar = self:Add("AvatarImage")
		self.Avatar = avatar
		avatar:Dock(LEFT)
		avatar:NoClipping(true)
		avatar.OnMousePressed = function()
			return self:ToggleMenu()
		end
		avatar.PaintOver = self.AvatarPaintOver
		local SetPlayer = avatar.SetPlayer
		avatar.SetPlayer = function(self, ply, ...)
			SetPlayer(self, ply, ...)
			self.m_ePlayer = ply
		end
		local nickname = self:Add("DLabel")
		nickname:Dock(FILL)
		self.Nickname = nickname
		nickname:SetFont("Jailbreak::Scoreboard - Player")
		nickname:SetMouseInputEnabled(true)
		nickname:SetTextColor(dark_grey)
		nickname:SetContentAlignment(4)
		local ping = self:Add("DLabel")
		ping:Dock(RIGHT)
		self.Ping = ping
		ping:SetFont("Jailbreak::Scoreboard - Player")
		ping:SetMouseInputEnabled(true)
		ping:SetTextColor(dark_grey)
		ping:SetContentAlignment(5)
		ping:SetZPos(1000)
		ping:SetText("")
		local ratio = self:Add("DLabel")
		ratio:Dock(RIGHT)
		self.Ratio = ratio
		ratio:SetFont("Jailbreak::Scoreboard - Player")
		ratio:SetMouseInputEnabled(true)
		ratio:SetContentAlignment(5)
		ratio:SetTextColor(dark_grey)
		ratio:SetZPos(2000)
		ratio:SetText("")
		self.Color = light_grey
		self.Text = "unknown"
	end
	PANEL.Think = function(self)
		local ply = self.Player
		if ply == nil then
			return
		end
		if not ply:IsValid() or ply:Team() ~= self.TeamID then
			Jailbreak.ScoreBoard:Perform()
			self:Remove()
			return
		end
		local alive = ply:Alive()
		if alive ~= self.Alive then
			self.Alive = alive
			self.Color = ply:Alive() and ply:GetTeamColor() or light_grey
		end
		local text = ply:Nick()
		if text ~= self.Text then
			self.Text = text
			local nickname = self.Nickname
			if IsValid(nickname) then
				nickname:SetTooltip(text)
				nickname:SetText(text)
			end
		end
		local ping, pingStr = self.Ping, tostring(ply:Ping() or 0) .. "ms"
		if IsValid(ping) and ping:GetText() ~= pingStr then
			ping:SetTooltip(pingStr)
			ping:SetText(pingStr)
		end
		local ratio, ratioStr = self.Ratio, tostring(ply:Frags()) .. ":" .. tostring(ply:Deaths())
		if IsValid(ratio) and ratio:GetText() ~= ratioStr then
			ratio:SetTooltip(ratioStr)
			return ratio:SetText(ratioStr)
		end
	end
	PANEL.PerformLayout = function(self)
		local margin = VMin(0.5)
		self:DockMargin(0, 0, 0, margin)
		self:DockPadding(margin, margin, margin, margin)
		local height = VMin(2.5) + margin * 2
		local ply = self.Player
		if IsValid(ply) then
			SetFont("Jailbreak::Scoreboard - Player")
			height = max(height, margin + select(2, GetTextSize(ply:Nick())) + margin)
			local nickname = self.Nickname
			if IsValid(nickname) then
				nickname:DockMargin(margin, 0, 0, 0)
			end
			local avatar = self.Avatar
			if IsValid(avatar) then
				local avatarHeight = avatar:GetTall()
				avatar:SetWide(avatarHeight)
				avatar:SetPlayer(ply, Clamp(2 ^ floor(log(ceil(avatarHeight), 2)), 16, 512))
			end
		end
		self:SetTall(height)
		return CloseDermaMenus()
	end
	PANEL.Paint = function(self, width, height)
		SetDrawColor(self.Color)
		return DrawRect(0, 0, width, height)
	end
	Register("Jailbreak::Scoreboard - Player", PANEL, "EditablePanel")
end
do
	Jailbreak.Font("Jailbreak::Scoreboard - Header", "Roboto Mono Bold", 4)
	local PANEL = { }
	PANEL.Init = function(self)
		self.TeamID = TEAM_SPECTATOR
		self:Dock(TOP)
		return InvalidateLayout(self, true)
	end
	PANEL.PerformLayout = function(self)
		local teamID = self.TeamID
		self.Color = GetTeamColor(teamID)
		local text = "#jb.team." .. teamID
		self:SetTooltip(text)
		SetFont("Jailbreak::Scoreboard - Header")
		local textWidth, textHeight = GetTextSize(text)
		local width = self:GetWide()
		self.Text = text
		local margin = VMin(0.5)
		local height = margin + textHeight + margin
		self:SetTall(height)
		if self.TeamID == TEAM_SPECTATOR then
			self.TextPosX, self.TextPosY = (width - textWidth) / 2, (height - textHeight) / 2
			self.RectX, self.RectWidth = 0, width
			return
		end
		local score = tostring(GetScore(teamID))
		local scoreWidth, scoreHeight = GetTextSize(score)
		local scoreSize = max(scoreWidth + margin, VMin(5))
		self.ScoreX, self.ScoreY = (scoreSize - scoreWidth) / 2, (height - scoreHeight) / 2
		self.ScoreSize = scoreSize
		self.Score = score
		local scoreX = scoreSize + margin
		self.RectX, self.RectWidth = scoreX, width - scoreX
		self.TextPosX, self.TextPosY = scoreX + (width - scoreX - textWidth) / 2, (height - textHeight) / 2
	end
	PANEL.Paint = function(self, width, height)
		SetTextColor(dark_grey.r, dark_grey.g, dark_grey.b)
		SetFont("Jailbreak::Scoreboard - Header")
		SetDrawColor(self.Color)
		if self.TeamID ~= TEAM_SPECTATOR then
			DrawRect(0, 0, self.ScoreSize, height)
			SetTextPos(self.ScoreX, self.ScoreY)
			DrawText(self.Score)
		end
		DrawRect(self.RectX, 0, self.RectWidth, height)
		SetTextPos(self.TextPosX, self.TextPosY)
		return DrawText(self.Text)
	end
	Register("Jailbreak::Scoreboard - Header", PANEL, "Panel")
end
do
	local GetTeamPlayers = Jailbreak.GetTeamPlayers
	local PANEL = { }
	PANEL.Paint = function(self, width, height)
		SetDrawColor(black.r, black.g, black.b, 100)
		return DrawRect(0, 0, width, height)
	end
	PANEL.Build = function(self)
		self:Clear()
		local teamID = self.TeamID
		if teamID ~= nil then
			local _list_0 = GetTeamPlayers(nil, teamID)[1]
			for _index_0 = 1, #_list_0 do
				local ply = _list_0[_index_0]
				local panel = self:Add("Jailbreak::Scoreboard - Player")
				panel.TeamID = teamID
				panel.Player = ply
			end
		end
	end
	PANEL.PerformLayout = function(self, width, height)
		DScrollPanel.PerformLayout(self, width, height)
		local parent = self:GetParent()
		if IsValid(parent) then
			return parent:InvalidateParent()
		end
	end
	Register("Jailbreak::Scoreboard - ScrollPanel", PANEL, "DScrollPanel")
end
do
	Jailbreak.Font("Jailbreak::Scoreboard - Small", "Roboto Mono Medium Italic", 2)
	local PANEL = { }
	PANEL.Init = function(self)
		local header = self:Add("DLabel")
		self.Header = header
		header:Dock(TOP)
		header:SetTextColor(white)
		header:SetContentAlignment(5)
		header:SetMouseInputEnabled(true)
		header:SetFont("Jailbreak::Scoreboard - Header")
		local prisoners = self:Add("EditablePanel")
		self.Prisoners = prisoners
		prisoners:Dock(LEFT)
		local label = prisoners:Add("Jailbreak::Scoreboard - Header")
		prisoners.Label = label
		label.TeamID = TEAM_PRISONER
		InvalidateLayout(label)
		local scrollPanel = prisoners:Add("Jailbreak::Scoreboard - ScrollPanel")
		prisoners.ScrollPanel = scrollPanel
		scrollPanel.TeamID = TEAM_PRISONER
		scrollPanel:Dock(FILL)
		local guards = self:Add("EditablePanel")
		self.Guards = guards
		guards:Dock(RIGHT)
		label = guards:Add("Jailbreak::Scoreboard - Header")
		guards.Label = label
		label.TeamID = TEAM_GUARD
		InvalidateLayout(label)
		scrollPanel = guards:Add("Jailbreak::Scoreboard - ScrollPanel")
		guards.ScrollPanel = scrollPanel
		scrollPanel.TeamID = TEAM_GUARD
		scrollPanel:Dock(FILL)
		local spectators = self:Add("EditablePanel")
		self.Spectators = spectators
		spectators:SetZPos(-1000)
		spectators:Dock(BOTTOM)
		label = spectators:Add("Jailbreak::Scoreboard - Header")
		spectators.Label = label
		label.TeamID = TEAM_SPECTATOR
		InvalidateLayout(label)
		scrollPanel = spectators:Add("Jailbreak::Scoreboard - ScrollPanel")
		spectators.ScrollPanel = scrollPanel
		scrollPanel.TeamID = TEAM_SPECTATOR
		scrollPanel:Dock(FILL)
		local playerCount = self:Add("DLabel")
		self.PlayerCount = playerCount
		playerCount:SetZPos(-5000)
		playerCount:SetTextColor(white)
		playerCount:SetContentAlignment(5)
		playerCount:SetFont("Jailbreak::Scoreboard - Small")
		return playerCount:Dock(BOTTOM)
	end
	PANEL.PerformLayout = function(self)
		local size = VMin(80)
		self:SetSize(size, size)
		self:Center()
		local padding = VMin(1)
		local margin = VMin(0.5)
		local header = self.Header
		if IsValid(header) then
			local hostName = GetHostName()
			header:SetText(hostName)
			header:SetTooltip(hostName)
			header:DockMargin(0, 0, 0, margin)
			header:SizeToContentsY()
		end
		local prisoners = self.Prisoners
		if IsValid(prisoners) then
			local label = prisoners.Label
			if IsValid(label) then
				label:DockMargin(0, 0, 0, margin)
			end
			local scrollPanel = prisoners.ScrollPanel
			if IsValid(scrollPanel) then
				local vbar = scrollPanel.VBar
				if IsValid(vbar) then
					vbar:SetWide(0)
				end
			end
			prisoners:SetWide(size / 2 - padding - margin / 2)
		end
		local guards = self.Guards
		if IsValid(guards) then
			local label = guards.Label
			if IsValid(label) then
				label:DockMargin(0, 0, 0, margin)
			end
			local scrollPanel = guards.ScrollPanel
			if IsValid(scrollPanel) then
				local vbar = scrollPanel.VBar
				if IsValid(vbar) then
					vbar:SetWide(0)
				end
			end
			guards:SetWide(size / 2 - padding - margin / 2)
		end
		local spectators = self.Spectators
		if IsValid(spectators) then
			spectators:DockMargin(0, margin, 0, margin)
			local label = spectators.Label
			if IsValid(label) then
				label:DockMargin(0, 0, 0, margin)
			end
			local scrollPanel = spectators.ScrollPanel
			if IsValid(scrollPanel) then
				local vbar = scrollPanel.VBar
				if IsValid(vbar) then
					vbar:SetWide(0)
				end
			end
			spectators:SetTall(size / 4)
		end
		local playerCount = self.PlayerCount
		if IsValid(playerCount) then
			local teams = GetTeamPlayersCount(nil, TEAM_PRISONER, TEAM_GUARD)
			playerCount:SetText(format(GetPhrase("jb.scoreboard.players-online"), player.GetCount(), teams[1], teams[2]))
			playerCount:SizeToContentsY()
		end
		return self:DockPadding(padding, padding, padding, padding)
	end
	PANEL.Show = function(self)
		InvalidateLayout(self, true)
		self:SetVisible(true)
		CloseDermaMenus()
		self:MakePopup()
		return self:Perform()
	end
	PANEL.Hide = function(self)
		CloseDermaMenus()
		if Jailbreak.Developer then
			self:Remove()
			return
		end
		self:SetVisible(false)
		return self:Cleanup()
	end
	PANEL.Perform = function(self)
		local scrollPanel = self.Guards.ScrollPanel
		if IsValid(scrollPanel) then
			scrollPanel:Build()
		end
		scrollPanel = self.Prisoners.ScrollPanel
		if IsValid(scrollPanel) then
			scrollPanel:Build()
		end
		scrollPanel = self.Spectators.ScrollPanel
		if IsValid(scrollPanel) then
			return scrollPanel:Build()
		end
	end
	PANEL.Cleanup = function(self)
		local scrollPanel = self.Guards.ScrollPanel
		if IsValid(scrollPanel) then
			scrollPanel:Clear()
		end
		scrollPanel = self.Prisoners.ScrollPanel
		if IsValid(scrollPanel) then
			scrollPanel:Clear()
		end
		scrollPanel = self.Spectators.ScrollPanel
		if IsValid(scrollPanel) then
			return scrollPanel:Clear()
		end
	end
	PANEL.Paint = function(self, width, height)
		SetDrawColor(dark_grey.r, dark_grey.g, dark_grey.b, 240)
		return DrawRect(0, 0, width, height)
	end
	Register("Jailbreak::Scoreboard", PANEL)
end
GM.ScoreboardShow = function(self)
	local scoreboard = Jailbreak.ScoreBoard
	if not IsValid(scoreboard) then
		scoreboard = Create("Jailbreak::Scoreboard")
		Jailbreak.ScoreBoard = scoreboard
	end
	scoreboard:Show()
	return false
end
GM.ScoreboardHide = function(self)
	local scoreboard = Jailbreak.ScoreBoard
	if IsValid(scoreboard) then
		return scoreboard:Hide()
	end
end
do
	Jailbreak.Font("Jailbreak::Tooltip", "Roboto Mono", 1.8)
	local tooltipFadeOut = CreateClientConVar("tooltip_fadeout", "2", true, false, "Tooltip fadeout speed multiplier.", 0, 10)
	local tooltipClear = CreateClientConVar("tooltip_clear", "1", true, false, "If enabled, game will clear alpha of tooltips after fading out.", 0, 1)
	local tooltipFadeIn = CreateClientConVar("tooltip_fadein", "3", true, false, "Tooltip fadein speed multiplier.", 0, 10)
	local tooltipDelay = GetConVar("tooltip_delay")
	local FrameTime = FrameTime
	local CurTime = CurTime
	do
		local CursorVisible = vgui.CursorVisible
		local GetCursorPos = input.GetCursorPos
		local PANEL = { }
		PANEL.Init = function(self)
			self:SetFontInternal("Jailbreak::Tooltip")
			self:SetContentAlignment(5)
			self:SetAlpha(0)
			self:SetPaintBackgroundEnabled(true)
			self:SetKeyboardInputEnabled(false)
			self:SetMouseInputEnabled(false)
			self:SetPaintedManually(true)
			InvalidateLayout(self, true)
			return hook.Add("DrawOverlay", self, self.PaintManual)
		end
		PANEL.Think = function(self)
			if not CursorVisible() then
				self:SetVisible(false)
				return
			end
			local x, y = GetCursorPos()
			self:SetPos(x, y - self:GetTall())
			if self.FadeIn then
				local alpha = self:GetAlpha()
				if alpha > 0 then
					self:SetAlpha(max(0, alpha - FrameTime() * 255 * tooltipFadeIn:GetFloat()))
				elseif self:IsVisible() then
					self:SetVisible(false)
				end
				return
			end
			local lastTextChange = self.LastTextChange
			if not lastTextChange then
				self:SetVisible(false)
				return
			end
			local timePassed = CurTime() - lastTextChange
			if timePassed <= tooltipDelay:GetFloat() then
				if tooltipClear:GetBool() then
					self:SetAlpha(0)
				end
				return
			end
			local alpha = self:GetAlpha()
			if alpha < 255 then
				return self:SetAlpha(min(alpha + FrameTime() * 255 * tooltipFadeOut:GetFloat(), 255))
			end
		end
		PANEL.PerformLayout = function(self)
			self:SetBGColor(dark_grey.r, dark_grey.g, dark_grey.b, 240)
			local textWidth, textHeight = self:GetTextSize()
			local margin = VMin(0.25)
			return self:SetSize(margin + textWidth + margin, margin + textHeight + margin)
		end
		PANEL.SetText = function(self, str)
			PANEL_META.SetText(self, str)
			self.LastTextChange = CurTime()
			self:SetVisible(true)
			self.FadeIn = false
		end
		Register("Jailbreak::Tooltip", PANEL, "Label")
	end
	local removeTooltip
	removeTooltip = function(self)
		local tooltip = Jailbreak.Tooltip
		if IsValid(tooltip) then
			tooltip.FadeIn = true
		end
		return true
	end
	RemoveTooltip = removeTooltip
	EndTooltip = removeTooltip
	local findTooltip
	findTooltip = function(self)
		while IsValid(self) do
			if self:IsVisible() then
				local text = self.strTooltipText
				if text ~= nil then
					return Translate(text)
				end
			end
			self = GetParent(self)
		end
	end
	FindTooltip = findTooltip
	ChangeTooltip = function(self)
		removeTooltip()
		local text = findTooltip(self)
		if not text then
			return
		end
		local tooltip = Jailbreak.Tooltip
		if Jailbreak.Developer and IsValid(tooltip) then
			tooltip:Remove()
		end
		if not IsValid(tooltip) then
			tooltip = Create("Jailbreak::Tooltip")
			Jailbreak.Tooltip = tooltip
		end
		return tooltip:SetText(text)
	end
end
