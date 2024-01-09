AddCSLuaFile()

local sTag = "M9kR_Initialize_Addon_Throwables"


if SERVER then
	resource.AddWorkshop("2205783122") -- If you don't want others to automatically download M9k Remastered content on joining, remove this line or comment it out.
end

-- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- --
-- Kill icons
-- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- --

if CLIENT then


	local tData = {
		["m9k_mmm_thrownbeer"] = "vgui/hud/m9k_mmm_thrownbeer",
		["m9k_mmm_thrownfrag"] = "vgui/hud/m9k_mmm_thrownfrag",
		["m9k_mmm_flame"] = "vgui/hud/m9k_mmm_flame",
		["m9k_mmm_thrownpipebomb"] = "vgui/hud/m9k_mmm_thrownpipebomb",
		["m9k_mmm_thrownrock"] = "vgui/hud/m9k_mmm_thrownrock",
		["m9k_mmm_thrownsnowball"] = "vgui/hud/m9k_mmm_thrownsnowball"
	}


	local killiconAdd = killicon.Add

	local cCached1 = Color(255,255,255)


	hook.Add("Initialize",sTag,function()

		hook.Remove("Initialize",sTag)


		if MMM_M9k_IsBaseInstalled then

			for Key,v in pairs(tData) do
				killiconAdd(Key,v,cCached1)
			end
		end

	end)
end

-- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- --
-- Ammo
-- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- --

if CLIENT then

	local languageAdd = language.Add -- Improve load times by microseconds.


	languageAdd("m9k_mmm_beer_ammo","Beer")
	languageAdd("m9k_mmm_decoy_ammo","Decoy")
	languageAdd("m9k_mmm_flaregrenade_ammo","Flare")
	languageAdd("m9k_mmm_flashbang_ammo","Flashbang")
	languageAdd("m9k_mmm_grenade_ammo","HE Grenade")
	languageAdd("m9k_mmm_molotov_ammo","Molotov")
	languageAdd("m9k_mmm_pipebomb_ammo","Pipebomb")
	languageAdd("m9k_mmm_rocks_ammo","Rocks")
	languageAdd("m9k_mmm_smokegrenade_ammo","Smoke Grenade")
	languageAdd("m9k_mmm_snowball_ammo","Snowball")

end


hook.Add("OnGamemodeLoaded",sTag,function()

	hook.Remove("OnGamemodeLoaded",sTag)

	if not MMM_M9k_IsBaseInstalled then return end


	local gameAddAmmoType = game.AddAmmoType -- Improve load times by microseconds.


	gameAddAmmoType({
		name = "40mmGrenade",
		dmgtype = DMG_BULLET
	})

	gameAddAmmoType({
		name = "ProxMine",
		dmgtype = DMG_BULLET
	})

	gameAddAmmoType({
		name = "rzmflaregun",
		dmgtype = DMG_BULLET
	})

	gameAddAmmoType({
		name = "NerveGas"
	})

	gameAddAmmoType({
		name = "StickyGrenade"
	})

	gameAddAmmoType({
		name = "nitroG"
	})

	gameAddAmmoType({
		name = "Harpoon"
	})

	gameAddAmmoType({
		name = "IED_Detonators"
	})

	gameAddAmmoType({
		name = "M9k_Nuclear_Warhead"
	})

	gameAddAmmoType({
		name = "SatCannon"
	})

end)

-- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- --