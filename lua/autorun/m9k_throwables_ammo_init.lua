AddCSLuaFile()

if CLIENT then
	language.Add("m9k_mmm_beer_ammo","Beer")
	language.Add("m9k_mmm_decoy_ammo","Decoy")
	language.Add("m9k_mmm_flaregrenade_ammo","Flare")
	language.Add("m9k_mmm_flashbang_ammo","Flashbang")
	language.Add("m9k_mmm_grenade_ammo","HE Grenade")
	language.Add("m9k_mmm_incendiary_ammo","Incendiary")
	language.Add("m9k_mmm_molotov_ammo","Molotov")
	language.Add("m9k_mmm_pipebomb_ammo","Pipebomb")
	language.Add("m9k_mmm_rocks_ammo","Rocks")
	language.Add("m9k_mmm_smokegrenade_ammo","Smoke Grenade")
	language.Add("m9k_mmm_snowball_ammo","Snowball")
end

hook.Add("Initialize","M9k_Throwables_Ammo_Init",function()
	game.AddAmmoType({
		name = "m9k_mmm_beer"
	})

	game.AddAmmoType({
		name = "m9k_mmm_decoy"
	})

	game.AddAmmoType({
		name = "m9k_mmm_flaregrenade"
	})

	game.AddAmmoType({
		name = "m9k_mmm_flashbang"
	})

	game.AddAmmoType({
		name = "m9k_mmm_grenade"
	})

	game.AddAmmoType({
		name = "m9k_mmm_incendiary"
	})

	game.AddAmmoType({
		name = "m9k_mmm_molotov"
	})

	game.AddAmmoType({
		name = "m9k_mmm_pipebomb"
	})

	game.AddAmmoType({
		name = "m9k_mmm_rocks"
	})

	game.AddAmmoType({
		name = "m9k_mmm_smokegrenade"
	})

	game.AddAmmoType({
		name = "m9k_mmm_snowball"
	})
end)