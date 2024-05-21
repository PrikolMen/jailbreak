if engine.ActiveGamemode() ~= "jailbreak" then
	return
end
do
	local cmd = ulx.command("Jailbreak", "ulx setcoins", function(ply, value)
		ulx.fancyLogAdmin(ply, "#A setted the warden coins amount to #s.", value)
		return Jailbreak.SetWardenCoins(math.floor(tonumber(value) or 0))
	end, "!setcoins")
	cmd:addParam({
		type = ULib.cmds.NumArg,
		hint = "number"
	})
	cmd:defaultAccess(ULib.ACCESS_ADMIN)
	cmd:help("Sets warden coins amount.")
end
do
	local cmd = ulx.command("Jailbreak", "ulx givecoins", function(ply, value)
		ulx.fancyLogAdmin(ply, "#A gave #s warden coins.", value)
		return Jailbreak.GiveWardenCoins(math.floor(tonumber(value) or 0))
	end, "!givecoins")
	cmd:addParam({
		type = ULib.cmds.NumArg,
		hint = "number"
	})
	cmd:defaultAccess(ULib.ACCESS_ADMIN)
	cmd:help("Gives warden coins.")
end
do
	local cmd = ulx.command("Jailbreak", "ulx takecoins", function(ply, value)
		ulx.fancyLogAdmin(ply, "#A took #s warden coins.", value)
		return Jailbreak.TakeWardenCoins(math.floor(tonumber(value) or 0))
	end, "!takecoins")
	cmd:addParam({
		type = ULib.cmds.NumArg,
		hint = "number"
	})
	cmd:defaultAccess(ULib.ACCESS_ADMIN)
	cmd:help("Takes warden coins.")
end
do
	local cmd = ulx.command("Jailbreak", "ulx forceteam", function(ply, targets, teamID)
		if 1 == teamID then
			teamID = TEAM_GUARD
		elseif 2 == teamID then
			teamID = TEAM_GUARD
		elseif 3 == teamID then
			teamID = TEAM_SPECTATOR
		end
		for _index_0 = 1, #targets do
			local ply = targets[_index_0]
			if ply:Alive() then
				ply:Kill()
			end
			ply:SetTeam(teamID)
		end
	end, "!forceteam")
	cmd:addParam({
		type = ULib.cmds.PlayersArg
	})
	cmd:addParam({
		type = ULib.cmds.NumArg
	})
	cmd:defaultAccess(ULib.ACCESS_ADMIN)
	cmd:help("Force team for selected players.")
end
do
	local cmd = ulx.command("Jailbreak", "ulx respawn", function(ply, targets)
		for _index_0 = 1, #targets do
			local ply = targets[_index_0]
			ply:Spawn()
		end
	end, "!respawn")
	cmd:addParam({
		type = ULib.cmds.PlayersArg
	})
	cmd:defaultAccess(ULib.ACCESS_ADMIN)
	return cmd:help("Respawn selected players.")
end
