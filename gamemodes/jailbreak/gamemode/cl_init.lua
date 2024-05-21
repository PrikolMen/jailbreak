include("shared.lua")
local Jailbreak = Jailbreak
do
	local FCVAR_NETWORKED = bit.bor(FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD)
	local FCVAR_CLIENT = bit.bor(FCVAR_ARCHIVE, FCVAR_DONTRECORD)
	local CreateConVar = CreateConVar
	Jailbreak.PlayerWeaponColor = CreateConVar("cl_weaponcolor", "0.30 1.80 2.10", FCVAR_NETWORKED, "The value is a Vector - so between 0-1 - not between 0-255")
	Jailbreak.PlayerColor = CreateConVar("cl_playercolor", "0.3 0.3 0.3", FCVAR_NETWORKED, "The value is a Vector - so between 0-1 - not between 0-255")
	Jailbreak.PlayerBodyGroups = CreateConVar("jb_playerbodygroups", "0", FCVAR_NETWORKED, "The bodygroups to use, if the model has any")
	Jailbreak.PlayerSkin = CreateConVar("jb_playerskin", "0", FCVAR_NETWORKED, "The skin to use, if the model has any")
	Jailbreak.PlayerModel = CreateConVar("jb_playermodel", "none", bit.bor(FCVAR_USERINFO, FCVAR_DONTRECORD), "Current desired player model.")
	Jailbreak.PickupNotifyLifetime = CreateConVar("jb_pickup_notify_lifetime", "5", FCVAR_CLIENT, "Pickup notification lifetime in seconds", 0, 60)
	Jailbreak.HandsTransparency = CreateConVar("jb_hands_transparency", "0", FCVAR_CLIENT, "The firstperson hands transparency value 0-1", 0, 1)
end
include("client/utils.lua")
include("client/player.lua")
include("client/game.lua")
include("client/chat.lua")
include("client/hud.lua")
include("client/ui.lua")
include("client/voice-chat.lua")
include("client/desktop-windows.lua")
include("client/markers.lua")
return include("client/extra.lua")
