if not MMM_M9k_IsBaseInstalled then return end -- Make sure the base is installed!
if game.SinglePlayer() and not IsMounted("csgo") then return end -- In singleplayer we do not even want this to be loaded in the first place!
if SERVER and not IsMounted("csgo") then
	SWEP.Base = "meteors_notmounted_base"

	return
end -- Make sure CS:GO is mounted!

SWEP.Base = "meteors_grenade_base_model"
SWEP.Category = "M9kR: Throwables"
SWEP.PrintName = "Molotov (CS:GO)"

SWEP.Spawnable = true

SWEP.ViewModelFOV = 55
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/cstrike/c_eq_fraggrenade.mdl"
SWEP.WorldModel = "models/weapons/w_eq_molotov_thrown.mdl" -- Higher quality for dropped ones.

SWEP.Primary.Ammo = "m9k_mmm_molotov"

SWEP.WorldModelStr = "models/weapons/w_eq_molotov.mdl"
SWEP.ViewModelStr = "models/weapons/w_eq_molotov.mdl"

SWEP.ModelWorldForwardMult = -1.5
SWEP.ModelWorldRightMult = 2
SWEP.ModelWorldUpMult = -4
SWEP.ModelWorldAngForward = -5
SWEP.ModelWorldAngRight = 195
SWEP.ModelWorldAngUp = 180

SWEP.ModelViewForwardMult = 0.8
SWEP.ModelViewRightMult = 0.1
SWEP.ModelViewUpMult = -1.75
SWEP.ModelViewAngForward = -10
SWEP.ModelViewAngRight = 180
SWEP.ModelViewAngUp = -150
SWEP.ModelViewBlacklistedBones = {
	["v_weapon.Flashbang_Parent"] = true,
	["v_weapon.strike_lever"] = true,
	["v_weapon.safety_pin"] = true,
	["v_weapon.pull_ring"] = true
}

SWEP.GrenadeClassEnt = "m9k_mmm_thrownincendiary"
SWEP.GrenadeModelStr = "models/weapons/w_eq_molotov_thrown.mdl"
SWEP.GrenadeThrowAng = Angle(0,0,-45)
SWEP.GrenadeTrailCol = Color(225,93,0)
SWEP.GrenadeNoPin = true

SWEP.ThrowSound = "weapons/iceaxe/iceaxe_swing1.wav"

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