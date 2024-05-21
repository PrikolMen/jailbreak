if engine.ActiveGamemode() ~= "jailbreak" then
	return
end
local command = sam.command
local Exists = file.Exists
local find = string.find
command.set_category("Jailbreak")
command.new("setcoins"):Help("Sets warden coins amount."):SetPermission("setcoins", "admin"):SetCategory("Jailbreak"):AddArg("number", {
	optional = true,
	hint = "amount",
	default = 0,
	max = 10000,
	min = 0
}):OnExecute(function(_, amount)
	Jailbreak.SetWardenCoins(math.floor(amount))
	return
end):End()
command.new("givecoins"):Help("Gives warden coins."):SetPermission("givecoins", "admin"):SetCategory("Jailbreak"):AddArg("number", {
	optional = true,
	hint = "amount",
	default = 0,
	max = 1000,
	min = 0
}):OnExecute(function(_, amount)
	Jailbreak.GiveWardenCoins(math.floor(amount))
	return
end):End()
command.new("takecoins"):Help("Takes warden coins."):SetPermission("takecoins", "admin"):SetCategory("Jailbreak"):AddArg("number", {
	optional = true,
	hint = "amount",
	default = 0,
	max = 1000,
	min = 0
}):OnExecute(function(_, amount)
	Jailbreak.TakeWardenCoins(math.floor(amount))
	return
end):End()
command.new("forceteam"):Help("Force team for selected players."):SetPermission("forceteam", "admin"):SetCategory("Jailbreak"):AddArg("player", { }):AddArg("number", {
	optional = true,
	hint = "TeamID",
	default = 1,
	max = 3,
	min = 1
}):OnExecute(function(_, targets, teamID)
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
end):End()
return command.new("forcewarden"):Help("Makes selected players warden."):SetPermission("forcewarden", "admin"):SetCategory("Jailbreak"):AddArg("player", { }):AddArg("number", {
	optional = true,
	hint = "give/take",
	default = 1,
	min = 0,
	max = 1
}):AddArg("number", {
	optional = true,
	hint = "silent",
	default = 0,
	min = 0,
	max = 1
}):OnExecute(function(_, targets, isWarden, silent)
	isWarden = isWarden == 1
	silent = silent == 1
	for _index_0 = 1, #targets do
		local ply = targets[_index_0]
		if ply:Alive() and Jailbreak.Teams[ply:Team()] then
			ply:SetWarden(isWarden, silent)
		end
	end
end):End()
