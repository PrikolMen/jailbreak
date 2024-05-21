local avaliableWeapons = Jailbreak.AvaliableWeapons
if not istable(avaliableWeapons) then
	avaliableWeapons = { }
	Jailbreak.AvaliableWeapons = avaliableWeapons
end
local WeaponHandler = WeaponHandler
if not WeaponHandler then
	return
end
local Vector, Angle = Vector, Angle
local altrenativeWeapons = {
	Classes = {
		weapon_knife = {
			"arc9_go_knife_bayonet",
			"arc9_fas_dv2",
			"arccw_melee_knife",
			"weapon_crowbar"
		},
		weapon_ak47 = {
			"swb_css_ak47",
			"arc9_go_ak47",
			"arc9_fas_ak47",
			"arccw_ur_ak",
			"arccw_ak47",
			"m9k_ak74",
			"weapon_ar2"
		},
		weapon_aug = {
			"swb_css_aug",
			"arc9_go_aug",
			"arc9_fas_m16a2",
			"arccw_ud_mini14",
			"arccw_augpara",
			"9k_auga3",
			"weapon_ar2"
		},
		weapon_awp = {
			"swb_css_awp",
			"arc9_go_awp",
			"arc9_fas_m24",
			"arccw_ur_aw",
			"arccw_awm",
			"m9k_m98b",
			"weapon_crossbow"
		},
		weapon_deagle = {
			"swb_css_deagle",
			"arc9_go_deagle",
			"arc9_fas_deagle",
			"arccw_ur_deagle",
			"arccw_deagle357",
			"m9k_deagle",
			"weapon_357"
		},
		weapon_elite = {
			"swb_css_fiveseven",
			"arc9_go_elite",
			"arc9_fas_m93r",
			"arccw_ud_glock",
			"arccw_makarov",
			"m9k_hk45",
			"weapon_pistol"
		},
		weapon_famas = {
			"swb_css_famas",
			"arc9_go_famas",
			"arc9_fas_famas",
			"arccw_ur_db",
			"arccw_famas",
			"m9k_famas",
			"weapon_ar2"
		},
		weapon_fiveseven = {
			"swb_css_fiveseven",
			"arc9_go_fiveseven",
			"arc9_fas_grach",
			"arccw_ur_m1911",
			"arccw_fiveseven",
			"m9k_m92beretta",
			"weapon_pistol"
		},
		weapon_g3sg1 = {
			"swb_css_g3sg1",
			"arc9_go_g1sg3",
			"arc9_fas_svd",
			"arccw_ur_g3",
			"arccw_g3a3",
			"m9k_dragunov",
			"weapon_crossbow"
		},
		weapon_galil = {
			"swb_css_galil",
			"arc9_go_galilar",
			"arc9_fas_ak74",
			"arccw_ur_spas12",
			"arccw_galil556",
			"m9k_winchester73",
			"weapon_ar2"
		},
		weapon_glock = {
			"swb_css_glock",
			"arc9_go_glock",
			"arc9_fas_g20",
			"arccw_ud_glock",
			"arccw_g18",
			"m9k_glock",
			"weapon_pistol"
		},
		weapon_m249 = {
			"swb_css_m249",
			"arc9_go_negev",
			"arc9_fas_rpk",
			"arccw_ud_m16",
			"arccw_minimi",
			"m9k_pkm",
			"weapon_ar2"
		},
		weapon_m3 = {
			"swb_css_m3super",
			"arc9_go_nova",
			"arc9_fas_m3super90",
			"arccw_ud_870",
			"arccw_shorty",
			"m9k_ithacam37",
			"weapon_shotgun"
		},
		weapon_m4a1 = {
			"swb_css_m4a1",
			"arc9_go_m4a1",
			"arc9_fas_m4a1",
			"arccw_ud_m16",
			"arccw_m4a1",
			"m9k_m4a1",
			"weapon_ar2"
		},
		weapon_mac10 = {
			"swb_css_mac10",
			"arc9_go_mac10",
			"arc9_fas_mac11",
			"arccw_ud_uzi",
			"arccw_mac11",
			"m9k_uzi",
			"weapon_smg1"
		},
		weapon_mp5navy = {
			"swb_css_mp5",
			"arc9_go_mp5sd",
			"arc9_fas_mp5",
			"arccw_ur_mp5",
			"arccw_mp5",
			"m9k_mp5",
			"weapon_smg1"
		},
		weapon_p228 = {
			"swb_css_p228",
			"arc9_go_p250",
			"arc9_fas_p226",
			"arccw_ur_m1911",
			"arccw_p228",
			"m9k_hk45",
			"weapon_pistol"
		},
		weapon_p90 = {
			"swb_css_p90",
			"arc9_go_p90",
			"arc9_fas_bizon",
			"arccw_ur_mp5",
			"arccw_p90",
			"m9k_bizonp19",
			"weapon_smg1"
		},
		weapon_scout = {
			"swb_css_scout",
			"arc9_go_ssg08",
			"arc9_fas_sks",
			"arccw_ud_mini14",
			"arccw_scout",
			"m9k_m24",
			"weapon_crossbow"
		},
		weapon_sg550 = {
			"swb_css_sg550",
			"arc9_go_scar20",
			"arc9_fas_sr25",
			"arccw_ur_g3",
			"arccw_sg550",
			"m9k_sl8",
			"weapon_crossbow"
		},
		weapon_sg552 = {
			"swb_css_sg552",
			"arc9_go_sg556",
			"arc9_fas_sg550",
			"arccw_ud_mini14",
			"arccw_sg552",
			"m9k_m16a4_acog",
			"weapon_ar2"
		},
		weapon_tmp = {
			"swb_css_tmp",
			"arc9_go_mp9",
			"arc9_fas_uzi",
			"arccw_ud_uzi",
			"arccw_tmp",
			"m9k_mp9",
			"weapon_smg1"
		},
		weapon_ump45 = {
			"swb_css_ump",
			"arc9_go_ump",
			"arc9_fas_colt",
			"arccw_ur_mp5",
			"arccw_ump45",
			"m9k_ump45",
			"weapon_smg1"
		},
		weapon_usp = {
			"swb_css_usp",
			"arc9_go_usp",
			"arc9_fas_m1911",
			"arccw_ur_329",
			"arccw_usp",
			"m9k_usp",
			"weapon_pistol"
		},
		weapon_xm1014 = {
			"swb_css_usp",
			"arc9_go_xm1014",
			"arc9_fas_saiga",
			"arccw_ud_m1014",
			"arccw_m1014",
			"m9k_spas12",
			"weapon_shotgun"
		},
		weapon_hegrenade = {
			"arc9_go_nade_frag",
			"arc9_fas_m67",
			"arccw_ud_m79",
			"arccw_nade_frag",
			"weapon_frag"
		},
		weapon_smokegrenade = {
			"arc9_go_nade_smoke",
			"arc9_fas_m18",
			"arccw_nade_smoke",
			"weapon_frag"
		},
		weapon_flashbang = {
			"arc9_go_nade_flashbang",
			"arc9_fas_m84",
			"arccw_nade_flash",
			"weapon_frag"
		},
		weapon_c4 = {
			"arc9_go_nade_c4",
			"m9k_suicide_bomb",
			"weapon_slam"
		}
	},
	Offsets = {
		arccw_ur_deagle = {
			Vector(-10, 0, 8),
			Angle(0, 0, 0)
		},
		arccw_ur_m1911 = {
			Vector(-10, 0, 6),
			Angle(0, 0, 0)
		},
		weapon_crowbar = {
			Vector(0, 0, 10),
			Angle(90, 0, 0)
		},
		arccw_ur_mp5 = {
			Vector(0, 0, 0),
			Angle(0, 0, 180)
		},
		arccw_ud_m79 = {
			Vector(0, 0, 0),
			Angle(-90, 0, 0)
		},
		arccw_ud_m16 = {
			Vector(0, 0, 10),
			Angle(30, 0, 0)
		},
		arccw_ur_ak = {
			Vector(-5, 0, 8),
			Angle(30, 0, 0)
		}
	}
}
Jailbreak.AltrenativeWeapons = altrenativeWeapons
do
	local IsValidModel, PrecacheModel = util.IsValidModel, util.PrecacheModel
	local GetStored = weapons.GetStored
	GM.PreGamemodeLoaded = function(self)
		for className, alternatives in pairs(altrenativeWeapons.Classes) do
			avaliableWeapons[#avaliableWeapons + 1] = className
			local alternative = WeaponHandler(className, alternatives, altrenativeWeapons.Offsets).Alternative
			if not alternative then
				goto _continue_0
			end
			local weapon = GetStored(alternative)
			if not weapon then
				goto _continue_0
			end
			weapon.DrawWeaponInfoBox = false
			local viewModel = weapon.ViewModel
			if viewModel and #viewModel ~= 0 and IsValidModel(viewModel) then
				PrecacheModel(viewModel)
			end
			local worldModel = weapon.WorldModel
			if worldModel and #worldModel ~= 0 and IsValidModel(worldModel) then
				PrecacheModel(worldModel)
			end
			::_continue_0::
		end
	end
end
do
	local slots = {
		weapon_knife = 0,
		weapon_usp = 1,
		weapon_p228 = 1,
		weapon_glock = 1,
		weapon_elite = 1,
		weapon_deagle = 1,
		weapon_fiveseven = 1,
		weapon_m3 = 2,
		weapon_aug = 2,
		weapon_awp = 2,
		weapon_p90 = 2,
		weapon_tmp = 2,
		weapon_ak47 = 2,
		weapon_m249 = 2,
		weapon_m4a1 = 2,
		weapon_g3sg1 = 2,
		weapon_galil = 2,
		weapon_mac10 = 2,
		weapon_scout = 2,
		weapon_sg550 = 2,
		weapon_sg552 = 2,
		weapon_ump45 = 2,
		weapon_famas = 2,
		weapon_xm1014 = 2,
		weapon_mp5navy = 2,
		weapon_flashbang = 4,
		weapon_hegrenade = 4,
		weapon_smokegrenade = 4,
		weapon_c4 = 5
	}
	return hook.Add("Initialize", "Jailbreak::WeaponSlotsForCSS", function()
		local _list_0 = weapons.GetList()
		for _index_0 = 1, #_list_0 do
			local swep = _list_0[_index_0]
			swep.Slot = slots[swep.ClassName] or swep.Slot or 0
		end
	end)
end
