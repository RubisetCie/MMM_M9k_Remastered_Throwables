if not MMM_M9k_IsBaseInstalled then return end -- Make sure the base is installed!

SWEP.Base = "meteors_grenade_base_model"
SWEP.Category = "M9kR: Throwables"
SWEP.PrintName = "Rock"

SWEP.Spawnable = true

SWEP.ViewModelFOV = 55
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/cstrike/c_eq_fraggrenade.mdl"
SWEP.WorldModel = "models/props_debris/concrete_chunk05g.mdl"

SWEP.Primary.Ammo = "m9k_mmm_rocks"

SWEP.WorldModelScale = Vector(0.75,0.75,0.75)
SWEP.ModelWorldForwardMult = 2.6
SWEP.ModelWorldRightMult = 2.3
SWEP.ModelWorldUpMult = -0.5
SWEP.ModelWorldAngForward = -90
SWEP.ModelWorldAngRight = -40
SWEP.ModelWorldAngUp = 110

SWEP.ModelViewForwardMult = 3.5
SWEP.ModelViewRightMult = 2
SWEP.ModelViewUpMult = -0.5
SWEP.ModelViewAngForward = -90
SWEP.ModelViewAngRight = 180
SWEP.ModelViewAngUp = 110
SWEP.ModelViewBlacklistedBones = {
	["v_weapon.Flashbang_Parent"] = true,
	["v_weapon.strike_lever"] = true,
	["v_weapon.safety_pin"] = true,
	["v_weapon.pull_ring"] = true
}

SWEP.GrenadeClassEnt = "m9k_mmm_thrownrock"
SWEP.GrenadeModelStr = "models/props_debris/concrete_chunk05g.mdl"
SWEP.GrenadeThrowAng = Angle(0,0,-45)
SWEP.GrenadeNoPin = true

SWEP.ThrowSound = "weapons/iceaxe/iceaxe_swing1.wav"

if CLIENT then

	local drawSimpleText = draw.SimpleText
	local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER

	local cCached1 = Color(255,235,0)


	function SWEP:DrawWeaponSelection(x,y,wide,tall)
		drawSimpleText("D","WeaponIcons_m9k_css",x + wide / 2 * 0.95,y + tall * 0.275,cCached1,TEXT_ALIGN_CENTER)
	end
end