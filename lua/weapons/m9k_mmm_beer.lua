if not MMM_M9k_IsBaseInstalled then return end -- Make sure the base is installed!

SWEP.Base = "meteors_grenade_base_model"
SWEP.Category = "M9kR: Throwables"
SWEP.PrintName = "Beer"

SWEP.Spawnable = true

SWEP.ViewModelFOV = 55
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/cstrike/c_eq_fraggrenade.mdl"
SWEP.WorldModel = "models/props_junk/garbage_glassbottle001a.mdl"

SWEP.Primary.Ammo = "m9k_mmm_beer"

SWEP.WorldModelScale = Vector(0.75,0.75,0.75)
SWEP.ModelWorldForwardMult = 3.25
SWEP.ModelWorldRightMult = 2
SWEP.ModelWorldUpMult = -2
SWEP.ModelWorldAngForward = 5
SWEP.ModelWorldAngRight = 195
SWEP.ModelWorldAngUp = -95

SWEP.ViewModelScale = Vector(0.5,0.5,0.5)
SWEP.ModelViewForwardMult = 4
SWEP.ModelViewRightMult = 2.25
SWEP.ModelViewUpMult = -1
SWEP.ModelViewAngForward = -5
SWEP.ModelViewAngRight = 180
SWEP.ModelViewAngUp = -35
SWEP.ModelViewBlacklistedBones = {
	["v_weapon.Flashbang_Parent"] = true,
	["v_weapon.strike_lever"] = true,
	["v_weapon.safety_pin"] = true,
	["v_weapon.pull_ring"] = true
}

SWEP.GrenadeClassEnt = "m9k_mmm_thrownbeer"
SWEP.GrenadeModelStr = "models/props_junk/garbage_glassbottle001a.mdl"
SWEP.GrenadeNoPin = true

SWEP.ThrowSound = "weapons/iceaxe/iceaxe_swing1.wav"

if CLIENT then

	local drawSimpleText = draw.SimpleText
	local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER

	local cCached1 = Color(255,235,0)


	function SWEP:DrawWeaponSelection(x,y,wide,tall)
		drawSimpleText("C","WeaponIcons_m9k_css",x + wide / 2 * 0.86,y + tall * 0.25,cCached1,TEXT_ALIGN_CENTER)
	end
end