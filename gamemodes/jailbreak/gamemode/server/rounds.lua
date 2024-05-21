local Jailbreak = Jailbreak
local GM = GM
local GetTeamPlayersCount, Teams, PrepareTime, RoundTime, PlaySound, SendChatText, GetRoundState = Jailbreak.GetTeamPlayersCount, Jailbreak.Teams, Jailbreak.PrepareTime, Jailbreak.RoundTime, Jailbreak.PlaySound, Jailbreak.SendChatText, Jailbreak.GetRoundState
local Iterator = player.Iterator
local CurTime = CurTime
local Run = hook.Run
local ROUND_WAITING_PLAYERS = ROUND_WAITING_PLAYERS
local ROUND_RUNNING = ROUND_RUNNING
local ROUND_FINISHED = ROUND_FINISHED
local TEAM_PRISONER = TEAM_PRISONER
local TEAM_GUARD = TEAM_GUARD
local CHAT_SERVERMESSAGE = CHAT_SERVERMESSAGE
local setRoundState, setWinningTeam, setRoundTime = nil, nil, nil
do
	local SetGlobal2Int = SetGlobal2Int
	setRoundState = function(state, silent)
		local oldState = GetRoundState()
		if oldState == state then
			return
		end
		SetGlobal2Int("round-state", state)
		if not silent then
			return Run("RoundStateChanged", oldState, state)
		end
	end
	Jailbreak.SetRoundState = setRoundState
	setWinningTeam = function(teamID)
		if Teams[teamID] then
			team.AddScore(teamID, 1)
		end
		return SetGlobal2Int("winning-team", teamID)
	end
	Jailbreak.SetWinningTeam = setWinningTeam
	setRoundTime = function(int)
		return SetGlobal2Int("next-round-state", CurTime() + int)
	end
	Jailbreak.SetRoundTime = setRoundTime
end
do
	local GetPlayersCount = Jailbreak.GetPlayersCount
	local Create = timer.Create
	local lastPrisonersCount = 0
	local playerChangedTeam
	playerChangedTeam = function(self)
		local teamID = self:Team()
		return Create("Jailbreak::TeamPlayerCountChanged", 0.25, 1, function()
			local _exp_0 = GetRoundState()
			if ROUND_PREPARING == _exp_0 then
				if Teams[teamID] and GetPlayersCount(teamID) == 0 then
					return setRoundState(ROUND_WAITING_PLAYERS)
				end
			elseif ROUND_RUNNING == _exp_0 then
				local teams = GetTeamPlayersCount(true, TEAM_GUARD, TEAM_PRISONER)
				if teams[1] == 0 or teams[2] == 0 then
					return setRoundState(ROUND_FINISHED)
				else
					if teamID == TEAM_PRISONER and teams[2] == 1 and teams[2] < lastPrisonersCount then
						PlaySound("ambient/levels/caves/ol04_gearengage.wav")
					end
					lastPrisonersCount = teams[2]
				end
			end
		end)
	end
	Jailbreak.PlayerChangedTeam = playerChangedTeam
	hook.Add("TeamPlayerDeath", "Jailbreak::TeamPlayerCountChanged", playerChangedTeam)
	hook.Add("PlayerChangedTeam", "Jailbreak::TeamPlayerCountChanged", playerChangedTeam)
	hook.Add("TeamPlayerDisconnected", "Jailbreak::TeamPlayerCountChanged", playerChangedTeam)
