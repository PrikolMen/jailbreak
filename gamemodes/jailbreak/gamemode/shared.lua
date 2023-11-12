GM.Name = "Jailbreak"
GM.Author = ""
GM.TeamBased = true

GM.VoiceChatDistance = 1024 ^ 2

TEAM_GUARD = 1
TEAM_PRISONER = 2

GM.PlayableTeams = {
    [ TEAM_PRISONER ] = true,
    [ TEAM_GUARD ] = true
}

function GM:CreateTeams()
    team.SetUp( TEAM_PRISONER, "#jb.prisoners", Color( 255, 89, 50 ), true )
    team.SetSpawnPoint( TEAM_PRISONER, { "info_player_terrorist", "info_player_rebel" } )

    team.SetUp( TEAM_GUARD, "#jb.guards", Color( 50, 185, 255 ), true )
    team.SetSpawnPoint( TEAM_GUARD, { "info_player_counterterrorist", "info_player_combine" } )

    team.SetUp( TEAM_SPECTATOR, "#jb.spectators", Color( 50, 50, 50 ), true )
end

local util_PrecacheModel = util.PrecacheModel

local guardModels = {
    "models/player/gasmask.mdl",
    "models/player/riot.mdl",
    "models/player/swat.mdl",
    "models/player/urban.mdl",
    -- "models/player/odessa.mdl"
}

for _, modelPath in ipairs( guardModels ) do
    util_PrecacheModel( modelPath )
end

local prisonerModels = { {}, {} }

-- Female Models
for i = 1, 6 do
    local modelPath = "models/player/Group01/female_0" .. i .. ".mdl"
    prisonerModels[ 1 ][ i ] = modelPath
    util_PrecacheModel( modelPath )
end

-- Male Models
for i = 1, 9 do
    local modelPath = "models/player/Group01/male_0" .. i .. ".mdl"
    prisonerModels[ 2 ][ i ] = modelPath
    util_PrecacheModel( modelPath )
end

GM.PlayerModels = {
    [ TEAM_PRISONER ] = prisonerModels,
    [ TEAM_GUARD ] = guardModels
}

local TEAM_UNASSIGNED = TEAM_UNASSIGNED

function GM:FinishMove( ply, mv )
    if drive.FinishMove( ply, mv ) then
        return true
    end

    local teamID = ply:Team()
    if teamID == TEAM_UNASSIGNED then
        return true
    end

    if self.PlayableTeams[ teamID ] then
        if not ply:Alive() then
            return true
        end

        if ply:IsPlayingTaunt() then
            mv:SetForwardSpeed( 0 )
            mv:SetSideSpeed( 0 )
        end
    end
end

function GM:IsRoundPreparing()
    return GetGlobalInt( "preparing", 0 ) > CurTime()
end

function GM:GetRoundState()
    return GetGlobal2String( "round-state", "waiting" )
end

function GM:IsRoundRunning()
    return self:GetRoundState() == "running"
end

function GM:IsRoundEnded()
    return self:GetRoundState() == "ended"
end

function GM:IsWaitingPlayers()
    return self:GetRoundState() == "waiting"
end

do

    local singleHandHoldTypes = {
        ["grenade"] = true,
        ["normal"] = true,
        ["melee"] = true,
        ["knife"] = true,
        ["fist"] = true,
        ["slam"] = true
    }

    hook.Add( "CalcMainActivity", "Jailbreak::Additional Animations", function( ply, velocity )
        if not ply:IsOnGround() then return end

        if velocity:Length() >= ply:GetRunSpeed() then
            local weapon = ply:GetActiveWeapon()
            if IsValid( weapon ) and not singleHandHoldTypes[ weapon:GetHoldType() ] then return end
            return ACT_HL2MP_RUN_FAST, -1
        elseif ply:Crouching() and velocity:Length2DSqr() < 1 then
            local weapon = ply:GetActiveWeapon()
            if IsValid( weapon ) and weapon:GetHoldType() ~= "normal" then return end
            return ACT_MP_JUMP, ply:LookupSequence( "pose_ducking_01" )
        end
    end )

end

