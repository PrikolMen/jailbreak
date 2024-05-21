do
	local AddCSLuaFile = AddCSLuaFile
	AddCSLuaFile("shared.lua")
	local _list_0 = file.Find("jailbreak/gamemode/shared/*.lua", "lsv")
	for _index_0 = 1, #_list_0 do
		local fileName = _list_0[_index_0]
		AddCSLuaFile("shared/" .. fileName)
	end
	local _list_1 = file.Find("jailbreak/gamemode/client/*.lua", "lsv")
	for _index_0 = 1, #_list_1 do
		local fileName = _list_1[_index_0]
		AddCSLuaFile("client/" .. fileName)
	end
end
include("shared.lua")
local Jailbreak = Jailbreak
Jailbreak.ObserveTargets = Jailbreak.ObserveTargets or { }
Jailbreak.DefaultTeamColors = {
	[TEAM_PRISONER] = Vector(0.62, 0.35, 0.07),
	[TEAM_GUARD] = Vector(0, 0, 0)
}
do
	local FCVAR_SERVER = bit.bor(FCVAR_ARCHIVE, FCVAR_NOTIFY)
	local CreateConVar = CreateConVar
	Jailbreak.PlayerWalkSpeed = CreateConVar("jb_player_walk_speed", "220", FCVAR_SERVER, "The speed of the player while walking.", 0, 3000)
	Jailbreak.PlayerRunSpeed = CreateConVar("jb_player_run_speed", "280", FCVAR_SERVER, "The speed of the player while running.", 0, 3000)
	Jailbreak.PlayerJumpPower = CreateConVar("jb_player_jump_power", "256", FCVAR_SERVER, "The jump power of the player.", 0, 3000)
	Jailbreak.AllowCustomPlayerColors = CreateConVar("jb_allow_custom_player_colors", "1", FCVAR_SERVER, "Allow custom player colors.", 0, 1)
	Jailbreak.AllowCustomWeaponColors = CreateConVar("jb_allow_custom_weapon_colors", "1", FCVAR_SERVER, "Allow custom weapon colors.", 0, 1)
	Jailbreak.AllowSprayEveryone = CreateConVar("jb_allow_spray_everyone", "0", FCVAR_SERVER, "Allow use spray to everyone.", 0, 1)
	Jailbreak.GuardsArmor = CreateConVar("jb_guards_armor", "0", FCVAR_SERVER, "Guards armor amount on spawn.", 0, 1000)
	Jailbreak.PermanentGuards = CreateConVar("jb_permanent_guards", "1", FCVAR_SERVER, "If enabled, disables guard rotation.", 0, 1)
	Jailbreak.GuardsDeathSound = CreateConVar("jb_guards_death_sound", "0", FCVAR_SERVER, "If enabled, an alarm will sound when the guard dies.", 0, 1)
	Jailbreak.WardenCoins = CreateConVar("jb_warden_coins", "100", FCVAR_SERVER, "Warden coins amount on spawn.", 0, 16384)
	Jailbreak.EmotionDistance = CreateConVar("jb_chat_emotion_distance", "300", FCVAR_SERVER, "Distance of emotion messages.", 32, 65536)
	Jailbreak.OutOfCharacter = CreateConVar("jb_chat_ooc", "1", FCVAR_SERVER, "Allows non-game global chat to be used by everyone.", 0, 1)
	Jailbreak.AllowTeamChat = CreateConVar("jb_chat_allow_team_chat", "0", FCVAR_SERVER, "Allows team chat.", 0, 1)
	Jailbreak.VoiceChatUDP = CreateConVar("jb_voice_chat_udp", "1", FCVAR_SERVER, "Use faster udp voice chat packets instead of tcp.", 0, 1)
	Jailbreak.VoiceChatSpeed = CreateConVar("jb_voice_chat_speed", "4", FCVAR_SERVER, "Speed of voice chat packets sending.", 0, 10)
	Jailbreak.PrepareTime = CreateConVar("jb_prepare_time", "10", FCVAR_SERVER, "The time before the start of the round that is given for preparation.", 5, 2 * 60 * 60)
	Jailbreak.RoundTime = CreateConVar("jb_round_time", "0", FCVAR_SERVER, "Round time in seconds.", 0, 12 * 60 * 60)
	Jailbreak.ShockCollarVictimDamage = CreateConVar("jb_shock_collar_victim_damage", "0.25", FCVAR_SERVER, "Damage to the victim from the electric collar.", 0, 1000)
	Jailbreak.ShockCollarAttackerDamage = CreateConVar("jb_shock_collar_attacker_damage", "0.5", FCVAR_SERVER, "Damage to the attacker from the electric collar.", 0, 1000)
	Jailbreak.RagdollHealth = CreateConVar("jb_ragdoll_health", "1000", FCVAR_SERVER, "The value is responsible for the health of the player ragdoll.", 50, 10000)
	Jailbreak.RagdollRemove = CreateConVar("jb_ragdoll_remove", "0", FCVAR_SERVER, "If enabled, player ragdoll will be removed on player spawn.", 0, 1)
	Jailbreak.AllowRagdollSpectate = CreateConVar("jb_allow_ragdoll_spectate", "0", FCVAR_SERVER, "Enables ragdoll spectate.", 0, 1)
	Jailbreak.DoorsHealth = CreateConVar("jb_doors_health", "1000", FCVAR_SERVER, "The value is responsible for the health of the door.", 50, 10000)
	Jailbreak.DropActiveWeaponOnDeath = CreateConVar("jb_drop_active_weapon_on_death", "1", FCVAR_SERVER, "If enabled, the active weapon will be dropped on player death.", 0, 1)
	Jailbreak.AllowWeaponsInVehicle = CreateConVar("jb_allow_weapons_in_vehicle", "0", FCVAR_SERVER, "Allows players to use weapons in vehicles.", 0, 1)
	Jailbreak.FreezeWeaponsOnSpawn = CreateConVar("jb_freeze_weapons_on_spawn", "1", FCVAR_SERVER, "Freezes weapon clusters on spawn.", 0, 1)
	Jailbreak.DeathAnimations = CreateConVar("jb_death_animations", "0", FCVAR_SERVER, "Enables silly player death animations.", 0, 1)
	Jailbreak.TF2Freezecam = CreateConVar("jb_tf2_freezecam", "1", FCVAR_SERVER, "Enables TF2 style freezecam on death.", 0, 1)
