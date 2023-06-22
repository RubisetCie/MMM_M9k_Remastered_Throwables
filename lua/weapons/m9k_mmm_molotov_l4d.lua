if not MMM_M9k_IsBaseInstalled then return end -- Make sure the base is installed!
if game.SinglePlayer() and not IsMounted("left4dead") and not IsMounted("left4dead2") then return end -- In singleplayer we do not even want this to be loaded in the first place!
if SERVER and not IsMounted("left4dead") and not IsMounted("left4dead2") then
	SWEP.Base = "meteors_notmounted_base"

	return
end -- We make sure that either Left4Dead or Left4Dead2 is installed since the models are identical.

SWEP.Base = "meteors_grenade_base_model"
SWEP.Category = "M9kR: Throwables"
SWEP.PrintName = "Molotov (L4D)"

SWEP.Spawnable = true

SWEP.ViewModelFOV = 55
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/cstrike/c_eq_fraggrenade.mdl"
SWEP.WorldModel = "models/w_models/weapons/w_eq_molotov.mdl"

SWEP.Primary.Ammo = "m9k_mmm_molotov"

SWEP.ModelWorldForwardMult = 2.75
SWEP.ModelWorldRightMult = 2
SWEP.ModelWorldUpMult = -1
SWEP.ModelWorldAngForward = 5
SWEP.ModelWorldAngRight = 195
SWEP.ModelWorldAngUp = -5

SWEP.ModelViewForwardMult = 3.5
SWEP.ModelViewRightMult = 1.75
SWEP.ModelViewAngForward = -10
SWEP.ModelViewAngRight = 180
SWEP.ModelViewAngUp = 35
SWEP.ModelViewBlacklistedBones = {
	["v_weapon.Flashbang_Parent"] = true,
	["v_weapon.strike_lever"] = true,
	["v_weapon.safety_pin"] = true,
	["v_weapon.pull_ring"] = true
}

SWEP.GrenadeClassEnt = "m9k_mmm_thrownincendiary"
SWEP.GrenadeModelStr = "models/w_models/weapons/w_eq_molotov.mdl"
SWEP.GrenadeThrowAng = Angle(0,0,-45)
SWEP.GrenadeTrailCol = Color(225,93,0)
SWEP.GrenadeNoPin = true

SWEP.ThrowSound = "weapons/iceaxe/iceaxe_swing1.wav"
SWEP.DrawSound = "weapons/molotov/molotov_helpinghandextend.wav"

if CLIENT then

	local drawSimpleText = draw.SimpleText
	local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER

	local cCached1 = Color(255,235,0)


	function SWEP:DrawWeaponSelection(x,y,wide,tall)
		drawSimpleText("J","WeaponIcons_m9k_css",x + wide / 2 * 1.055,y + tall * 0.275,cCached1,TEXT_ALIGN_CENTER)
	end
end

if SERVER then

	function SWEP:ProjectileModifications(ent_Projectile)
		ent_Projectile.IsMolotov = true
	end
end