local classes = {
    ["weapon_knife"] = { "arc9_go_knife_bayonet", "arc9_fas_dv2", "arccw_melee_knife", "weapon_crowbar" },
    ["weapon_ak47"] = { "swb_css_ak47", "arc9_go_ak47", "arc9_fas_ak47", "arccw_ur_ak", "arccw_ak47", "m9k_ak74m", "weapon_ar2" },
    ["weapon_aug"] = { "swb_css_aug", "arc9_go_aug", "arc9_fas_m16a2", "arccw_ud_mini14", "arccw_augpara", "9k_auga3", "weapon_ar2" },
    ["weapon_awp"] = { "swb_css_awp", "arc9_go_awp", "arc9_fas_m24", "arccw_ur_aw", "arccw_awm", "m9k_m98b", "weapon_crossbow" },
    ["weapon_deagle"] = { "swb_css_deagle", "arc9_go_deagle", "arc9_fas_deagle", "arccw_ur_deagle", "arccw_deagle357", "m9k_deagle", "weapon_357" },
    ["weapon_elite"] = { "swb_css_fiveseven", "arc9_go_elite", "arc9_fas_m93r", "arccw_ud_glock", "arccw_makarov", "m9k_hk45", "weapon_pistol" },
    ["weapon_famas"] = { "swb_css_famas", "arc9_go_famas", "arc9_fas_famas", "arccw_ur_db", "arccw_famas", "m9k_famas", "weapon_ar2" },
    ["weapon_fiveseven"] = { "swb_css_fiveseven", "arc9_go_fiveseven", "arc9_fas_grach", "arccw_ur_m1911", "arccw_fiveseven", "m9k_m92beretta", "weapon_pistol" },
    ["weapon_g3sg1"] = { "swb_css_g3sg1", "arc9_go_g1sg3", "arc9_fas_svd", "arccw_ur_g3", "arccw_g3a3", "m9k_dragunov", "weapon_crossbow" },
    ["weapon_galil"] = { "swb_css_galil", "arc9_go_galilar", "arc9_fas_ak74", "arccw_ur_spas12", "arccw_galil556", "m9k_winchester73", "weapon_ar2" },
    ["weapon_glock"] = { "swb_css_glock", "arc9_go_glock", "arc9_fas_g20", "arccw_ud_glock", "arccw_g18", "m9k_glock", "weapon_pistol" },
    ["weapon_m249"] = { "swb_css_m249", "arc9_go_negev", "arc9_fas_rpk", "arccw_ud_m16", "arccw_minimi", "m9k_pkm", "weapon_ar2" },
    ["weapon_m3"] = { "swb_css_m3super", "arc9_go_nova", "arc9_fas_m3super90", "arccw_ud_870", "arccw_shorty", "m9k_ithacam37", "weapon_shotgun" },
    ["weapon_m4a1"] = { "swb_css_m4a1", "arc9_go_m4a1", "arc9_fas_m4a1", "arccw_ud_m16", "arccw_m4a1", "m9k_m4a1", "weapon_ar2" },
    ["weapon_mac10"] = { "swb_css_mac10", "arc9_go_mac10", "arc9_fas_mac11", "arccw_ud_uzi", "arccw_mac11", "m9k_uzi", "weapon_smg1" },
    ["weapon_mp5navy"] = { "swb_css_mp5", "arc9_go_mp5sd", "arc9_fas_mp5", "arccw_ur_mp5", "arccw_mp5", "m9k_mp5", "weapon_smg1" },
    ["weapon_p228"] = { "swb_css_p228", "arc9_go_p250", "arc9_fas_p226", "arccw_ur_m1911", "arccw_p228", "m9k_hk45", "weapon_pistol" },
    ["weapon_p90"] = { "swb_css_p90", "arc9_go_p90", "arc9_fas_bizon", "arccw_ur_mp5", "arccw_p90", "m9k_bizonp19", "weapon_smg1" },
    ["weapon_scout"] = { "swb_css_scout", "arc9_go_ssg08", "arc9_fas_sks", "arccw_ud_mini14", "arccw_scout", "m9k_m24", "weapon_crossbow" },
    ["weapon_sg550"] = { "swb_css_sg550", "arc9_go_scar20", "arc9_fas_sr25", "arccw_ur_g3", "arccw_sg550", "m9k_sl8", "weapon_crossbow" },
    ["weapon_sg552"] = { "swb_css_sg552", "arc9_go_sg556", "arc9_fas_sg550", "arccw_ud_mini14", "arccw_sg552", "m9k_m16a4_acog", "weapon_ar2" },
    ["weapon_tmp"] = { "swb_css_tmp", "arc9_go_mp9", "arc9_fas_uzi", "arccw_ud_uzi", "arccw_tmp", "m9k_mp9", "weapon_smg1" },
    ["weapon_ump45"] = { "swb_css_ump", "arc9_go_ump", "arc9_fas_colt", "arccw_ur_mp5", "arccw_ump45", "m9k_ump45", "weapon_smg1" },
    ["weapon_usp"] = { "swb_css_usp", "arc9_go_usp", "arc9_fas_m1911", "arccw_ur_329", "arccw_usp", "m9k_usp", "weapon_pistol" },
    ["weapon_xm1014"] = { "swb_css_usp", "arc9_go_xm1014", "arc9_fas_saiga", "arccw_ud_m1014", "arccw_m1014", "m9k_spas12", "weapon_shotgun" },
    ["weapon_hegrenade"] = { "arc9_go_nade_frag", "arc9_fas_m67", "arccw_ud_m79", "arccw_nade_frag", "weapon_frag" },
    ["weapon_smokegrenade"] = { "arc9_go_nade_smoke", "arc9_fas_m18", "arccw_nade_smoke", "weapon_crowbar" },
    ["weapon_flashbang"] = { "arc9_go_nade_flashbang", "arc9_fas_m84", "arccw_nade_flash", "weapon_crowbar" }
}

local WeaponHandler = WeaponHandler

function GM:PreGamemodeLoaded()
    for className, alternatives in pairs( classes ) do
        WeaponHandler( className, alternatives )
    end
end