end
include("server/language.lua")
include("server/utils.lua")
include("server/player.lua")
include("server/communication.lua")
include("server/events.lua")
include("server/damage.lua")
include("server/rounds.lua")
include("server/game.lua")
do
	local RunConsoleCommand = RunConsoleCommand
	local FindByClass = ents.FindByClass
	local Run = hook.Run
	GM.InitPostEntity = function(self)
		RunConsoleCommand("sv_defaultdeployspeed", "1")
		RunConsoleCommand("mp_show_voice_icons", "0")
		RunConsoleCommand("sv_gravity", "800")
		if #FindByClass("info_player_teamspawn") ~= 0 then
			Jailbreak.m_bTF2Medieval = #FindByClass("tf_logic_medieval") ~= 0
			xpcall(SoundHandler, ErrorNoHaltWithStack, "tf")
			resource.AddWorkshop("105181283")
			Jailbreak.GameName = "tf"
		elseif (#FindByClass("info_player_counterterrorist") + #FindByClass("info_player_counterterrorist")) ~= 0 then
			xpcall(SoundHandler, ErrorNoHaltWithStack, "cstrike")
			Jailbreak.GameName = "cstrike"
		end
		timer.Simple(0, Jailbreak.ReloadLocalization)
		local mapName = game.GetMap()
		Jailbreak.MapName = mapName
		Run("MapInitialized", mapName)
		return
	end
	GM.PostCleanupMap = function(self)
		Run("MapInitialized", Jailbreak.MapName)
		return
	end
end
include("server/commands.lua")
return include("server/extra.lua")