end
do
	local SafeCleanUpMap, Colors, RunEvents, SetShockCollars, ClearObserveTargets, TeamIsJoinable, PermanentGuards, SetWardenCoins, WardenCoins = Jailbreak.SafeCleanUpMap, Jailbreak.Colors, Jailbreak.RunEvents, Jailbreak.SetShockCollars, Jailbreak.ClearObserveTargets, Jailbreak.TeamIsJoinable, Jailbreak.PermanentGuards, Jailbreak.SetWardenCoins, Jailbreak.WardenCoins
	GM.RoundStateChanged = function(self, old, new)
		RunEvents(new)
		if ROUND_WAITING_PLAYERS == new then
			SetShockCollars(false)
			ClearObserveTargets()
			for _, ply in Iterator() do
				if ply:Alive() then
					ply:KillSilent()
				end
				if ply:IsBot() or (ply:IsGuard() and not PermanentGuards:GetBool()) then
					ply:SetTeam(TEAM_PRISONER)
				end
			end
			SendChatText(false, false, CHAT_SERVERMESSAGE, "#jb.round.changed." .. new)
			SafeCleanUpMap()
		elseif ROUND_PREPARING == new then
			for _, ply in Iterator() do
				if ply:IsBot() then
					ply:SetTeam(TEAM_PRISONER)
				end
				if Teams[ply:Team()] then
					ply:Spawn()
				end
			end
			SendChatText(false, false, CHAT_SERVERMESSAGE, "#jb.round.changed." .. new, Colors.horizon)
			SetShockCollars(false)
			SafeCleanUpMap()
		elseif ROUND_RUNNING == new then
			PlaySound("ambient/alarms/warningbell1.wav")
			SetWardenCoins(WardenCoins:GetInt())
			for _, ply in Iterator() do
				if ply:IsBot() then
					local teamID = ply:Team()
					for index = 1, 2 do
						if index ~= teamID and TeamIsJoinable(index) then
							ply:SetTeam(index)
							ply:KillSilent()
							break
						end
					end
				end
			end
			local teams = GetTeamPlayersCount(true, TEAM_GUARD, TEAM_PRISONER)
			if teams[1] == 0 or teams[2] == 0 then
				setRoundState(ROUND_WAITING_PLAYERS)
				return
			end
			local guards = { }
			for _, ply in Iterator() do
				local teamID = ply:Team()
				if Teams[teamID] then
					if not ply:Alive() then
						ply:Spawn()
					end
					if teamID == TEAM_GUARD then
						guards[#guards + 1] = ply
					elseif teamID == TEAM_PRISONER then
						ply:GiveShockCollar()
					end
				end
			end
			if #guards == 1 then
				guards[1]:SetWarden(true)
			end
			SetShockCollars(true)
			local roundTime = RoundTime:GetInt()
			if roundTime > 0 then
				setRoundTime(roundTime)
			end
			SendChatText(false, false, CHAT_SERVERMESSAGE, "#jb.round.changed." .. new, Colors.asparagus)
			Run("GameStarted")
		elseif ROUND_FINISHED == new then
			local teams = GetTeamPlayersCount(true, TEAM_GUARD, TEAM_PRISONER)
			if teams[1] > teams[2] then
				SendChatText(false, false, CHAT_SERVERMESSAGE, "#jb.round.changed." .. new .. "." .. TEAM_GUARD, Jailbreak.GetTeamColor(TEAM_GUARD))
				setWinningTeam(TEAM_GUARD)
			elseif teams[1] < teams[2] then
				SendChatText(false, false, CHAT_SERVERMESSAGE, "#jb.round.changed." .. new .. "." .. TEAM_PRISONER, Jailbreak.GetTeamColor(TEAM_PRISONER))
				setWinningTeam(TEAM_PRISONER)
			else
				SendChatText(false, false, CHAT_SERVERMESSAGE, "#jb.round.changed." .. new .. ".0", Colors.dark_white)
				setWinningTeam(0)
			end
			setRoundTime(PrepareTime:GetInt())
			PlaySound("ambient/alarms/warningbell1.wav")
			Run("GameFinished")
		end
		return
	end
end
do
	local black = Jailbreak.Colors.black
	GM.TeamPlayerDeath = function(self, ply, teamID)
		if not ply:IsBot() then
			ply:ShockScreenEffect(0.25, black, 1, false)
		end
		ply:RemoveFromObserveTargets()
		ply:TakeSecurityRadio()
		ply:TakeSecurityKeys()
		ply:TakeShockCollar()
		ply:TakeFlashlight()
		return
	end
end
GM.TeamPlayerDisconnected = function(self, ply, teamID)
	if not ply:Alive() then
		return
	end
	ply:RemoveFromObserveTargets()
	if Jailbreak.IsRoundFinished() then
		return ply:CreateRagdoll()
	end
end
do
	local IsWaitingPlayers, PlayerSpawnTime = Jailbreak.IsWaitingPlayers, Jailbreak.PlayerSpawnTime
	local Simple = timer.Simple
	GM.PostPlayerSpawn = function(self, ply)
		ply:SetNW2Int("spawn-time", CurTime() + 0.25)
		ply:SetNW2Bool("is-spawning", true)
		ply:AddToObserveTargets()
		Simple(PlayerSpawnTime:GetFloat(), function()
			if ply:IsValid() then
				return ply:SetNW2Bool("is-spawning", false)
			end
		end)
		if IsWaitingPlayers() then
			local teams = GetTeamPlayersCount(true, TEAM_GUARD, TEAM_PRISONER)
			if teams[1] > 0 and teams[2] > 0 then
				setRoundState(ROUND_PREPARING)
				return setRoundTime(PrepareTime:GetInt())
			end
		end
	end
end
do
	local GetRoundTime = Jailbreak.GetRoundTime
	local AddScore = team.AddScore
	GM.Think = function(self)
		if GetRoundTime() > CurTime() then
			return
		end
		local _exp_0 = GetRoundState()
		if ROUND_PREPARING == _exp_0 then
			return setRoundState(ROUND_RUNNING)
		elseif ROUND_RUNNING == _exp_0 then
			if RoundTime:GetInt() == 0 then
				return
			end
			AddScore(TEAM_GUARD, 1)
			setWinningTeam(TEAM_GUARD)
			setRoundState(ROUND_FINISHED, true)
			return setRoundTime(PrepareTime:GetInt())
		elseif ROUND_FINISHED == _exp_0 then
			return setRoundState(ROUND_WAITING_PLAYERS)
		end
	end
end
GM.ShockCollarsToggled = function(self, bool)
	for _, ply in Iterator() do
		if ply:HasShockCollar() then
			ply:SetShockCollar(bool, false)
		end
	end
end
GM.ShockCollarToggled = function(self, ply, bool)
	if not ply:IsBot() then
		SendChatText(ply, false, CHAT_SERVERMESSAGE, bool and "#jb.notify.shock-collar.on" or "#jb.notify.shock-collar.off")
	end
	return ply:DoElectricSparks()
end
