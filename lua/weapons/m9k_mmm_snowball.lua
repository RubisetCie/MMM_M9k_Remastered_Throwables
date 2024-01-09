if not MMM_M9k_IsBaseInstalled then return end -- Make sure the base is installed!
if game.SinglePlayer() and not IsMounted("cstrike") then return end -- In singleplayer we do not even want this to be loaded in the first place!
if SERVER and not IsMounted("cstrike") then
	SWEP.Base = "meteors_notmounted_base"

	return
end -- Make sure CSS is mounted!

SWEP.Base = "meteors_grenade_base_model"
SWEP.Category = "M9kR: Throwables"
SWEP.PrintName = "Snowball"

SWEP.Spawnable = true

SWEP.ViewModelFOV = 55
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/cstrike/c_eq_fraggrenade.mdl"
SWEP.WorldModel = "models/props/cs_office/snowman_head.mdl"

SWEP.Primary.Ammo = "m9k_mmm_snowball"

SWEP.WorldModelScale = Vector(0.25,0.25,0.25)
SWEP.ModelWorldForwardMult = 3
SWEP.ModelWorldRightMult = 2.3
SWEP.ModelWorldUpMult = -0.5
SWEP.ModelWorldAngForward = -90
SWEP.ModelWorldAngRight = -40
SWEP.ModelWorldAngUp = 110

SWEP.ViewModelScale = Vector(0.25,0.25,0.25)
SWEP.ModelViewForwardMult = 4
SWEP.ModelViewRightMult = 2.1
SWEP.ModelViewUpMult = -0.3
SWEP.ModelViewAngForward = -90
SWEP.ModelViewAngRight = 180
SWEP.ModelViewAngUp = 110
SWEP.ModelViewBlacklistedBones = {
	["v_weapon.Flashbang_Parent"] = true,
	["v_weapon.strike_lever"] = true,
	["v_weapon.safety_pin"] = true,
	["v_weapon.pull_ring"] = true
}

SWEP.GrenadeClassEnt = "m9k_mmm_thrownsnowball"
SWEP.GrenadeModelStr = "models/props/cs_office/snowman_head.mdl"
SWEP.GrenadeNoPin = true

SWEP.ThrowSound = "weapons/iceaxe/iceaxe_swing1.wav"

if CLIENT then

	local drawSimpleText = draw.SimpleText
	local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER

	local cCached1 = Color(255,235,0)


	function SWEP:DrawWeaponSelection(x,y,wide,tall)
		drawSimpleText("E","WeaponIcons_m9k_css",x + wide / 2 * 1.2,y + tall * 0.25,cCached1,TEXT_ALIGN_CENTER)
	end
end